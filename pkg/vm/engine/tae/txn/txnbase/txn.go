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

package txnbase

import (
	"fmt"
	"sync"

	"github.com/matrixorigin/matrixone/pkg/logutil"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/common"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/handle"
	"github.com/matrixorigin/matrixone/pkg/vm/engine/tae/iface/txnif"
)

type OpType int8

const (
	OpCommit = iota
	OpRollback
)

type OpTxn struct {
	Txn txnif.AsyncTxn
	Op  OpType
}

func (txn *OpTxn) Repr() string {
	if txn.Op == OpCommit {
		return fmt.Sprintf("[Commit][Txn-%d]", txn.Txn.GetID())
	} else {
		return fmt.Sprintf("[Rollback][Txn-%d]", txn.Txn.GetID())
	}
}

var DefaultTxnFactory = func(mgr *TxnManager, store txnif.TxnStore, id, startTS uint64, info []byte) txnif.AsyncTxn {
	return NewTxn(mgr, store, id, startTS, info)
}

type Txn struct {
	sync.RWMutex
	sync.WaitGroup
	*TxnCtx
	Mgr             *TxnManager
	Store           txnif.TxnStore
	Err             error
	DoneCond        sync.Cond
	PrepareCommitFn func(interface{}) error
}

func NewTxn(mgr *TxnManager, store txnif.TxnStore, txnId uint64, start uint64, info []byte) *Txn {
	txn := &Txn{
		Mgr:   mgr,
		Store: store,
	}
	txn.TxnCtx = NewTxnCtx(&txn.RWMutex, txnId, start, info)
	txn.DoneCond = *sync.NewCond(txn)
	return txn
}

func (txn *Txn) MockIncWriteCnt() int { return txn.Store.IncreateWriteCnt() }

func (txn *Txn) SetError(err error) { txn.Err = err }
func (txn *Txn) GetError() error    { return txn.Err }

func (txn *Txn) SetPrepareCommitFn(fn func(interface{}) error) { txn.PrepareCommitFn = fn }

func (txn *Txn) Commit() (err error) {
	if txn.Store.IsReadonly() {
		txn.Mgr.DeleteTxn(txn.GetID())
		return nil
	}
	txn.Add(1)
	err = txn.Mgr.OnOpTxn(&OpTxn{
		Txn: txn,
		Op:  OpCommit,
	})
	// TxnManager is closed
	if err != nil {
		txn.SetError(err)
		txn.Lock()
		_ = txn.ToRollbackingLocked(txn.GetStartTS() + 1)
		txn.Unlock()
		_ = txn.PrepareRollback()
		_ = txn.ApplyRollback()
		txn.Done()
	}
	txn.Wait()
	txn.Mgr.DeleteTxn(txn.GetID())
	return txn.GetError()
}

func (txn *Txn) GetStore() txnif.TxnStore {
	return txn.Store
}

func (txn *Txn) Rollback() (err error) {
	if txn.Store.IsReadonly() {
		txn.Mgr.DeleteTxn(txn.GetID())
		return
	}
	txn.Add(1)
	err = txn.Mgr.OnOpTxn(&OpTxn{
		Txn: txn,
		Op:  OpRollback,
	})
	if err != nil {
		_ = txn.PrepareRollback()
		_ = txn.ApplyRollback()
		txn.Done()
	}
	txn.Wait()
	txn.Mgr.DeleteTxn(txn.GetID())
	err = txn.Err
	return
}

func (txn *Txn) Done() {
	txn.DoneCond.L.Lock()
	if txn.State == txnif.TxnStateCommitting {
		if err := txn.ToCommittedLocked(); err != nil {
			txn.SetError(err)
		}
	} else {
		if err := txn.ToRollbackedLocked(); err != nil {
			txn.SetError(err)
		}
	}
	txn.WaitGroup.Done()
	txn.DoneCond.Broadcast()
	txn.DoneCond.L.Unlock()
}

func (txn *Txn) IsTerminated(waitIfcommitting bool) bool {
	state := txn.GetTxnState(waitIfcommitting)
	return state == txnif.TxnStateCommitted || state == txnif.TxnStateRollbacked
}

func (txn *Txn) GetTxnState(waitIfcommitting bool) txnif.TxnState {
	txn.RLock()
	state := txn.State
	if !waitIfcommitting {
		txn.RUnlock()
		return state
	}
	if state != txnif.TxnStateCommitting {
		txn.RUnlock()
		return state
	}
	txn.RUnlock()
	txn.DoneCond.L.Lock()
	state = txn.State
	if state != txnif.TxnStateCommitting {
		txn.DoneCond.L.Unlock()
		return state
	}
	txn.DoneCond.Wait()
	txn.DoneCond.L.Unlock()
	return state
}

func (txn *Txn) PrepareCommit() error {
	logutil.Debugf("Prepare Committing %d", txn.ID)
	var err error
	if txn.PrepareCommitFn != nil {
		err = txn.PrepareCommitFn(txn)
	}
	if err != nil {
		return err
	}
	// TODO: process data in store
	err = txn.Store.PrepareCommit()
	return err
}

func (txn *Txn) ApplyCommit() (err error) {
	defer func() {
		if err == nil {
			err = txn.Store.Close()
		} else {
			txn.Store.Close()
		}
	}()
	err = txn.Store.ApplyCommit()
	return
}

func (txn *Txn) ApplyRollback() (err error) {
	defer func() {
		if err == nil {
			err = txn.Store.Close()
		} else {
			txn.Store.Close()
		}
	}()
	err = txn.Store.ApplyRollback()
	return
}

func (txn *Txn) PreCommit() error {
	return txn.Store.PreCommit()
}

func (txn *Txn) PrepareRollback() error {
	logutil.Debugf("Prepare Rollbacking %d", txn.ID)
	return txn.Store.PrepareRollback()
}

func (txn *Txn) String() string {
	str := txn.TxnCtx.String()
	return fmt.Sprintf("%s: %v", str, txn.GetError())
}

func (txn *Txn) WaitDone() error {
	// logutil.Infof("Wait %s Done", txn.String())
	txn.Done()
	return txn.Err
}

func (txn *Txn) CreateDatabase(name string) (db handle.Database, err error) {
	return
}

func (txn *Txn) DropDatabase(name string) (db handle.Database, err error) {
	return
}

func (txn *Txn) GetDatabase(name string) (db handle.Database, err error) {
	return
}

func (txn *Txn) UseDatabase(name string) (err error) {
	return
}

func (txn *Txn) CurrentDatabase() (db handle.Database) {
	return
}

func (txn *Txn) DatabaseNames() (names []string) {
	return
}

func (txn *Txn) LogTxnEntry(dbId, tableId uint64, entry txnif.TxnEntry, readed []*common.ID) (err error) {
	return
}
