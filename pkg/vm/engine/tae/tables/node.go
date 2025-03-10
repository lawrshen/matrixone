// Copyright 2021 Matrix Origin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package tables

import (
	"bytes"
	"sync/atomic"
	"time"

	"github.com/RoaringBitmap/roaring"
	gbat "github.com/matrixorigin/matrixone/pkg/container/batch"
	gvec "github.com/matrixorigin/matrixone/pkg/container/vector"
	"github.com/matrixorigin/matrixone/pkg/logutil"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/buffer"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/buffer/base"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/catalog"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/container/batch"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/container/vector"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/data"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/file"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/txnif"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/tables/updates"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/tasks"
)

type appendableNode struct {
	*buffer.Node
	file      file.Block
	block     *dataBlock
	data      batch.IBatch
	rows      uint32
	mgr       base.INodeManager
	flushTs   uint64
	ckpTs     uint64
	exception *atomic.Value
}

func newNode(mgr base.INodeManager, block *dataBlock, file file.Block) *appendableNode {
	flushTs, err := file.ReadTS()
	if err != nil {
		panic(err)
	}
	impl := new(appendableNode)
	impl.exception = new(atomic.Value)
	id := block.meta.AsCommonID()
	impl.Node = buffer.NewNode(impl, mgr, *id, uint64(catalog.EstimateBlockSize(block.meta, block.meta.GetSchema().BlockMaxRows)))
	impl.UnloadFunc = impl.OnUnload
	impl.LoadFunc = impl.OnLoad
	impl.UnloadableFunc = impl.CheckUnloadable
	// impl.DestroyFunc = impl.OnDestory
	impl.file = file
	impl.mgr = mgr
	impl.block = block
	impl.flushTs = flushTs
	mgr.RegisterNode(impl)
	return impl
}

func (node *appendableNode) TryPin() (base.INodeHandle, error) {
	return node.mgr.TryPin(node.Node, time.Second)
}

func (node *appendableNode) Rows(txn txnif.AsyncTxn, coarse bool) uint32 {
	if coarse {
		readLock := node.block.mvcc.GetSharedLock()
		defer readLock.Unlock()
		return node.rows
	}
	// TODO: fine row count
	// 1. Load txn ts zonemap
	// 2. Calculate fine row count
	return 0
}

func (node *appendableNode) CheckUnloadable() bool {
	return !node.block.mvcc.HasActiveAppendNode()
}

func (node *appendableNode) GetColumnsView(maxRow uint32) (view batch.IBatch, err error) {
	if exception := node.exception.Load(); exception != nil {
		err = exception.(error)
		return
	}
	attrs := node.data.GetAttrs()
	vecs := make([]vector.IVector, len(attrs))
	for _, attrId := range attrs {
		vec, err := node.GetVectorView(maxRow, attrId)
		if err != nil {
			return view, err
		}
		vecs[attrId] = vec
	}
	view, err = batch.NewBatch(attrs, vecs)
	return
}

func (node *appendableNode) GetVectorView(maxRow uint32, colIdx int) (vec vector.IVector, err error) {
	if exception := node.exception.Load(); exception != nil {
		err = exception.(error)
		return
	}
	ivec, err := node.data.GetVectorByAttr(colIdx)
	if err != nil {
		return
	}
	vec = ivec.Window(0, maxRow)
	return
}

// TODO: Apply updates and txn sels
func (node *appendableNode) GetVectorCopy(maxRow uint32, colIdx int, compressed, decompressed *bytes.Buffer) (vec *gvec.Vector, err error) {
	if exception := node.exception.Load(); exception != nil {
		logutil.Errorf("%v", exception)
		err = exception.(error)
		return
	}
	ro, err := node.GetVectorView(maxRow, colIdx)
	if err != nil {
		return
	}
	if decompressed == nil {
		return ro.CopyToVector()
	}
	return ro.CopyToVectorWithBuffer(compressed, decompressed)
}

func (node *appendableNode) SetBlockMaxFlushTS(ts uint64) {
	atomic.StoreUint64(&node.flushTs, ts)
}

func (node *appendableNode) GetBlockMaxFlushTS() uint64 {
	return atomic.LoadUint64(&node.flushTs)
}

func (node *appendableNode) OnLoad() {
	if exception := node.exception.Load(); exception != nil {
		logutil.Errorf("%v", exception)
		return
	}
	var err error
	schema := node.block.meta.GetSchema()
	if node.data, err = node.file.LoadIBatch(schema.Types(), schema.BlockMaxRows); err != nil {
		node.exception.Store(err)
	}
}

