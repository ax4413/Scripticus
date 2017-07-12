-- ====	EXECUTION COUNT OF SPROCS

-- Set this variable to the Database you want to interigate
DECLARE @DBName VARCHAR(150) = 'OECentral2008'

SELECT DB_NAME(st.dbid) DBName
	, OBJECT_SCHEMA_NAME(st.objectid,dbid) SchemaName
	, OBJECT_NAME(st.objectid,dbid) StoredProcedure
	, max(cp.usecounts) Execution_count
FROM sys.dm_exec_cached_plans cp
	CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE DB_NAME(st.dbid) is not null and cp.objtype = 'proc'
	AND DB_NAME(st.dbid) = @DBName
GROUP BY cp.plan_handle
	, DB_NAME(st.dbid)
	, OBJECT_SCHEMA_NAME(objectid,st.dbid)
	, OBJECT_NAME(objectid,st.dbid) 
ORDER BY max(cp.usecounts)



-- ==== LAST EXECUTION TIME OF SPROCS
SELECT distinct p.name
	,  Max(dm.last_execution_time) LastExecutionTime
FROM sys.procedures p
	LEFT OUTER JOIN sys.dm_exec_procedure_stats dm ON dm.object_id = p.object_id
GROUP BY p.name