-- ===  http://sqlmonitormetrics.red-gate.com/possible-duplicate-indexes/
-- ===  When a table has multiple indexes defined on the same columns, it produces duplicate 
-- ===  indexes that waste space and have a negative impact on performance. This metric measures 
-- ===  the number of possible duplicate indexes per database. Use it if you want to monitor when 
-- ===  a duplicate index is created or to find whether there is a duplicated index in your database.

-- ===  Note: Be very careful before dropping an index. Check that the index is really not used 
-- ===  (sys.dm_db_index_usage_stats can help with this), and that applications are not using the 
-- ===  index on hints. Even if there is a duplicate based on the key columns, there are occasionally 
-- ===  valid reasons for having a duplicate, for example, a clustered index and a non-clustered index 
-- ===  can use the same key columns.

-- Exactly duplicated indexes
WITH  IndexCols AS (
    SELECT  Id      = object_id,
            IndId   = index_id,
            Name    = name,
            Cols    = ( SELECT  CASE keyno WHEN 0 THEN NULL ELSE colid END AS [data()]
                        FROM    sys.sysindexkeys AS k
                        WHERE   k.id = i.object_id
                                AND k.indid = i.index_id
                        ORDER BY keyno, colid
                        FOR XML PATH('') ),
            Inc     = ( SELECT  CASE keyno WHEN 0 THEN colid ELSE NULL END AS [data()]
                        FROM    sys.sysindexkeys AS k
                        WHERE   k.id = i.object_id
                                AND k.indid = i.index_id
                        ORDER BY colid
                        FOR XML PATH('') )
    FROM sys.indexes AS i
)
--SELECT *, OBJECT_SCHEMA_NAME(Id) + '.' + OBJECT_NAME(Id) FROM IndexCols ORDER BY Id, Name/*

SELECT  [DbName]        = DB_NAME(),
        [TableName]     = OBJECT_SCHEMA_NAME(c1.Id) + '.' + OBJECT_NAME(c1.Id),
        [IndexName]     = c1.Name + CASE c1.IndId
                                        WHEN 1 THEN ' (clustered index)'
                                        ELSE ' (nonclustered index)' END,
        [DupIndexName] = c2.name + CASE c2.indid
                                        WHEN 1 THEN ' (clustered index)'
                                        ELSE ' (nonclustered index)' END
FROM    IndexCols AS c1
        INNER JOIN IndexCols AS c2
                ON c1.Id = c2.Id
                    AND c1.IndId < c2.IndId
                    AND c1.Cols = c2.Cols
                    AND c1.Inc = c2.Inc
ORDER BY OBJECT_SCHEMA_NAME(c1.Id) + '.' + OBJECT_NAME(c1.Id), c1.Name, c2.name
--*/