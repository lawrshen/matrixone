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

package txnimpl

import (
	"bytes"
	"sync"

	gvec "github.com/matrixorigin/matrixone/pkg/container/vector"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/catalog"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/common"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/handle"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/txnif"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/model"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/txn/txnbase"
)

type txnBlock struct {
	*txnbase.TxnBlock
	isUncommitted bool
	entry         *catalog.BlockEntry
	table         *txnTable
}

type blockIt struct {
	sync.RWMutex
	linkIt *common.LinkIt
	curr   *catalog.BlockEntry
	table  *txnTable
}

type relBlockIt struct {
	sync.RWMutex
	rel       handle.Relation
	segmentIt handle.SegmentIt
	blockIt   handle.BlockIt
}

func newBlockIt(table *txnTable, meta *catalog.SegmentEntry) *blockIt {
	it := &blockIt{
		table:  table,
		linkIt: meta.MakeBlockIt(true),
	}
	for it.linkIt.Valid() {
		curr := it.linkIt.Get().GetPayload().(*catalog.BlockEntry)
		curr.RLock()
		if curr.TxnCanRead(it.table.store.txn, curr.RWMutex) {
			curr.RUnlock()
			it.curr = curr
			break
		}
		curr.RUnlock()
		it.linkIt.Next()
	}
	return it
}

func (it *blockIt) Close() error { return nil }

func (it *blockIt) Valid() bool { return it.linkIt.Valid() }

func (it *blockIt) Next() {
	valid := true
	for {
		it.linkIt.Next()
		node := it.linkIt.Get()
		if node == nil {
			it.curr = nil
			break
		}
		entry := node.GetPayload().(*catalog.BlockEntry)
		entry.RLock()
		valid = entry.TxnCanRead(it.table.store.txn, entry.RWMutex)
		entry.RUnlock()
		if valid {
			it.curr = entry
			break
		}
	}
}

func (it *blockIt) GetBlock() handle.Block {
	return buildBlock(it.table, it.curr)
}

func buildBlock(table *txnTable, meta *catalog.BlockEntry) handle.Block {
	if meta.GetSegment().GetTable().GetDB().IsSystemDB() {
		return newSysBlock(table, meta)
	}
	return newBlock(table, meta)
}

func newBlock(table *txnTable, meta *catalog.BlockEntry) *txnBlock {
	blk := &txnBlock{
		TxnBlock: &txnbase.TxnBlock{
			Txn: table.store.txn,
		},
		entry:         meta,
		table:         table,
		isUncommitted: isLocalSegmentByID(meta.GetSegment().ID),
	}
	return blk
}

func (blk *txnBlock) GetMeta() interface{} { return blk.entry }
func (blk *txnBlock) String() string {
	blkData := blk.entry.GetBlockData()
	return blkData.PPString(common.PPL1, 0, "")
	// return blk.entry.String()
}

func (blk *txnBlock) IsUncommitted() bool {
	return blk.isUncommitted
}
func (blk *txnBlock) GetTotalChanges() int {
	return blk.entry.GetBlockData().GetTotalChanges()
}
func (blk *txnBlock) IsAppendableBlock() bool { return blk.entry.IsAppendable() }
func (blk *txnBlock) ID() uint64              { return blk.entry.GetID() }
func (blk *txnBlock) Fingerprint() *common.ID { return blk.entry.AsCommonID() }
func (blk *txnBlock) BatchDedup(pks *gvec.Vector) (err error) {
	blkData := blk.entry.GetBlockData()
	blk.Txn.GetStore().LogBlockID(blk.getDBID(), blk.entry.GetSegment().GetTable().GetID(), blk.entry.GetID())
	return blkData.BatchDedup(blk.Txn, pks)
}

func (blk *txnBlock) getDBID() uint64 {
	return blk.entry.GetSegment().GetTable().GetDB().ID
}

func (blk *txnBlock) RangeDelete(start, end uint32) (err error) {
	return blk.Txn.GetStore().RangeDelete(blk.getDBID(), blk.entry.AsCommonID(), start, end)
}

func (blk *txnBlock) Update(row uint32, col uint16, v interface{}) (err error) {
	return blk.Txn.GetStore().Update(blk.getDBID(), blk.entry.AsCommonID(), row, col, v)
}

// TODO: temp use coarse rows
func (blk *txnBlock) Rows() int {
	if blk.isUncommitted {
		return blk.table.localSegment.GetBlockRows(blk.entry)
	}
	return blk.entry.GetBlockData().Rows(blk.Txn, true)
}

func (blk *txnBlock) GetColumnDataById(colIdx int, compressed, decompressed *bytes.Buffer) (*model.ColumnView, error) {
	if blk.isUncommitted {
		return blk.table.localSegment.GetColumnDataById(blk.entry, colIdx, compressed, decompressed)
	}
	return blk.entry.GetBlockData().GetColumnDataById(blk.Txn, colIdx, compressed, decompressed)
}
func (blk *txnBlock) GetColumnDataByName(attr string, compressed, decompressed *bytes.Buffer) (*model.ColumnView, error) {
	if blk.isUncommitted {
		attrId := blk.table.entry.GetSchema().GetColIdx(attr)
		return blk.table.localSegment.GetColumnDataById(blk.entry, attrId, compressed, decompressed)
	}
	return blk.entry.GetBlockData().GetColumnDataByName(blk.Txn, attr, compressed, decompressed)
}

func (blk *txnBlock) LogTxnEntry(entry txnif.TxnEntry, readed []*common.ID) (err error) {
	return blk.Txn.GetStore().LogTxnEntry(blk.getDBID(), blk.entry.GetSegment().GetTable().GetID(), entry, readed)
}

func (blk *txnBlock) GetSegment() (seg handle.Segment) {
	seg = newSegment(blk.table, blk.entry.GetSegment())
	return
}

func (blk *txnBlock) GetByFilter(filter *handle.Filter) (offset uint32, err error) {
	return blk.entry.GetBlockData().GetByFilter(blk.table.store.txn, filter)
}

// TODO: segmentit or tableit
func newRelationBlockIt(rel handle.Relation) *relBlockIt {
	segmentIt := rel.MakeSegmentIt()
	if !segmentIt.Valid() {
		return new(relBlockIt)
	}
	seg := segmentIt.GetSegment()
	blockIt := seg.MakeBlockIt()
	for !blockIt.Valid() {
		segmentIt.Next()
		if !segmentIt.Valid() {
			return new(relBlockIt)
		}
		seg = segmentIt.GetSegment()
		blockIt = seg.MakeBlockIt()
	}
	return &relBlockIt{
		blockIt:   blockIt,
		segmentIt: segmentIt,
		rel:       rel,
	}
}

func (it *relBlockIt) Close() error { return nil }
func (it *relBlockIt) Valid() bool {
	if it.segmentIt == nil || !it.segmentIt.Valid() {
		return false
	}
	if !it.blockIt.Valid() {
		it.segmentIt.Next()
		if !it.segmentIt.Valid() {
			return false
		}
		seg := it.segmentIt.GetSegment()
		it.blockIt = seg.MakeBlockIt()
		return it.blockIt.Valid()
	}
	return true
}

func (it *relBlockIt) GetBlock() handle.Block {
	return it.blockIt.GetBlock()
}

func (it *relBlockIt) Next() {
	it.blockIt.Next()
	if it.blockIt.Valid() {
		return
	}
	it.segmentIt.Next()
	if !it.segmentIt.Valid() {
		return
	}
	seg := it.segmentIt.GetSegment()
	it.blockIt = seg.MakeBlockIt()
}
