IF (SELECT OBJECT_ID('tempdb..#IndexDetails')) IS NOT NULL
  DROP TABLE #IndexDetails ;
GO

-- ==== Identify Foriegn Keys without a index
WITH
  ForiegnKey AS (
    SELECT  fk.name, fk.object_id,
            bt.name BaseTableName, bc.name BaseTableColumnName,
            rt.name RefTableName, rc.name RefTableColumnName,
            bt.object_id BaseTableId, bc.column_id BaseTableColumnId,
            rt.object_id RefTableId, rc.column_id RefTableColumnId,
            fk.key_index_id
    FROM    sys.foreign_keys fk
            INNER JOIN sys.foreign_key_columns fkc
                    ON fkc.constraint_object_id = fk.object_id
            INNER JOIN sys.tables bt
                    ON bt.object_id = fk.parent_object_id
            INNER JOIN sys.columns bc
                    ON bc.object_id = fkc.parent_object_id
                    AND bc.column_id = fkc.parent_column_id
            INNER JOIN sys.tables rt
                    ON rt.object_id = fk.referenced_object_id
            INNER JOIN sys.columns rc
                    ON rc.object_id = fkc.referenced_object_id
                    AND rc.column_id = fkc.referenced_column_id
)
--SELECT * FROM ForiegnKey ORDER BY BaseTableName, BaseTableColumnName, RefTableName, RefTableColumnName, key_index_id /*

, IndexKey AS(
    SELECT  t.name TableName,
            t.object_id table_id,
            c.name ColumnName,
            c.column_id ,
            ixc.is_descending_key,
            ixc.is_included_column,
            CASE WHEN ix.filter_definition IS NOT NULL THEN 1 ELSE 0 END Is_Filter_Index,
            ix.name,
            ix.index_id,
            ixc.index_column_id,
            MAX(index_column_id) OVER (PARTITION BY ix.name) Columns_in_index
    FROM    sys.indexes ix
            INNER JOIN sys.index_columns ixc
                    ON ixc.object_id = ix.object_id
                    AND ix.index_id = ixc.index_id
            INNER JOIN sys.tables t
                    ON t.object_id = ix.object_id
            INNER JOIN sys.columns c
                    ON c.object_id = ix.object_id
                    AND c.column_id = ixc.column_id
    WHERE   IXC.is_included_column = 0
)
--SELECT * FROM IndexKey ORDER BY TableName, index_id, index_column_id /*


-- ===  Show Foriegn keys that do not have a backing index containing that sole column, also indicate those that do have covering index that contains more than 1 column
SELECT  [TableName]             = COALESCE(fk.BaseTableName, ix.TableName),
        [ColumnName]            = COALESCE(fk.BaseTableColumnName, ix.ColumnName),
        [IndexPresent]          = CASE WHEN fk.BaseTableName IS NULL OR ix.TableName IS NULL THEN 0 ELSE 1 END,
        [CoveringIndexPresent] = CASE WHEN fk.BaseTableName IS NOT NULL AND covix.TableName IS NOT NULL THEN 1 ELSE 0 END,
        [IndexCoverage]         = CAST((CAST(SUM(CASE WHEN fk.BaseTableName IS NULL OR ix.TableName IS NULL THEN 0 ELSE 1 END) OVER(PARTITION BY NULL) AS DECIMAL(18,4)) /
                                        CAST(SUM(1) OVER(PARTITION BY NULL) AS DECIMAL(18,4))) *
                                        100.00 AS DECIMAL(18,4))
FROM    ForiegnKey fk
        LEFT OUTER JOIN (
                        SELECT  table_id, column_id, TableName, ColumnName
                        FROM    IndexKey
                        WHERE   Is_Filter_Index = 0
                                AND Columns_in_index = 1
                    )ix
                ON ix.table_id = fk.BaseTableId
                AND ix.column_id = fk.BaseTableColumnId
        LEFT OUTER JOIN (--covering index
                        SELECT  DISTINCT table_id, column_id, TableName, ColumnName
                        FROM    IndexKey
                        WHERE   Is_Filter_Index = 0
                                AND Columns_in_index > 1
                    )covix
                ON covix.table_id = fk.BaseTableId
                AND covix.column_id = fk.BaseTableColumnId
ORDER BY 1,2