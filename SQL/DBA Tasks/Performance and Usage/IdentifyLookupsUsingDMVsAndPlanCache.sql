-- ===  Identify where lookups are causing us performance problems
-- ===  https://www.simple-talk.com/sql/database-administration/exploring-query-plans-in-sql/

-- ===  Which database is in the worst shape    ============================================
SELECT  db_name(database_id), max(user_lookups) bigger, avg(user_lookups) average
FROM    sys.dm_db_index_usage_stats
GROUP BY db_name(database_id)
ORDER BY average DESC ;



-- ===  Lets have a look at that database   ================================================
Use MetroBankMainDEV    /* <<<<------- you will need to change the  database name */

SELECT  [table]         = object_name(c.object_id),
        [index]         = c.name,
        [user_lookups]  = user_lookups,
        [type]          = CASE a.index_id
                            WHEN 1 THEN 'CLUSTERED'
                            ELSE 'NONCLUSTERED' END
FROM    sys.dm_db_index_usage_stats a
        INNER JOIN sys.indexes c
                ON  c.object_id = a.object_id
                AND c.index_id  = a.index_id
                AND database_id = DB_ID()
ORDER BY user_lookups DESC ;



-- ===  LETS HAVE A LOOK AT THESE PLANS ====================================================

-- ===  List all plans that include a lookup
SELECT  qp.query_plan,
        qt.text,
        plan_handle,
        query_plan_hash
FROM    sys.dm_exec_query_stats
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt
        CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
WHERE   qp.query_plan.exist('declare namespace
                             AWMI="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
                             //AWMI:IndexScan[@Lookup]')=1

-- ===  List all plans that include a lookup on a particular index
SELECT  qp.query_plan,
        qt.text,
        plan_handle,
        query_plan_hash
FROM    sys.dm_exec_query_stats
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt
        CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
WHERE   qp.query_plan.exist('declare namespace
                             AWMI="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
                             //AWMI:IndexScan[@Lookup]/AWMI:Object[@Index="[PK_SystemParameter]"]')=1

-- ===  ====================================================================================