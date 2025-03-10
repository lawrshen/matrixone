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
	"errors"
	"fmt"

	"github.com/matrixorigin/matrixone/pkg/container/batch"
	"github.com/matrixorigin/matrixone/pkg/container/vector"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/catalog"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/common"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/data"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/handle"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/txnif"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/tables/updates"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/txn/txnbase"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/wal"
)

var (
	ErrDuplicateNode = errors.New("tae: duplicate node")
)

type txnTable struct {
	store        *txnStore
	createEntry  txnif.TxnEntry
	dropEntry    txnif.TxnEntry
	localSegment *localSegment
	updateNodes  map[common.ID]txnif.UpdateNode
	deleteNodes  map[common.ID]txnif.DeleteNode
	entry        *catalog.TableEntry
	logs         []wal.LogEntry
	maxSegId     uint64
	maxBlkId     uint64

	txnEntries []txnif.TxnEntry
	csnStart   uint32
}

func newTxnTable(store *txnStore, entry *catalog.TableEntry) *txnTable {
	tbl := &txnTable{
		store:       store,
		entry:       entry,
		updateNodes: make(map[common.ID]txnif.UpdateNode),
		deleteNodes: make(map[common.ID]txnif.DeleteNode),
		logs:        make([]wal.LogEntry, 0),
		txnEntries:  make([]txnif.TxnEntry, 0),
	}
	return tbl
}

func (tbl *txnTable) LogSegmentID(sid uint64) {
	if tbl.maxSegId < sid {
		tbl.maxSegId = sid
	}
}

func (tbl *txnTable) LogBlockID(bid uint64) {
	if tbl.maxBlkId < bid {
		tbl.maxBlkId = bid
	}
}

func (tbl *txnTable) WaitSynced() {
	for _, e := range tbl.logs {
		if err := e.WaitDone(); err != nil {
			panic(err)
		}
		e.Free()
	}
}

func (tbl *txnTable) CollectCmd(cmdMgr *commandManager) (err error) {
	tbl.csnStart = uint32(cmdMgr.GetCSN())
	for _, txnEntry := range tbl.txnEntries {
		csn := cmdMgr.GetCSN()
		cmd, err := txnEntry.MakeCommand(csn)
		if err != nil {
			return err
		}
		if cmd == nil {
			panic(txnEntry)
		}
		cmdMgr.AddCmd(cmd)
	}
	if tbl.localSegment != nil {
		if err = tbl.localSegment.CollectCmd(cmdMgr); err != nil {
			return
		}
	}
	return
}

func (tbl *txnTable) GetSegment(id uint64) (seg handle.Segment, err error) {
	var meta *catalog.SegmentEntry
	if meta, err = tbl.entry.GetSegmentByID(id); err != nil {
		return
	}
	meta.RLock()
	if !meta.TxnCanRead(tbl.store.txn, meta.RWMutex) {
		err = txnbase.ErrNotFound
	}
	meta.RUnlock()
	seg = newSegment(tbl, meta)
	return
}

func (tbl *txnTable) SoftDeleteSegment(id uint64) (err error) {
	txnEntry, err := tbl.entry.DropSegmentEntry(id, tbl.store.txn)
	if err != nil {
		return
	}
	tbl.txnEntries = append(tbl.txnEntries, txnEntry)
	tbl.store.warChecker.ReadTable(tbl.entry.GetDB().ID, tbl.entry.AsCommonID())
	return
}

func (tbl *txnTable) CreateNonAppendableSegment() (seg handle.Segment, err error) {
	var meta *catalog.SegmentEntry
	var factory catalog.SegmentDataFactory
	if tbl.store.dataFactory != nil {
		factory = tbl.store.dataFactory.MakeSegmentFactory()
	}
	if meta, err = tbl.entry.CreateSegment(tbl.store.txn, catalog.ES_NotAppendable, factory); err != nil {
		return
	}
	seg = newSegment(tbl, meta)
	tbl.txnEntries = append(tbl.txnEntries, meta)
	tbl.store.warChecker.ReadTable(tbl.entry.GetDB().ID, meta.GetTable().AsCommonID())
	return
}

