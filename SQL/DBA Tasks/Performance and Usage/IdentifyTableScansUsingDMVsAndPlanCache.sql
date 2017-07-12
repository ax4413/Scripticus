-- ===  Identify where table scans are causing us performance problems
-- ===  https://www.simple-talk.com/sql/database-administration/exploring-query-plans-in-sql/

-- ===  Which database is in the worst shape    ============================================
SELECT  db_name(database_id), max(user_scans) bigger, avg(user_scans) average
FROM    sys.dm_db_index_usage_stats
GROUP BY db_name(database_id)
ORDER BY average DESC ;



-- ===  Lets have a look at that database   ================================================
Use MetroBankMainDEV    /* <<<<------- you will need to change the  database name */

SELECT  [table]         = object_name(c.object_id),
        [index]         = c.name,
        [user_scans]    = user_scans,
        [user_seeks]    = user_seeks,
        [type]          = CASE a.index_id
                            WHEN 1 THEN 'CLUSTERED'
                            ELSE 'NONCLUSTERED' END
FROM    sys.dm_db_index_usage_stats a
        INNER JOIN sys.indexes c
                ON  c.object_id = a.object_id
                AND c.index_id  = a.index_id
                AND database_id = DB_ID()
ORDER BY user_scans DESC ;



-- ===  LETS HAVE A LOOK AT THESE PLANS ====================================================

-- ===  List all plans that include a scan
SELECT  qp.query_plan, qt.text , total_worker_time
FROM    sys.dm_exec_query_stats
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt
        CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
WHERE   qp.query_plan.exist('declare namespace
                             qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
                             //qplan:RelOp[@LogicalOp="Index Scan"
                             or @LogicalOp="Clustered Index Scan"
                             or @LogicalOp="Table Scan"]')=1
ORDER BY total_worker_time DESC ;


-- ===  List only the plans that scan a particular index
SELECT  qp.query_plan, qt.text , total_worker_time
FROM    sys.dm_exec_query_stats
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt
        CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
WHERE   qp.query_plan.exist('declare namespace
                             qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
                             //qplan:RelOp[@LogicalOp="Index Scan"
                             or @LogicalOp="Clustered Index Scan"
                             or @LogicalOp="Table Scan"]/qplan:IndexScan/qplan:Object[@Index="[PK_ThirdPartyServiceAvailability]"]')=1
ORDER BY total_worker_time DESC ;

-- ===  ====================================================================================