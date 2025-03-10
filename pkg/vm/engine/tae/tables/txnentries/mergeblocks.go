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

package txnentries

import (
	"sync"

	"github.com/matrixorigin/matrixone/pkg/logutil"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/catalog"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/common"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/container/compute"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/handle"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/txnif"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/tasks"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/wal"
)

type mergeBlocksEntry struct {
	sync.RWMutex
	txn         txnif.AsyncTxn
	relation    handle.Relation
	droppedSegs []*catalog.SegmentEntry
	createdSegs []*catalog.SegmentEntry
	droppedBlks []*catalog.BlockEntry
	createdBlks []*catalog.BlockEntry
	mapping     []uint32
	fromAddr    []uint32
	toAddr      []uint32
	scheduler   tasks.TaskScheduler
}

func NewMergeBlocksEntry(txn txnif.AsyncTxn, relation handle.Relation, droppedSegs, createdSegs []*catalog.SegmentEntry, droppedBlks, createdBlks []*catalog.BlockEntry, mapping, fromAddr, toAddr []uint32, scheduler tasks.TaskScheduler) *mergeBlocksEntry {
	return &mergeBlocksEntry{
		txn:         txn,
		relation:    relation,
		createdSegs: createdSegs,
		droppedSegs: droppedSegs,
		createdBlks: createdBlks,
		droppedBlks: droppedBlks,
		mapping:     mapping,
		fromAddr:    fromAddr,
		toAddr:      toAddr,
		scheduler:   scheduler,
	}
}

func (entry *mergeBlocksEntry) PrepareRollback() (err error) {
	// TODO: remove block file? (should be scheduled and executed async)
	return
}
func (entry *mergeBlocksEntry) ApplyRollback() (err error) { return }
func (entry *mergeBlocksEntry) ApplyCommit(index *wal.Index) (err error) {
	if err = entry.scheduler.Checkpoint([]*wal.Index{index}); err != nil {
		// TODO:
		// Right now scheduler may be stopped before ApplyCommit and then it returns schedule error here.
		// We'll ensure the schduler can only be stopped after txn manager being stopped.
		logutil.Warnf("Schedule checkpoint task failed: %v", err)
		err = nil
	}
	return entry.PostCommit()
}

func (entry *mergeBlocksEntry) PostCommit() (err error) {
	for _, blk := range entry.droppedBlks {
		if _, _ = entry.scheduler.ScheduleScopedFn(nil, tasks.CheckpointTask, blk.AsCommonID(), blk.GetBlockData().CheckpointWALClosure(entry.txn.GetCommitTS())); err != nil {
			// TODO:
			// Right now scheduler may be stopped before ApplyCommit and then it returns schedule error here.
			// We'll ensure the schduler can only be stopped after txn manager being stopped.
			logutil.Warnf("Schedule checkpoint task failed: %v", err)
			err = nil
		}
	}
	return
}

func (entry *mergeBlocksEntry) MakeCommand(csn uint32) (cmd txnif.TxnCmd, err error) {
	droppedSegs := make([]*common.ID, 0)
	for _, blk := range entry.droppedSegs {
		id := blk.AsCommonID()
		droppedSegs = append(droppedSegs, id)
	}
	createdSegs := make([]*common.ID, 0)
	for _, blk := range entry.createdSegs {
		id := blk.AsCommonID()
		createdSegs = append(createdSegs, id)
	}
	droppedBlks := make([]*common.ID, 0)
	for _, blk := range entry.droppedBlks {
		id := blk.AsCommonID()
		droppedBlks = append(droppedBlks, id)
	}
	createdBlks := make([]*common.ID, 0)
	for _, blk := range entry.createdBlks {
		createdBlks = append(createdBlks, blk.AsCommonID())
	}
	cmd = newMergeBlocksCmd(entry.relation.ID(), droppedSegs, createdSegs, droppedBlks, createdBlks, entry.mapping, entry.fromAddr, entry.toAddr)
	return
}

func (entry *mergeBlocksEntry) resolveAddr(fromPos int, fromOffset uint32) (toPos int, toOffset uint32) {
	totalFromOffset := entry.fromAddr[fromPos] + fromOffset
	totalToOffset := entry.mapping[totalFromOffset]
	left, right := 0, len(entry.toAddr)-1
	for left <= right {
		toPos = (left + right) / 2
		if entry.toAddr[toPos] < totalToOffset {
			left = toPos + 1
		} else if entry.toAddr[toPos] > totalToOffset {
			right = toPos - 1
		} else {
			break
		}
	}

	// if toPos == 0 && entry.toAddr[toPos] < totalToOffset {
	if entry.toAddr[toPos] > totalToOffset {
		toPos = toPos - 1
	}
	toOffset = totalToOffset - entry.toAddr[toPos]
	// logutil.Infof("mapping=%v", entry.mapping)
	// logutil.Infof("fromPos=%d, fromOff=%d", fromPos, fromOffset)
	// logutil.Infof("fromAddr=%v", entry.fromAddr)
	// logutil.Infof("toAddr=%v", entry.toAddr)
	// logutil.Infof("toPos=%d, toOffset=%d", toPos, toOffset)
	return
}

func (entry *mergeBlocksEntry) PrepareCommit() (err error) {
	blks := make([]handle.Block, len(entry.createdBlks))
	for i, meta := range entry.createdBlks {
		id := meta.AsCommonID()
		seg, err := entry.relation.GetSegment(id.SegmentID)
		if err != nil {
			return err
		}
		blk, err := seg.GetBlock(id.BlockID)
		if err != nil {
			return err
		}
		blks[i] = blk
	}
	for fromPos, dropped := range entry.droppedBlks {
		dataBlock := dropped.GetBlockData()
		view := dataBlock.CollectChangesInRange(entry.txn.GetStartTS(), entry.txn.GetCommitTS())
		if view == nil {
			continue
		}
		deletes := view.DeleteMask
		for colIdx, mask := range view.UpdateMasks {
			vals := view.UpdateVals[colIdx]
			view.UpdateMasks[colIdx], view.UpdateVals[colIdx], view.DeleteMask = compute.ShuffleByDeletes(mask, vals, deletes)
			for row, v := range view.UpdateVals[colIdx] {
				toPos, toRow := entry.resolveAddr(fromPos, row)

				if err = blks[toPos].Update(toRow, colIdx, v); err != nil {
					return
				}
			}
		}
		if len(view.UpdateMasks) == 0 {
			_, _, view.DeleteMask = compute.ShuffleByDeletes(nil, nil, view.DeleteMask)
		}
		if view.DeleteMask != nil {
			it := view.DeleteMask.Iterator()
			for it.HasNext() {
				row := it.Next()
				toPos, toRow := entry.resolveAddr(fromPos, row)
				if err = blks[toPos].RangeDelete(toRow, toRow); err != nil {
					return
				}
			}
		}
	}
	return
}