func (tbl *txnTable) CreateSegment() (seg handle.Segment, err error) {
	var meta *catalog.SegmentEntry
	var factory catalog.SegmentDataFactory
	if tbl.store.dataFactory != nil {
		factory = tbl.store.dataFactory.MakeSegmentFactory()
	}
	if meta, err = tbl.entry.CreateSegment(tbl.store.txn, catalog.ES_Appendable, factory); err != nil {
		return
	}
	seg = newSegment(tbl, meta)
	tbl.txnEntries = append(tbl.txnEntries, meta)
	tbl.store.warChecker.ReadTable(tbl.entry.GetDB().ID, meta.GetTable().AsCommonID())
	return
}

func (tbl *txnTable) SoftDeleteBlock(id *common.ID) (err error) {
	var seg *catalog.SegmentEntry
	if seg, err = tbl.entry.GetSegmentByID(id.SegmentID); err != nil {
		return
	}
	meta, err := seg.DropBlockEntry(id.BlockID, tbl.store.txn)
	if err != nil {
		return
	}
	tbl.txnEntries = append(tbl.txnEntries, meta)
	tbl.store.warChecker.ReadSegment(tbl.entry.GetDB().ID, seg.AsCommonID())
	return
}

func (tbl *txnTable) LogTxnEntry(entry txnif.TxnEntry, readed []*common.ID) (err error) {
	tbl.txnEntries = append(tbl.txnEntries, entry)
	for _, id := range readed {
		tbl.store.warChecker.Read(tbl.entry.GetDB().ID, id)
	}
	return
}

func (tbl *txnTable) GetBlock(id *common.ID) (blk handle.Block, err error) {
	var seg *catalog.SegmentEntry
	if seg, err = tbl.entry.GetSegmentByID(id.SegmentID); err != nil {
		return
	}
	meta, err := seg.GetBlockEntryByID(id.BlockID)
	if err != nil {
		return
	}
	blk = buildBlock(tbl, meta)
	return
}

func (tbl *txnTable) CreateNonAppendableBlock(sid uint64) (blk handle.Block, err error) {
	return tbl.createBlock(sid, catalog.ES_NotAppendable)
}

func (tbl *txnTable) CreateBlock(sid uint64) (blk handle.Block, err error) {
	return tbl.createBlock(sid, catalog.ES_Appendable)
}

func (tbl *txnTable) createBlock(sid uint64, state catalog.EntryState) (blk handle.Block, err error) {
	var seg *catalog.SegmentEntry
	if seg, err = tbl.entry.GetSegmentByID(sid); err != nil {
		return
	}
	if !seg.IsAppendable() && state == catalog.ES_Appendable {
		err = data.ErrNotAppendable
		return
	}
	var factory catalog.BlockDataFactory
	if tbl.store.dataFactory != nil {
		segData := seg.GetSegmentData()
		factory = tbl.store.dataFactory.MakeBlockFactory(segData.GetSegmentFile())
	}
	meta, err := seg.CreateBlock(tbl.store.txn, state, factory)
	if err != nil {
		return
	}
	tbl.txnEntries = append(tbl.txnEntries, meta)
	tbl.store.warChecker.ReadSegment(tbl.entry.GetDB().ID, seg.AsCommonID())
	return buildBlock(tbl, meta), err
}

func (tbl *txnTable) SetCreateEntry(e txnif.TxnEntry) {
	if tbl.createEntry != nil {
		panic("logic error")
	}
	tbl.createEntry = e
	tbl.txnEntries = append(tbl.txnEntries, e)
	tbl.store.warChecker.ReadDB(tbl.entry.GetDB().GetID())
}

func (tbl *txnTable) SetDropEntry(e txnif.TxnEntry) error {
	if tbl.dropEntry != nil {
		panic("logic error")
	}
	if tbl.createEntry != nil {
		return txnbase.ErrDDLDropCreated
	}
	tbl.dropEntry = e
	tbl.txnEntries = append(tbl.txnEntries, e)
	tbl.store.warChecker.ReadDB(tbl.entry.GetDB().GetID())
	return nil
}

func (tbl *txnTable) IsDeleted() bool {
	return tbl.dropEntry != nil
}

