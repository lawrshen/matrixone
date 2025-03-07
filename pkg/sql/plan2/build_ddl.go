// Copyright 2021 - 2022 Matrix Origin
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

package plan2

import (
	"fmt"

	"github.com/matrixorigin/matrixone/pkg/errno"
	"github.com/matrixorigin/matrixone/pkg/pb/plan"
	"github.com/matrixorigin/matrixone/pkg/sql/errors"
	"github.com/matrixorigin/matrixone/pkg/sql/parsers/dialect"
	"github.com/matrixorigin/matrixone/pkg/sql/parsers/tree"
)

func buildCreateTable(stmt *tree.CreateTable, ctx CompilerContext) (*Plan, error) {
	createTable := &plan.CreateTable{
		IfNotExists: stmt.IfNotExists,
		Temporary:   stmt.Temporary,
		TableDef: &TableDef{
			Name: string(stmt.Table.ObjectName),
		},
	}

	// get database name
	if len(stmt.Table.SchemaName) == 0 {
		createTable.Database = ctx.DefaultDatabase()
	} else {
		createTable.Database = string(stmt.Table.SchemaName)
	}

	// get table name
	if !stmt.IfNotExists {
		_, def := ctx.Resolve(createTable.Database, createTable.TableDef.Name)
		if def != nil {
			return nil, errors.New(errno.InvalidTableDefinition, fmt.Sprintf("table '%v' exist", createTable.TableDef.Name))
		}
	}

	// set tableDef
	err := buildTableDefs(stmt.Defs, ctx, createTable.TableDef)
	if err != nil {
		return nil, err
	}

	// set option
	for _, option := range stmt.Options {
		switch opt := option.(type) {
		case *tree.TableOptionProperties:
			properties := make([]*plan.Property, len(opt.Preperties))
			for idx, property := range opt.Preperties {
				properties[idx] = &plan.Property{
					Key:   property.Key,
					Value: property.Value,
				}
			}
			createTable.TableDef.Defs = append(createTable.TableDef.Defs, &plan.TableDef_DefType{
				Def: &plan.TableDef_DefType_Properties{
					Properties: &plan.PropertiesDef{
						Properties: properties,
					},
				},
			})
		// todo confirm: option data store like this?
		case *tree.TableOptionComment:
			properties := []*plan.Property{
				{
					Key:   "Comment",
					Value: opt.Comment,
				},
			}
			createTable.TableDef.Defs = append(createTable.TableDef.Defs, &plan.TableDef_DefType{
				Def: &plan.TableDef_DefType_Properties{
					Properties: &plan.PropertiesDef{
						Properties: properties,
					},
				},
			})
		// these table options is not support in plan
		// case *tree.TableOptionEngine, *tree.TableOptionSecondaryEngine, *tree.TableOptionCharset,
		// 	*tree.TableOptionCollate, *tree.TableOptionAutoIncrement, *tree.TableOptionComment,
		// 	*tree.TableOptionAvgRowLength, *tree.TableOptionChecksum, *tree.TableOptionCompression,
		// 	*tree.TableOptionConnection, *tree.TableOptionPassword, *tree.TableOptionKeyBlockSize,
		// 	*tree.TableOptionMaxRows, *tree.TableOptionMinRows, *tree.TableOptionDelayKeyWrite,
		// 	*tree.TableOptionRowFormat, *tree.TableOptionStatsPersistent, *tree.TableOptionStatsAutoRecalc,
		// 	*tree.TableOptionPackKeys, *tree.TableOptionTablespace, *tree.TableOptionDataDirectory,
		// 	*tree.TableOptionIndexDirectory, *tree.TableOptionStorageMedia, *tree.TableOptionStatsSamplePages,
		// 	*tree.TableOptionUnion, *tree.TableOptionEncryption:
		// 	return nil, errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("unexpected statement: '%v'", tree.String(stmt, dialect.MYSQL)))
		default:
			return nil, errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("unexpected options; statement: '%v'", tree.String(stmt, dialect.MYSQL)))
		}
	}

	// set partition(unsupport now)
	if stmt.PartitionOption != nil {
		return nil, errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("partition unsupport now; statement: '%v'", tree.String(stmt, dialect.MYSQL)))
	}

	return &Plan{
		Plan: &plan.Plan_Ddl{
			Ddl: &plan.DataDefinition{
				DdlType: plan.DataDefinition_CREATE_TABLE,
				Definition: &plan.DataDefinition_CreateTable{
					CreateTable: createTable,
				},
			},
		},
	}, nil
}

