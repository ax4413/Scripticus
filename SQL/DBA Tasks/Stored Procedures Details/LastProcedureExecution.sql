SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

DECLARE @querysought VARCHAR(256) = '%boywhathairylegsyouhavethere%';

SELECT  OBJECT_NAME(st.objectid) AS ObjName,
        qs.last_execution_time,
        cp.size_in_bytes, cp.usecounts,
        qp.query_plan,
        cp.cacheobjtype,cp.objtype,
        st.text AS QueryText,
        ( SELECT  st.text AS [processing-instruction(definition)]
          FROM    sys.dm_exec_sql_text(qs.sql_handle) sti
          FOR XML PATH(''), TYPE ) AS FormattedSQLText
FROM    sys.dm_exec_query_stats qs
        INNER JOIN sys.dm_exec_cached_plans cp
                ON qs.plan_handle = cp.plan_handle
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
        OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE   OBJECT_NAME(st.objectid) LIKE @querysought
        OR st.text LIKE @querysought
;