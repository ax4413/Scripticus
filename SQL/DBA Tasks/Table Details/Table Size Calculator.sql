SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
Purpose:
To Evaluate table sizes combined with index space consumption to determine higher cost tables in 
terms of storage, resources and maintenance needs.

ModifiedDate  ModifiedBy  Description
2013-11-21    JB          Tables without Indexes had a Null Value in the Output
                          Fixed the output to sum properly for the NULLS in absence of an index
2015-04-17    JB          Added Filegroup information
                          Updated calcs - little more accuracy
                          Updated internal tables exclusions
2015-07-24    JB          Added Server Version Check and Internal Tables to pull from temp table
                          Added MSShipped Logic
2015-08-04    SY          Changed the temp table clustered index ddl
                          Formated the sql to my liking

*/

DECLARE @dbsize DECIMAL(19,2)
      , @logsize DECIMAL(19,2)
      , @IsMSShipped TINYINT = 0
        /*  NULL = all objects
            1 = MS Shipped Objects
            0 = User Created Objects
        */
    ;
--DECLARE @FileGroup VARCHAR(128) = NULL; --Null for all filegroups


--contributes TO SPACE IN what versions OF SQL
--2012    (202,204,207,211,212,213,214,215,216,221,222,236)
--2008    (202,204,211,212,213,214,215,216)
--2008R2  (202,204,211,212,213,214,215,216)
--2014    (202,204,207,211,212,213,214,215,216,221,222,236)
--2005    (202,204)
--2016    (202,204,207,211,212,213,214,215,216,221,222,236)

DECLARE   @ServerMajorVersion DECIMAL(4, 2)
SELECT    @ServerMajorVersion = CONVERT(DECIMAL(4, 2), PARSENAME(dt.fqn, 4) + '.' + PARSENAME(dt.fqn, 3))
FROM      ( SELECT CONVERT( VARCHAR(20), SERVERPROPERTY('ProductVersion') ) ) dt ( fqn );

IF OBJECT_ID('tempdb.dbo.#InternalTables') IS NOT NULL BEGIN
  DROP TABLE #InternalTables;
END

CREATE TABLE #InternalTables (
    [internal_type] [TINYINT] NULL
  , [internal_type_desc] [VARCHAR](60) NULL
  , [DBSource] [VARCHAR](16) NULL
) ON  [PRIMARY];

CREATE CLUSTERED INDEX CI_InternalType ON #InternalTables(internal_type)