func buildTableDefs(defs tree.TableDefs, ctx CompilerContext, tableDef *TableDef) error {
	var primaryKeys []string
	for _, item := range defs {
		switch def := item.(type) {
		case *tree.ColumnTableDef:
			colType, err := getTypeFromAst(def.Type)
			if err != nil {
				return err
			}
			defultValue, err := getDefaultExprFromColumn(def, colType)
			if err != nil {
				return err
			}
			col := &ColDef{
				Name:    def.Name.Parts[0],
				Alg:     plan.CompressType_Lz4,
				Typ:     colType,
				Default: defultValue,
			}
			tableDef.Cols = append(tableDef.Cols, col)

			var pks []string
			for _, attr := range def.Attributes {
				if _, ok := attr.(*tree.AttributePrimaryKey); ok {
					pks = append(pks, def.Name.Parts[0])
				}
			}
			if len(pks) > 0 {
				if len(primaryKeys) > 0 {
					return errors.New(errno.SyntaxErrororAccessRuleViolation, "Multiple primary key defined")
				}
				primaryKeys = pks
			}
		case *tree.PrimaryKeyIndex:
			if len(primaryKeys) > 0 {
				return errors.New(errno.SyntaxErrororAccessRuleViolation, "Multiple primary key defined")
			}
			pksMap := map[string]bool{}
			for _, key := range def.KeyParts {
				name := key.ColName.Parts[0] // name of primary key column
				if _, ok := pksMap[name]; ok {
					return errors.New(errno.InvalidTableDefinition, fmt.Sprintf("Duplicate column name '%s'", name))
				}
				primaryKeys = append(primaryKeys, name)
				pksMap[name] = true
			}
		case *tree.Index:
			var idxType plan.IndexDef_IndexType
			switch def.KeyType {
			case tree.INDEX_TYPE_BSI:
				idxType = plan.IndexDef_BSI
			case tree.INDEX_TYPE_ZONEMAP:
				idxType = plan.IndexDef_ZONEMAP
			default:
				idxType = plan.IndexDef_ZONEMAP //default
				// return errors.New(errno.InvalidTableDefinition, fmt.Sprintf("Invaild index type '%s'", def.KeyType.ToString()))
			}

			idxDef := &plan.IndexDef{
				Typ:      idxType,
				Name:     def.Name,
				ColNames: make([]string, len(def.KeyParts)),
			}

			nameMap := map[string]bool{}
			for i, key := range def.KeyParts {
				name := key.ColName.Parts[0] // name of index column

				if _, ok := nameMap[name]; ok {
					return errors.New(errno.InvalidTableDefinition, fmt.Sprintf("Duplicate column name '%s'", key.ColName.Parts[0]))
				}
				idxDef.ColNames[i] = name
				nameMap[name] = true
			}

			tableDef.Defs = append(tableDef.Defs, &plan.TableDef_DefType{
				Def: &plan.TableDef_DefType_Idx{
					Idx: idxDef,
				},
			})
		case *tree.UniqueIndex, *tree.CheckIndex, *tree.ForeignKey, *tree.FullTextIndex:
			// unsupport in plan. will support in next version.
			return errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("unsupport table def: '%v'", def))
		default:
			return errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("unsupport table def: '%v'", def))
		}
	}

	if len(primaryKeys) > 0 {
		tableDef.Defs = append(tableDef.Defs, &plan.TableDef_DefType{
			Def: &plan.TableDef_DefType_Pk{
				Pk: &plan.PrimaryKeyDef{
					Names: primaryKeys,
				},
			},
		})
	}
	return nil
}