func (tbl *txnTable) GetSchema() *catalog.Schema {
	return tbl.entry.GetSchema()
}

func (tbl *txnTable) GetMeta() *catalog.TableEntry {
	return tbl.entry
}

func (tbl *txnTable) GetID() uint64 {
	return tbl.entry.GetID()
}

func (tbl *txnTable) Close() error {
	var err error
	if tbl.localSegment != nil {
		if err = tbl.localSegment.Close(); err != nil {
			return err
		}
		tbl.localSegment = nil
	}
	tbl.updateNodes = nil
	tbl.deleteNodes = nil
	tbl.logs = nil
	return nil
}

func (tbl *txnTable) AddDeleteNode(id *common.ID, node txnif.DeleteNode) error {
	nid := *id
	u := tbl.deleteNodes[nid]
	if u != nil {
		return ErrDuplicateNode
	}
	tbl.deleteNodes[nid] = node
	tbl.txnEntries = append(tbl.txnEntries, node)
	return nil
}

func (tbl *txnTable) AddUpdateNode(node txnif.UpdateNode) error {
	id := *node.GetID()
	u := tbl.updateNodes[id]
	if u != nil {
		return ErrDuplicateNode
	}
	tbl.updateNodes[id] = node
	tbl.txnEntries = append(tbl.txnEntries, node)
	return nil
}

func (tbl *txnTable) Append(data *batch.Batch) error {
	err := tbl.BatchDedup(data.Vecs[tbl.entry.GetSchema().PrimaryKey])
	if err != nil {
		return err
	}
	if tbl.localSegment == nil {
		tbl.localSegment = newLocalSegment(tbl)
	}
	return tbl.localSegment.Append(data)
}

func (tbl *txnTable) RangeDeleteLocalRows(start, end uint32) (err error) {
	if tbl.localSegment != nil {
		err = tbl.localSegment.RangeDelete(start, end)
	}
	return
}

func (tbl *txnTable) LocalDeletesToString() string {
	s := fmt.Sprintf("<txnTable-%d>[LocalDeletes]:\n", tbl.GetID())
	if tbl.localSegment != nil {
		s = fmt.Sprintf("%s%s", s, tbl.localSegment.DeletesToString())
	}
	return s
}

func (tbl *txnTable) IsLocalDeleted(row uint32) bool {
	if tbl.localSegment == nil {
		return false
	}
	return tbl.localSegment.IsDeleted(row)
}

func (tbl *txnTable) RangeDelete(id *common.ID, start, end uint32) (err error) {
	if isLocalSegment(id) {
		return tbl.RangeDeleteLocalRows(start, end)
	}
	node := tbl.deleteNodes[*id]
	if node != nil {
		chain := node.GetChain().(*updates.DeleteChain)
		controller := chain.GetController()
		writeLock := controller.GetExclusiveLock()
		err = controller.CheckNotDeleted(start, end, tbl.store.txn.GetStartTS())
		if err == nil {
			if err = controller.CheckNotUpdated(start, end, tbl.store.txn.GetStartTS()); err == nil {
				node.RangeDeleteLocked(start, end)
			}
		}
		writeLock.Unlock()
		if err != nil {
			seg, _ := tbl.entry.GetSegmentByID(id.SegmentID)
			blk, _ := seg.GetBlockEntryByID(id.BlockID)
			tbl.store.warChecker.ReadBlock(tbl.entry.GetDB().ID, blk.AsCommonID())
		}
		return
	}
	seg, err := tbl.entry.GetSegmentByID(id.SegmentID)
	if err != nil {
		return
	}
	blk, err := seg.GetBlockEntryByID(id.BlockID)
	if err != nil {
		return
	}
	blkData := blk.GetBlockData()
	node2, err := blkData.RangeDelete(tbl.store.txn, start, end)
	if err == nil {
		id := blk.AsCommonID()
		if err = tbl.AddDeleteNode(id, node2); err != nil {
			return
		}
		tbl.store.warChecker.ReadBlock(tbl.entry.GetDB().ID, id)
	}
	return
}

