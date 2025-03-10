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

package txnif

import (
	"io"
	"sync"

	"github.com/matrixorigin/matrixone/pkg/container/batch"
	"github.com/matrixorigin/matrixone/pkg/container/vector"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/common"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/handle"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/wal"
)

type TxnClient interface {
	StartTxn(info []byte) (AsyncTxn, error)
}

type Txn2PC interface {
	PreCommit() error
	PrepareRollback() error
	PrepareCommit() error
	ApplyRollback() error
	ApplyCommit() error
}

type TxnReader interface {
	RLock()
	RUnlock()
	GetID() uint64
	GetCtx() []byte
	GetStartTS() uint64
	GetCommitTS() uint64
	GetInfo() []byte
	IsTerminated(bool) bool
	IsVisible(o TxnReader) bool
	GetTxnState(waitIfcommitting bool) TxnState
	GetError() error
	GetStore() TxnStore
	String() string
	Repr() string
}

type TxnHandle interface {
	CreateDatabase(name string) (handle.Database, error)
	DropDatabase(name string) (handle.Database, error)
	GetDatabase(name string) (handle.Database, error)
	DatabaseNames() []string
}

type TxnChanger interface {
	sync.Locker
	RLock()
	RUnlock()
	ToCommittedLocked() error
	ToCommittingLocked(ts uint64) error
	ToRollbackedLocked() error
	ToRollbackingLocked(ts uint64) error
	Commit() error
	Rollback() error
	SetError(error)
	SetPrepareCommitFn(func(interface{}) error)
}

type TxnWriter interface {
	LogTxnEntry(dbId, tableId uint64, entry TxnEntry, readed []*common.ID) error
}

type TxnAsyncer interface {
	WaitDone() error
}

type TxnTest interface {
	MockSetCommitTSLocked(ts uint64)
	MockIncWriteCnt() int
}

type AsyncTxn interface {
	TxnTest
	Txn2PC
	TxnHandle
	TxnAsyncer
	TxnReader
	TxnWriter
	TxnChanger
}

type SyncTxn interface {
	TxnReader
	TxnWriter
	TxnChanger
}

type UpdateChain interface {
	sync.Locker
	RLock()
	RUnlock()
	GetID() *common.ID

	DeleteNode(*common.DLNode)
	DeleteNodeLocked(*common.DLNode)

	AddNode(txn AsyncTxn) UpdateNode
	AddNodeLocked(txn AsyncTxn) UpdateNode
	PrepareUpdate(uint32, UpdateNode) error

	GetValueLocked(row uint32, ts uint64) (interface{}, error)
	TryUpdateNodeLocked(row uint32, v interface{}, n UpdateNode) error
	// CheckDeletedLocked(start, end uint32, txn AsyncTxn) error
	// CheckColumnUpdatedLocked(row uint32, colIdx uint16, txn AsyncTxn) error
}

type DeleteChain interface {
	sync.Locker
	RLock()
	RUnlock()
	// GetID() *common.ID
	RemoveNodeLocked(DeleteNode)

	AddNodeLocked(txn AsyncTxn) DeleteNode
	AddMergeNode() DeleteNode

	PrepareRangeDelete(start, end uint32, ts uint64) error
	DepthLocked() int
	CollectDeletesLocked(ts uint64, collectIndex bool) DeleteNode
}

type AppendNode interface {
	TxnEntry
}

type DeleteNode interface {
	TxnEntry
	StringLocked() string
	GetChain() DeleteChain
	RangeDeleteLocked(start, end uint32)
	GetCardinalityLocked() uint32
}

type UpdateNode interface {
	TxnEntry
	GetID() *common.ID
	String() string
	GetChain() UpdateChain
	GetDLNode() *common.DLNode

	UpdateLocked(row uint32, v interface{}) error
}

type TxnStore interface {
	Txn2PC
	io.Closer
	BindTxn(AsyncTxn)

	BatchDedup(dbId, id uint64, pks *vector.Vector) error
	LogSegmentID(dbId, tid, sid uint64)
	LogBlockID(dbId, tid, bid uint64)

	Append(dbId, id uint64, data *batch.Batch) error

	RangeDelete(dbId uint64, id *common.ID, start, end uint32) error
	Update(dbId uint64, id *common.ID, row uint32, col uint16, v interface{}) error
	GetByFilter(dbId uint64, id uint64, filter *handle.Filter) (*common.ID, uint32, error)
	GetValue(dbId uint64, id *common.ID, row uint32, col uint16) (interface{}, error)

	CreateRelation(dbId uint64, def interface{}) (handle.Relation, error)
	DropRelationByName(dbId uint64, name string) (handle.Relation, error)
	GetRelationByName(dbId uint64, name string) (handle.Relation, error)

	CreateDatabase(name string) (handle.Database, error)
	GetDatabase(name string) (handle.Database, error)
	DropDatabase(name string) (handle.Database, error)
	DatabaseNames() []string

	GetSegment(dbId uint64, id *common.ID) (handle.Segment, error)
	CreateSegment(dbId, tid uint64) (handle.Segment, error)
	CreateNonAppendableSegment(dbId, tid uint64) (handle.Segment, error)
	CreateBlock(dbId, tid, sid uint64) (handle.Block, error)
	GetBlock(dbId uint64, id *common.ID) (handle.Block, error)
	CreateNonAppendableBlock(dbId uint64, id *common.ID) (handle.Block, error)
	SoftDeleteSegment(dbId uint64, id *common.ID) error
	SoftDeleteBlock(dbId uint64, id *common.ID) error

	AddTxnEntry(TxnEntryType, TxnEntry)

	LogTxnEntry(dbId, tableId uint64, entry TxnEntry, readed []*common.ID) error

	IsReadonly() bool
	IncreateWriteCnt() int
}

type TxnEntryType int16

type TxnEntry interface {
	sync.Locker
	RLock()
	RUnlock()
	PrepareCommit() error
	PrepareRollback() error
	ApplyCommit(index *wal.Index) error
	ApplyRollback() error
	MakeCommand(uint32) (TxnCmd, error)
}
