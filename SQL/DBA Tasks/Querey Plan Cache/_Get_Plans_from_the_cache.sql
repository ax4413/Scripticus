--  ============================================================================================================
--  Author:     Stephen Yeadon
--  Date:       2013-09-04
--  Desc:       Get Cached query plans for executed stored procedures
--  Reference:   http://www.sqlservercentral.com/blogs/everyday-sql/2013/09/03/the-case-of-the-null-query_plan/
--
--  Notes:      Some times the query plan can not be returned as it is to large for the xml type a NULL value
--              is returned in its place. If this is the case then neither of the following two functions can
--              help you, you will need to use powershell to get at the data. It is simply a limitation of SSMS.
--              SELECT * FROM sys.dm_exec_query_plan(plan_handle);
--              SELECT * FROM sys.dm_exec_text_query_plan(plan_handle, DEFAULT, DEFAULT)
--              Time for the shell Get-CachedQueryPlan.ps1 ( full details can be found in the above article )
--
--  ============================================================================================================

SELECT  qp.query_plan, ps.plan_handle
FROM    sys.dm_exec_procedure_stats ps
        INNER JOIN sys.objects o
                ON ps.object_id = o.object_id
        INNER JOIN sys.schemas s
                ON o.schema_id = s.schema_id
        OUTER APPLY sys.dm_exec_query_plan(ps.plan_handle) qp
WHERE   ps.database_id = DB_ID()
        AND s.name = 'dbo'
        AND o.name = 'SprocName'
;









--  ============================================================================================================
--  Author:     Stephen Yeadon
--  Date:       2013-11-15
--  Desc:       Get Cached query plans by the text that they execute.
--  Reference:
--  Notes:      This is only queries sql not procedures
--  ============================================================================================================

DECLARE @SearchText NVARCHAR(4000)
    SET @SearchText = N'WorkQueueHistory'
    SET @SearchText = N'%' + @SearchText + N'%'

PRINT 'Search Predicate: ' + @SearchText


-- ===  This will show you the execution plan of all sql executed containg the text "blah blah".
-- ===  You will need to decide which plan you want to remove
;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT  stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text,
              qp.query_plan,
        cp.plan_handle
FROM    sys.dm_exec_cached_plans cp
        CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
              CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
              CROSS APPLY qp.query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
WHERE   st.text LIKE @SearchText
  AND   (st.dbid is null or st.dbid = db_id())
ORDER BY SQL_Text
OPTION  (MAXDOP 1, RECOMPILE)
;


--  ============================================================================================================
--  Author:     Stephen Yeadon
--  Date:       2013-11-15
--  Desc:       Performave details arround plan execution
--  Reference:
--  Notes:      This is works for all queries sql, procedures, triggers etc
--  ============================================================================================================
SELECT  [Database Name]       = DB_NAME(st.dbid)
      , [Object Type]         = cp.objtype
      , [Schema Name]         = SCHEMA_NAME(o.Schema_id)
      , [Object Name]         = o.name
      , [Sql Text]            = st.text
      , [Cache Type]          = CP.CacheObjType
      , [Query Plan]          = qp.query_plan
      , [Comilation Time]     = qs.creation_time
      , [Last Execution Time] = qs.last_execution_time
      , [Execution Count]     = qs.execution_count
      , [Ref Count]           = cp.RefCounts
      , [Use Counts]          = cp.UseCounts
      , [Last Logical Reads]  = qs.last_logical_reads
      , [Last Logical Writes] = qs.last_logical_writes
      , [Last Physical Reads] = qs.last_physical_reads
      , [Last Worker Time]    = qs.last_worker_time
      , [Plan Handle]         = cp.plan_handle
      , [Parent Plan Handle]  = cp.parent_plan_handle
      , [Sql Handle]          = qs.sql_handle
      , [Query Hash]          = qs.query_hash
      , [Query Plan Hash]     = qs.query_plan_hash
FROM    sys.dm_exec_cached_plans cp
        INNER JOIN sys.dm_exec_query_stats qs
                ON qs.plan_handle = cp.plan_handle
        CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
        LEFT OUTER JOIN sys.objects o
                ON o.object_id = st.objectid
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE   st.dbid = db_id()
  AND   st.text LIKE @SearchText
ORDER BY DB_NAME(st.dbid), st.text
;