func (tbl *txnTable) GetByFilter(filter *handle.Filter) (id *common.ID, offset uint32, err error) {
	if tbl.localSegment != nil {
		id, offset, err = tbl.localSegment.GetByFilter(filter)
		if err == nil {
			return
		}
		err = nil
	}
	h := newRelation(tbl)
	blockIt := h.MakeBlockIt()
	for blockIt.Valid() {
		h := blockIt.GetBlock()
		if h.IsUncommitted() {
			blockIt.Next()
			continue
		}
		offset, err = h.GetByFilter(filter)
		// block := h.GetMeta().(*catalog.BlockEntry).GetBlockData()
		// offset, err = block.GetByFilter(tbl.store.txn, filter)
		if err == nil {
			id = h.Fingerprint()
			break
		}
		blockIt.Next()
	}
	return
}

func (tbl *txnTable) GetLocalValue(row uint32, col uint16) (v interface{}, err error) {
	if tbl.localSegment == nil {
		return
	}
	return tbl.localSegment.GetValue(row, col)
}

func (tbl *txnTable) GetValue(id *common.ID, row uint32, col uint16) (v interface{}, err error) {
	if isLocalSegment(id) {
		return tbl.localSegment.GetValue(row, col)
	}
	segMeta, err := tbl.entry.GetSegmentByID(id.SegmentID)
	if err != nil {
		panic(err)
	}
	meta, err := segMeta.GetBlockEntryByID(id.BlockID)
	if err != nil {
		panic(err)
	}
	block := meta.GetBlockData()
	return block.GetValue(tbl.store.txn, row, col)
}

func (tbl *txnTable) updateWithFineLock(node txnif.UpdateNode, txn txnif.AsyncTxn, row uint32, v interface{}) (err error) {
	chain := node.GetChain().(*updates.ColumnChain)
	controller := chain.GetController()
	sharedLock := controller.GetSharedLock()
	if err = controller.CheckNotDeleted(row, row, txn.GetStartTS()); err == nil {
		chain.Lock()
		err = chain.TryUpdateNodeLocked(row, v, node)
		chain.Unlock()
	}
	sharedLock.Unlock()
	return
}

func (tbl *txnTable) Update(id *common.ID, row uint32, col uint16, v interface{}) (err error) {
	if isLocalSegment(id) {
		return tbl.UpdateLocalValue(row, col, v)
	}
	uid := *id
	uid.Idx = col
	node := tbl.updateNodes[uid]
	if node != nil {
		err = tbl.updateWithFineLock(node, tbl.store.txn, row, v)
		if err != nil {
			seg, _ := tbl.entry.GetSegmentByID(id.SegmentID)
			blk, _ := seg.GetBlockEntryByID(id.BlockID)
			tbl.store.warChecker.ReadBlock(tbl.entry.GetDB().ID, blk.AsCommonID())
		}
		return
	}
	seg, err := tbl.entry.GetSegmentByID(id.SegmentID)
	if err != nil {
		return
	}
	blk, err := seg.GetBlockEntryByID(id.BlockID)
	if err != nil {
		return
	}
	blkData := blk.GetBlockData()
	node2, err := blkData.Update(tbl.store.txn, row, col, v)
	if err == nil {
		if err = tbl.AddUpdateNode(node2); err != nil {
			return
		}
		tbl.store.warChecker.ReadBlock(tbl.entry.GetDB().ID, blk.AsCommonID())
	}
	return
}

// 1. Get insert node and offset in node
// 2. Get row
// 3. Build a new row
// 4. Delete the row in the node
// 5. Append the new row
func (tbl *txnTable) UpdateLocalValue(row uint32, col uint16, value interface{}) (err error) {
	if tbl.localSegment != nil {
		err = tbl.localSegment.Update(row, col, value)
	}
	return
}

func (tbl *txnTable) UncommittedRows() uint32 {
	if tbl.localSegment == nil {
		return 0
	}
	return tbl.localSegment.Rows()
}