func (node *appendableNode) flushData(ts uint64, colData batch.IBatch) (err error) {
	if exception := node.exception.Load(); exception != nil {
		logutil.Errorf("%v", exception)
		err = exception.(error)
		return
	}
	mvcc := node.block.mvcc
	if node.GetBlockMaxFlushTS() == ts {
		logutil.Infof("[TS=%d] Unloading block with no flush: %s", ts, node.block.meta.AsCommonID().String())
		return data.ErrStaleRequest
	}
	masks := make(map[uint16]*roaring.Bitmap)
	vals := make(map[uint16]map[uint32]interface{})
	readLock := mvcc.GetSharedLock()
	for i := range node.block.meta.GetSchema().ColDefs {
		chain := mvcc.GetColumnChain(uint16(i))

		chain.RLock()
		updateMask, updateVals := chain.CollectUpdatesLocked(ts)
		chain.RUnlock()
		if updateMask != nil {
			masks[uint16(i)] = updateMask
			vals[uint16(i)] = updateVals
		}
	}
	deleteChain := mvcc.GetDeleteChain()
	dnode := deleteChain.CollectDeletesLocked(ts, false).(*updates.DeleteNode)
	readLock.Unlock()
	logutil.Infof("[TS=%d] Unloading block %s", ts, node.block.meta.AsCommonID().String())
	var deletes *roaring.Bitmap
	if dnode != nil {
		deletes = dnode.GetDeleteMaskLocked()
	}
	scope := node.block.meta.AsCommonID()
	task, err := node.block.scheduler.ScheduleScopedFn(tasks.WaitableCtx, tasks.IOTask, scope, node.block.ABlkFlushDataClosure(ts, colData, masks, vals, deletes))
	if err != nil {
		return
	}
	err = task.WaitDone()
	return
}

func (node *appendableNode) OnUnload() {
	if exception := node.exception.Load(); exception != nil {
		logutil.Errorf("%v", exception)
		return
	}
	ts := node.block.mvcc.LoadMaxVisible()
	needCkp := true
	if err := node.flushData(ts, node.data); err != nil {
		needCkp = false
		if err == data.ErrStaleRequest {
			// err = nil
		} else {
			logutil.Warnf("%s: %v", node.block.meta.String(), err)
			node.exception.Store(err)
		}
	}
	node.data.Close()
	node.data = nil
	if needCkp {
		_, _ = node.block.scheduler.ScheduleScopedFn(nil, tasks.CheckpointTask, node.block.meta.AsCommonID(), node.block.CheckpointWALClosure(ts))
	}
}

func (node *appendableNode) Close() (err error) {
	if exception := node.exception.Load(); exception != nil {
		logutil.Warnf("%v", exception)
		err = exception.(error)
		return
	}
	node.Node.Close()
	if exception := node.exception.Load(); exception != nil {
		logutil.Warnf("%v", exception)
		err = exception.(error)
		return
	}
	if node.data != nil {
		node.data.Close()
		node.data = nil
	}
	return
}

func (node *appendableNode) PrepareAppend(rows uint32) (n uint32, err error) {
	if exception := node.exception.Load(); exception != nil {
		logutil.Errorf("%v", exception)
		err = exception.(error)
		return
	}
	left := node.block.meta.GetSchema().BlockMaxRows - node.rows
	if left == 0 {
		err = data.ErrNotAppendable
		return
	}
	if rows > left {
		n = left
	} else {
		n = rows
	}
	return
}

func (node *appendableNode) ApplyAppend(bat *gbat.Batch, offset, length uint32, txn txnif.AsyncTxn) (from uint32, err error) {
	if exception := node.exception.Load(); exception != nil {
		logutil.Errorf("%v", exception)
		err = exception.(error)
		return
	}
	if node.data == nil {
		vecs := make([]vector.IVector, len(bat.Vecs))
		attrs := make([]int, len(bat.Vecs))
		for i, vec := range bat.Vecs {
			attrs[i] = i
			vecs[i] = vector.NewVector(vec.Typ, uint64(node.block.meta.GetSchema().BlockMaxRows))
		}
		node.data, _ = batch.NewBatch(attrs, vecs)
	}
	from = node.rows
	for idx, attr := range node.data.GetAttrs() {
		for i, a := range bat.Attrs {
			if a == node.block.meta.GetSchema().ColDefs[idx].Name {
				vec, err := node.data.GetVectorByAttr(attr)
				if err != nil {
					return 0, err
				}
				if _, err = vec.AppendVector(bat.Vecs[i], int(offset)); err != nil {
					return from, err
				}
			}
		}
	}
	node.rows += length
	return
}