func buildDropTable(stmt *tree.DropTable, ctx CompilerContext) (*Plan, error) {
	dropTable := &plan.DropTable{
		IfExists: stmt.IfExists,
	}
	if len(stmt.Names) != 1 {
		return nil, errors.New(errno.SyntaxErrororAccessRuleViolation, "support drop one table now")
	}
	dropTable.Database = string(stmt.Names[0].SchemaName)
	if dropTable.Database == "" {
		dropTable.Database = ctx.DefaultDatabase()
	}
	dropTable.Table = string(stmt.Names[0].ObjectName)
	if !stmt.IfExists {
		if !ctx.DatabaseExists(dropTable.Database) {
			return nil, errors.New(errno.InvalidSchemaName, fmt.Sprintf("database '%v' doesn't exist", dropTable.Database))
		}
		_, tableDef := ctx.Resolve(dropTable.Database, dropTable.Table)
		if tableDef == nil {
			return nil, errors.New(errno.UndefinedTable, fmt.Sprintf("table '%v' doesn't exist", dropTable.Table))
		}
	}

	return &Plan{
		Plan: &plan.Plan_Ddl{
			Ddl: &plan.DataDefinition{
				DdlType: plan.DataDefinition_DROP_TABLE,
				Definition: &plan.DataDefinition_DropTable{
					DropTable: dropTable,
				},
			},
		},
	}, nil
}

func buildCreateDatabase(stmt *tree.CreateDatabase, ctx CompilerContext) (*Plan, error) {
	createDb := &plan.CreateDatabase{
		IfNotExists: stmt.IfNotExists,
		Database:    string(stmt.Name),
	}
	if !stmt.IfNotExists {
		if ctx.DatabaseExists(createDb.Database) {
			return nil, errors.New(errno.InvalidSchemaName, fmt.Sprintf("database '%v' exist", createDb.Database))
		}
	}

	return &Plan{
		Plan: &plan.Plan_Ddl{
			Ddl: &plan.DataDefinition{
				DdlType: plan.DataDefinition_CREATE_DATABASE,
				Definition: &plan.DataDefinition_CreateDatabase{
					CreateDatabase: createDb,
				},
			},
		},
	}, nil
}

func buildDropDatabase(stmt *tree.DropDatabase, ctx CompilerContext) (*Plan, error) {
	dropDb := &plan.DropDatabase{
		IfExists: stmt.IfExists,
		Database: string(stmt.Name),
	}

	if !stmt.IfExists {
		if !ctx.DatabaseExists(dropDb.Database) {
			return nil, errors.New(errno.InvalidSchemaName, fmt.Sprintf("database '%v' doesn't exist", dropDb.Database))
		}
	}

	return &Plan{
		Plan: &plan.Plan_Ddl{
			Ddl: &plan.DataDefinition{
				DdlType: plan.DataDefinition_DROP_DATABASE,
				Definition: &plan.DataDefinition_DropDatabase{
					DropDatabase: dropDb,
				},
			},
		},
	}, nil
}

func buildCreateIndex(stmt *tree.CreateIndex, ctx CompilerContext) (*Plan, error) {
	return nil, errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("unexpected statement: '%v'", tree.String(stmt, dialect.MYSQL)))
	// todo unsupport now
	// createIndex := &plan.CreateIndex{}
	// return &Plan{
	// 	Plan: &plan.Plan_Ddl{
	// 		Ddl: &plan.DataDefinition{
	// 			DdlType: plan.DataDefinition_CREATE_INDEX,
	// 			Definition: &plan.DataDefinition_CreateIndex{
	// 				CreateIndex: createIndex,
	// 			},
	// 		},
	// 	},
	// }, nil
}

func buildDropIndex(stmt *tree.DropIndex, ctx CompilerContext) (*Plan, error) {
	return nil, errors.New(errno.SQLStatementNotYetComplete, fmt.Sprintf("unexpected statement: '%v'", tree.String(stmt, dialect.MYSQL)))
	// todo unsupport now
	// dropIndex := &plan.DropIndex{
	// 	IfExists: stmt.IfExists,
	// 	Index:    string(stmt.Name),
	// }
	// return &Plan{
	// 	Plan: &plan.Plan_Ddl{
	// 		Ddl: &plan.DataDefinition{
	// 			DdlType: plan.DataDefinition_DROP_INDEX,
	// 			Definition: &plan.DataDefinition_DropIndex{
	// 				DropIndex: dropIndex,
	// 			},
	// 		},
	// 	},
	// }, nil
}
