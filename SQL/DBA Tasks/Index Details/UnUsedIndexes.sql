-- ===  http://www.mssqltips.com/sqlservertip/3492/script-to-find-unused-sql-server-indexes/
-- ===  Get all indexes for tables with more that 10,000 records (adjust as needed)
-- ===  Un used indexes are those where the Reades per writes are aproximatley zero

SELECT  [TableName]       = o.name,
        [IndexName]       = i.name,
        [NumOfReads]      = user_seeks + user_scans + user_lookups,
        [NumOfWrites]     = user_updates,
        [PrimaryKey]      = i.is_primary_key,
        [TableRows]       = ( SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id ),
        [ReadsPerWrites]  = CASE WHEN s.user_updates < 1 THEN 100
                                 ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) / s.user_updates
                            END,
        [DropStatement]   = 'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(c.name) + '.' + QUOTENAME(OBJECT_NAME(s.object_id))
FROM    sys.dm_db_index_usage_stats s
        INNER JOIN sys.indexes i
                ON i.index_id = s.index_id AND s.object_id = i.object_id
        INNER JOIN sys.objects o
                ON s.object_id = o.object_id
        INNER JOIN sys.schemas c
                ON o.schema_id = c.schema_id
WHERE   OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
        AND s.database_id = DB_ID()
        AND i.type_desc = 'nonclustered'
        AND i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND ( SELECT SUM(p.rows)
              FROM sys.partitions p
              WHERE p.index_id = s.index_id AND s.object_id = p.object_id) > 10000 -- rows in table
ORDER BY NumOfReads