func (tbl *txnTable) PreCommitDededup() (err error) {
	if tbl.localSegment == nil {
		return
	}
	pks := tbl.localSegment.GetPrimaryColumn()
	segIt := tbl.entry.MakeSegmentIt(false)
	for segIt.Valid() {
		seg := segIt.Get().GetPayload().(*catalog.SegmentEntry)
		if seg.GetID() < tbl.maxSegId {
			return
		}
		{
			seg.RLock()
			uncreated := seg.IsCreatedUncommitted()
			dropped := seg.IsDroppedCommitted()
			seg.RUnlock()
			if uncreated || dropped {
				segIt.Next()
				continue
			}
		}
		segData := seg.GetSegmentData()
		// TODO: Add a new batch dedup method later
		if err = segData.BatchDedup(tbl.store.txn, pks); err == data.ErrDuplicate {
			return
		}
		if err == nil {
			segIt.Next()
			continue
		}
		err = nil
		blkIt := seg.MakeBlockIt(false)
		for blkIt.Valid() {
			blk := blkIt.Get().GetPayload().(*catalog.BlockEntry)
			if blk.GetID() < tbl.maxBlkId {
				return
			}
			{
				blk.RLock()
				uncreated := blk.IsCreatedUncommitted()
				dropped := blk.IsDroppedCommitted()
				blk.RUnlock()
				if uncreated || dropped {
					blkIt.Next()
					continue
				}
			}
			// logutil.Infof("%s: %d-%d, %d-%d: %s", tbl.txn.String(), tbl.maxSegId, tbl.maxBlkId, seg.GetID(), blk.GetID(), pks.String())
			blkData := blk.GetBlockData()
			// TODO: Add a new batch dedup method later
			if err = blkData.BatchDedup(tbl.store.txn, pks); err != nil {
				return
			}
			blkIt.Next()
		}
		segIt.Next()
	}
	return
}

func (tbl *txnTable) BatchDedup(pks *vector.Vector) (err error) {
	index := NewSimpleTableIndex()
	err = index.BatchInsert(pks, 0, vector.Length(pks), 0, true)
	if err != nil {
		return
	}
	// if tbl.localSegment != nil {
	// 	if err = tbl.localSegment.BatchDedupByCol(pks); err != nil {
	// 		return
	// 	}
	// }
	h := newRelation(tbl)
	segIt := h.MakeSegmentIt()
	for segIt.Valid() {
		seg := segIt.GetSegment()
		if err = seg.BatchDedup(pks); err == txnbase.ErrDuplicated {
			break
		}
		if err == data.ErrPossibleDuplicate {
			err = nil
			blkIt := seg.MakeBlockIt()
			for blkIt.Valid() {
				block := blkIt.GetBlock()
				if err = block.BatchDedup(pks); err != nil {
					break
				}
				blkIt.Next()
			}
		}
		if err != nil {
			break
		}
		segIt.Next()
	}
	segIt.Close()
	return
}

func (tbl *txnTable) BatchDedupLocal(bat *batch.Batch) (err error) {
	if tbl.localSegment != nil {
		err = tbl.localSegment.BatchDedupByCol(bat.Vecs[tbl.GetSchema().PrimaryKey])
	}
	return
}

func (tbl *txnTable) PrepareRollback() (err error) {
	for _, txnEntry := range tbl.txnEntries {
		if err = txnEntry.PrepareRollback(); err != nil {
			break
		}
	}
	return
}

func (tbl *txnTable) ApplyAppend() {
	if tbl.localSegment != nil {
		tbl.localSegment.ApplyAppend()
	}
}

func (tbl *txnTable) PreCommit() (err error) {
	if tbl.localSegment != nil {
		err = tbl.localSegment.PrepareApply()
	}
	return
}

func (tbl *txnTable) PrepareCommit() (err error) {
	for _, node := range tbl.txnEntries {
		if err = node.PrepareCommit(); err != nil {
			break
		}
	}
	return
}

func (tbl *txnTable) ApplyCommit() (err error) {
	csn := tbl.csnStart
	for _, node := range tbl.txnEntries {
		if err = node.ApplyCommit(tbl.store.cmdMgr.MakeLogIndex(csn)); err != nil {
			break
		}
		csn++
	}
	return
}

func (tbl *txnTable) ApplyRollback() (err error) {
	for _, node := range tbl.txnEntries {
		if err = node.ApplyRollback(); err != nil {
			break
		}
	}
	return
}