INSERT INTO #InternalTables ( [internal_type], [internal_type_desc], [DBSource] )
  VALUES  ( 201, N'QUEUE_MESSAGES', N'system database' )
        , ( 202, N'XML_INDEX_NODES', N'user database' )
        , ( 203, N'FULLTEXT_CATALOG_FREELIST', N'User Database' )
        , ( 204, N'FULLTEXT_CATALOG_MAP (BOL)/FULLTEXT_INDEX_MAP (REALITY)', N'User Database' )
        , ( 205, N'QUERY_NOTIFICATION', N'User Database' )
        , ( 206, N'SERVICE_BROKER_MAP', N'system database' )
        , ( 207, N'EXTENDED_INDEXES', N'user database' )
        , ( 208, N'FILESTREAM_TOMBSTONE', N'system database' )
        , ( 209, N'CHANGE_TRACKING', N'User Database' )
        , ( 210, N'TRACKED_COMMITTED_TRANSACTIONS', N'system database' )
        , ( 211, N'FULLTEXT_AVDL', N'user database' )
        , ( 212, N'FULLTEXT_COMP_FRAGMENT', N'user database' )
        , ( 213, N'FULLTEXT_DOCID_STATUS', N'user database' )
        , ( 214, N'FULLTEXT_INDEXED_DOCID', N'user database' )
        , ( 215, N'FULLTEXT_DOCID_FILTER', N'user database' )
        , ( 216, N'FULLTEXT_DOCID_MAP', N'user database' )
        , ( 217, N'FULLTEXT_THESAURUS_METADATA_TABLE', N'system database' )
        , ( 218, N'FULLTEXT_THESAURUS_STATE_TABLE', N'system database' )
        , ( 219, N'FULLTEXT_THESAURUS_PHRASE_TABLE', N'system database' )
        , ( 220, N'CONTAINED_FEATURES', N'system database' )
        , ( 221, N'SEMPLAT_DOCUMENT_INDEX_TABLE', N'user database' )
        , ( 222, N'SEMPLAT_TAG_INDEX_TABLE', N'user database' )
        , ( 223, N'SEMPLAT_MODEL_MAPPING_TABLE', N'system database' )
        , ( 224, N'SEMPLAT_LANGUAGE_MODEL_TABLE', N'system database' )
        , ( 225, N'FILETABLE_UPDATES', N'system database' )
        , ( 236, N'SELECTIVE_XML_INDEX_NODE_TABLE', N'user database' )
        , ( 240, N'QUERY_DISK_STORE_QUERY_TEXT', N'system database' )
        , ( 241, N'QUERY_DISK_STORE_QUERY', N'system database' )
        , ( 242, N'QUERY_DISK_STORE_PLAN', N'system database' )
        , ( 243, N'QUERY_DISK_STORE_RUNTIME_STATS', N'system database' )
        , ( 244, N'QUERY_DISK_STORE_RUNTIME_STATS_INTERVAL', N'system database' )
        , ( 245, N'QUERY_CONTEXT_SETTINGS', N'system database' );


IF OBJECT_ID('tempdb.dbo.#SpaceVersions') IS NOT NULL BEGIN
  DROP TABLE #SpaceVersions;
END

CREATE TABLE #SpaceVersions (
    Product VARCHAR(32)
  , ServerMajorVersion DECIMAL(4, 2)
  , TypesList VARCHAR(256)
) ;

CREATE CLUSTERED INDEX CI_ServerMajorVer ON #SpaceVersions(ServerMajorVersion)

INSERT INTO #SpaceVersions ( Product, ServerMajorVersion, TypesList )
  VALUES ( 'SQL Server 2005', 9.00 , '202,204')
       , ( 'SQL Server 2008', 10.00 , '202,204,211,212,213,214,215,216')
       , ( 'SQL Server 2008R2', 10.50 , '202,204,211,212,213,214,215,216')
       , ( 'SQL Server 2012', 11.00 , '202,204,207,211,212,213,214,215,216,221,222,236')
       , ( 'SQL Server 2014', 12.00 , '202,204,207,211,212,213,214,215,216,221,222,236')
       , ( 'SQL Server 2016', 13.00 , '202,204,207,211,212,213,214,215,216,221,222,236');


IF OBJECT_ID('tempdb.dbo.#PreselTypes') IS NOT NULL BEGIN
  DROP TABLE #PreselTypes;
END

SELECT  sv.Product, myit.internal_type, myit.internal_type_desc
INTO    #PreselTypes
FROM    #SpaceVersions sv 
        CROSS APPLY master.dbo.DelimitedSplit8K(sv.TypesList,',') ss
        /* must have DelimitedSplit8K installed http://bit.ly/Moden8KDL */
        /* Change database name in accordance with 8k splitter location */
        INNER JOIN #InternalTables myit
                ON ss.item = myit.internal_type
WHERE   sv.ServerMajorVersion = @ServerMajorVersion;


SET NOCOUNT ON

-- ===  Summary data.
BEGIN
    SELECT  @dbsize   = SUM(CONVERT(DECIMAL(19,2),CASE WHEN type = 0 THEN size ELSE 0 END)) / 128.0
          , @logsize  = SUM(CONVERT(DECIMAL(19,2),CASE WHEN type = 1 THEN size ELSE 0 END)) / 128.0
    FROM    sys.database_files
 
