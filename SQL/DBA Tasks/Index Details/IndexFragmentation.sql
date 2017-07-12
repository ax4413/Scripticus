-- ===  sys.dm_db_index_physical_stats  https://msdn.microsoft.com/en-us/library/ms188917.aspx
-- ===  sys.indexes                     https://msdn.microsoft.com/en-us/library/ms173760.aspx

DECLARE @DatabaseID int, @PageCount int

SET @DatabaseID = DB_ID()
SET @PageCount = 1000

SELECT  [DatabaseName]              = DB_NAME(@DatabaseID),
        [SchemaName]                = schemas.[name],
        [ObjectName]                = obj.[name],
        [IndexName]                 = ix.[name],
        [ObjectType]                = obj.type_desc,
        [IndexType]                 = ix.type_desc,
        [PartitionNumber]           = ix_stats.partition_number,
        [PageCount]                 = ix_stats.page_count,
        [AvgFragmentationInPercent] = ix_stats.avg_fragmentation_in_percent,
        [FragmentCount]             = ix_stats.fragment_count,                --  Number of fragments in the leaf level of an IN_ROW_DATA allocation unit.
        [AllocationUnitType]        = ix_stats.alloc_unit_type_desc,          --  Description of the allocation unit type
        [IndexDepth]                = ix_stats.index_depth                    --  Number of index levels.
FROM    sys.dm_db_index_physical_stats (@DatabaseID, NULL, NULL, NULL, 'LIMITED') ix_stats
        INNER JOIN sys.indexes ix
                ON ix_stats.[object_id] = ix.[object_id]
                AND ix_stats.index_id = ix.index_id
        INNER JOIN sys.objects obj
                ON ix.[object_id] = obj.[object_id]
        INNER JOIN sys.schemas schemas
                ON obj.[schema_id] = schemas.[schema_id]
WHERE   obj.[type] IN('U','V')
        AND obj.is_ms_shipped = 0
        AND ix.[type] IN(1,2,3,4) -- exclude heap tables and 2014 column store and in memory indexes
        AND ix.is_disabled = 0
        AND ix.is_hypothetical = 0
        AND ix_stats.alloc_unit_type_desc = 'IN_ROW_DATA'
        AND ix_stats.index_level = 0
        AND ix_stats.page_count >= @PageCount
ORDER BY obj.[name], ix.[name]




-- Get index fragmentation info for this DB with index name
SELECT  DB_NAME(ps.database_id) DatabaseName
      , OBJECT_NAME(ps.OBJECT_ID) TableName
      , i.name IndexName
      , ps.index_id
      , ps.avg_fragmentation_in_percent
FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ps
        INNER JOIN sys.indexes AS i
                ON ps.OBJECT_ID = i.OBJECT_ID AND ps.index_id = i.index_id
WHERE   ps.database_id = DB_ID()
ORDER BY DB_NAME(ps.database_id), OBJECT_NAME(ps.OBJECT_ID), i.name
GO





-- ===  The mode options are as follows: DEFAULT, NULL, LIMITED, SAMPLED, or DETAILED. The default (NULL) is LIMITED.

SELECT  [DatabaseName]  = DB_NAME(ix_stats.database_id),
        [TableName]     = OBJECT_NAME(ix_stats.object_id),
        [IndexName]     = ix.name,
        ix_stats.*
FROM    sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N'dbo.Address'), NULL, NULL , 'DETAILED') ix_stats
        INNER JOIN sys.indexes ix
                ON ix_stats.[object_id] = ix.[object_id]
                AND ix_stats.index_id = ix.index_id
