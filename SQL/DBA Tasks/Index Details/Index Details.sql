-- ===  Get some ide of how our indexes are being stored on diska nd in memory =====================

SELECT  OBJECT_NAME ([si].[object_id])        AS [Table Name]
      , [si].[name]                           AS [Index Name]
      , [ps].[index_id]                       AS [Index ID]
      , [ps].[index_depth]                    AS [Depth]
      , [ps].[index_level]                    AS [Level]
      , [ps].[alloc_unit_type_desc]           AS [Data Structure]
      , [ps].[record_count]                   AS [Rows]
      , [ps].[page_count]                     AS [Pages]
      , [ps].[avg_page_space_used_in_percent] AS [Page % Full]
      , [ps].[min_record_size_in_bytes]       AS [Min Row / Bytes]
      , [ps].[max_record_size_in_bytes]       AS [Max Row / Bytes]
      , [ps].[avg_record_size_in_bytes]       AS [Avg Row / Bytes]
FROM    [sys].[indexes] AS [si]
        CROSS APPLY sys.dm_db_index_physical_stats (
            DB_ID ()
          , [si].[object_id]
          , NULL
          , NULL
          , N'DETAILED' ) AS [ps]
WHERE   [si].[object_id] = [ps].[object_id]
  AND   [si].[index_id] = [ps].[index_id]
  AND   [si].[object_id] IN ( OBJECT_ID (N'Application') )
  --AND   [ps].[index_level] = 0  -- Leaf
ORDER BY [Table Name]
      , [Index ID]
      , [Level]
;
GO


-- ===  Get teh latest version of sp_SQLskills_SQL2012_helpindex ===================================
-- http://bit.ly/1b3RcR0

-- Better than the built in sp_indexhelp
EXEC sp_SQLskills_SQL2012_helpindex N'TableName'
GO

sp_indexhelp 'TableName'
GO
sp_spaceused 'TableName'
GO


-- ===  SHOW INDEX USAGE ===========================================================================

SELECT  i.name AS IndexName,
        i.type_desc AS IndexType,
        t.name AS TableName,
        c.name AS ColumnName,
        dmv.*
FROM    sys.tables t
        INNER JOIN sys.columns c
                ON c.object_id = t.object_id
        INNER JOIN sys.index_columns ic
                ON ic.column_id = c.column_id AND t.object_id = ic.object_id
        INNER JOIN sys.indexes i
                ON i.index_id = ic.index_id
               AND i.object_id = ic.object_id
        INNER JOIN sys.dm_db_index_usage_stats dmv
                ON dmv.index_id = i.index_id
               AND dmv.object_id = i.object_id
               AND dmv.database_id = DB_ID()
WHERE   t.is_ms_shipped = 0
ORDER BY i.name, t.name



-- ===  Index useage

DECLARE @TableName VARCHAR(128) = null

SELECT  [OBJECT NAME]       = OBJECT_NAME(ix_stats.object_id),
        [INDEX NAME]        = ix.[NAME],
        [USER_SEEKS]        = ix_stats.USER_SEEKS,
        [USER_SCANS]        = ix_stats.USER_SCANS,
        [USER_LOOKUPS]      = ix_stats.USER_LOOKUPS,
        [USER_UPDATES]      = ix_stats.USER_UPDATES,
        [Last Access Date]  = ( SELECT MAX(v) FROM (VALUES (ix_stats.last_user_seek), (ix_stats.last_user_scan), (ix_stats.last_user_lookup),
                                                           (ix_stats.last_system_seek), (ix_stats.last_system_scan), (ix_stats.last_system_lookup)) AS value(v) ) ,
        [Last Update Date]  = ( SELECT MAX(v) FROM (VALUES (ix_stats.last_user_update), (ix_stats.last_system_update)) AS value(v))
FROM    SYS.DM_DB_INDEX_USAGE_STATS AS ix_stats
        INNER JOIN SYS.INDEXES AS ix
                ON ix.object_id = ix_stats.object_id
               AND ix.index_id = ix_stats.index_id
WHERE   ix_stats.database_id = DB_ID()
        AND OBJECTPROPERTY(ix_stats.object_id,'IsUserTable') = 1
        AND (@TableName IS NULL OR ix_stats.object_id = OBJECT_ID(@TableName))
GO



-- ==== Details about the access methods to your indexes

DECLARE @TableName VARCHAR(128) = null

SELECT  OBJECT_NAME(stats.object_id) AS [OBJECT NAME],
        ix.[NAME] AS [INDEX NAME],
        stats.LEAF_INSERT_COUNT,
        stats.LEAF_UPDATE_COUNT,
        stats.LEAF_DELETE_COUNT
FROM    SYS.INDEXES AS ix
        INNER JOIN SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) stats
                ON stats.object_id = ix.[OBJECT_ID]
               AND stats.index_id  = ix.INDEX_ID
WHERE   stats.database_id = DB_ID()
        AND OBJECTPROPERTY(stats.object_id,'IsUserTable') = 1
        AND (@TableName IS NULL OR stats.object_id = OBJECT_ID(@TableName))




-- ===  INDEX STATS   ==============================================================================
-- ===  DBCC SHOWCONTIG       https://msdn.microsoft.com/en-us/library/ms175008.aspx
-- ===  DBCC SHOW_STATISTICS  https://msdn.microsoft.com/en-gb/library/ms174384.aspx

DBCC SHOWCONTIG ('application') WITH ALL_INDEXES, TABLERESULTS
DBCC SHOW_STATISTICS ('Application','PK_Applications') -- WITH STAT_HEADER | DENSITY_VECTOR | HISTOGRAM | STATS_STREAM