END

; WITH FirstPass AS (
    SELECT  object_id     = p.object_id
          , partition_id  = p.partition_id
          , ReservedPage  = CONVERT(DECIMAL(19,2),SUM(a.total_pages)) / 128.0
          , UsedPage      = CONVERT(DECIMAL(19,2),SUM(a.used_pages)) / 128.0
          , PageCnt       = SUM( CONVERT(DECIMAL(19,2), CASE WHEN ISNULL(svj.internal_type,1) <> 1 THEN 0
                                                             WHEN (a.type <> 1 AND p.index_id < 2) THEN a.used_pages
                                                             WHEN p.index_id < 2 THEN a.data_pages
                                                             ELSE 0 /*lob_used_page_count + row_overflow_used_page_count*/ END ) ) / 128.0
          , RowCnt        = SUM( CASE WHEN (p.index_id < 2) THEN ps.row_count
                                      ELSE 0 END )
    FROM    sys.allocation_units a
            INNER JOIN sys.partitions p
                    ON a.container_id = p.partition_id
            INNER JOIN sys.dm_db_partition_stats ps
                    ON p.object_id = ps.object_id
                    AND p.index_id = ps.index_id
            LEFT OUTER JOIN sys.internal_tables it
                    ON p.object_id = it.object_id
            LEFT OUTER JOIN #PreselTypes svj
                    ON it.internal_type = svj.internal_type
    WHERE   1 = 1
            AND OBJECTPROPERTY(p.object_id,'IsMSShipped') = ISNULL(@IsMSShipped,OBJECTPROPERTY(p.object_id,'IsMSShipped'))
            AND p.index_id IN (0,1,255)
    GROUP BY p.object_id, p.partition_id
)
, FileGroupNames AS (
    SELECT  ( STUFF( 
              ( SELECT  DISTINCT ', <' + FILEGROUP_NAME(au.data_space_id) + '>' 
                FROM    sys.allocation_units au
                        INNER JOIN sys.partitions pu
                                ON au.container_id = pu.partition_id
                WHERE   pu.object_id = a.object_id
                FOR XML PATH(''), ROOT('FileGroupNames'), TYPE 
              ).value('/FileGroupNames[1]','varchar(max)') 
              , 1, 2, '')) AS FGList, a.object_id
    FROM    FirstPass a
)
, IndexPass AS (
    SELECT  ps.object_id
          , iReservedPage = CONVERT( DECIMAL(19,2),SUM( CASE WHEN (index_id NOT IN (0,1,255)) THEN (ps.reserved_page_count)
                                                             ELSE 0 END)) / 128.0
          , iUsedPage     = CONVERT( DECIMAL(19,2),SUM( CASE WHEN (index_id NOT IN (0,1,255)) THEN ps.used_page_count
                                                             ELSE 0 END)) / 128.0
          , iPageCnt      = SUM( CONVERT(DECIMAL(19,2),CASE WHEN (index_id NOT IN (0,1,255))
                                                              THEN in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count
                                                            ELSE 0 END )) / 128.0
          , RowCnt        = SUM( CASE WHEN (index_id < 2) THEN row_count
                                      ELSE 0 END )
    FROM    sys.dm_db_partition_stats ps
    WHERE   1 = 1 
            AND OBJECTPROPERTY(ps.object_id,'IsMSShipped') = ISNULL(@IsMSShipped,OBJECTPROPERTY(ps.object_id,'IsMSShipped'))
            --AND index_id NOT IN (0,1,255)
    GROUP BY ps.object_id
)
, InternalTables AS (
    SELECT  ps.object_id
          , ReservedPage  = CONVERT(DECIMAL(19,2),SUM(reserved_page_count)) / 128.0
          , UsedPage      = CONVERT(DECIMAL(19,2),SUM(used_page_count)) / 128.0
    FROM    sys.dm_db_partition_stats  ps
            INNER JOIN sys.internal_tables it
                    ON it.object_id = ps.object_id
            INNER JOIN #PreselTypes svj2
                    ON it.internal_type = svj2.internal_type
    WHERE   it.parent_id = ps.object_id
            AND OBJECTPROPERTY(ps.object_id,'IsMSShipped') = ISNULL(@IsMSShipped,OBJECTPROPERTY(ps.object_id,'IsMSShipped'))
    GROUP BY ps.object_id
)
, Summary AS (
    SELECT  ObjName         = OBJECT_NAME (F.object_id) 
          , SchemaName      = SCHEMA_NAME(o.schema_id)
          , IsMsShipped     = CASE WHEN OBJECTPROPERTY(F.object_id,'IsMSShipped') = 1 THEN 'YES' 
                                   ELSE 'NO'  END
          , NumRows         = MAX(F.RowCnt)
          , ReservedPageMB  = SUM(ISNULL(F.ReservedPage,0) + ISNULL(i.ReservedPage,0))
          , DataSizeMB      = SUM(F.PageCnt)
          , IndexSizeMB     = SUM(ISNULL(ip.iPageCnt,0))
          , UnusedSpace     = SUM( CASE WHEN (F.ReservedPage + ISNULL(i.ReservedPage,0)) > (F.UsedPage + ISNULL(i.UsedPage,0))
                                            THEN ((F.ReservedPage + ISNULL(i.ReservedPage,0)) - (F.UsedPage + ISNULL(i.UsedPage,0))) 
                                        ELSE 0 END) + (SUM(ISNULL(ip.iReservedPage,0)) - SUM(ISNULL(ip.iUsedPage,0)))/128
          , IndexReservedMB = SUM(ISNULL(ip.iReservedPage,0))
          , dbsizeMB        = @dbsize
          , LogSizeMB       = @logsize
          , FGList          = MAX(fg.FGList)
    FROM    FirstPass F
            INNER JOIN sys.objects o
                    ON F.object_id = o.object_id
            INNER JOIN FileGroupNames fg
                    ON fg.object_id = F.object_id
            LEFT OUTER JOIN InternalTables i
                    ON i.object_id = F.OBJECT_ID
            LEFT OUTER JOIN IndexPass ip
                    ON F.OBJECT_ID = ip.OBJECT_ID
--WHERE F.FileGroupName = ISNULL(@FileGroup,F.FileGroupName)
GROUP BY F.object_id,o.schema_id
)
, TotalUnallocated AS (
    SELECT  SUM(ISNULL(UnusedSpace,0)) AS UnusedSpace
          , Usedr = SUM(ISNULL(Summary.ReservedPageMB,0))+SUM(ISNULL(Summary.IndexReservedMB,0)) 
    FROM    Summary
)

SELECT  ObjName
      , SchemaName
      --, S.FileGroupName
      , S.FGList
      , IsMsShipped,NumRows
      , ReservedPageMB
      , DataSizeMB            = ISNULL(DataSizeMB,0)
      , IndexSizeMB           = ISNULL(IndexSizeMB,0)
      , UnusedTableSpace      = ISNULL(S.UnusedSpace,0)
      , dbsizeMB
      , LogSizeMB
      , TotalTableFreeSpace   = TU.UnusedSpace
      , DataFileFreeSpace     = dbsizeMB - TU.Usedr
      /*within 1.5mb on a 1.76tb database or .000085% variance or 99.999915% accuracy */
      , PercentofDBPhysFile   = ((ISNULL(IndexSizeMB,0) + ISNULL(DataSizeMB,0)) / @dbsize) * 100
      , PercentofDBUsedSpace  = ((ISNULL(IndexSizeMB,0) + ISNULL(DataSizeMB,0)) / (@dbsize - TU.UnusedSpace)) * 100
FROM  Summary S
      CROSS APPLY TotalUnallocated TU
ORDER BY PercentofDBUsedSpace DESC;