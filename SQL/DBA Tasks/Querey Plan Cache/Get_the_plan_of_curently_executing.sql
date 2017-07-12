-- ===  Get the plan handle of the plan 
-- ===  currently executing in a given session
DECLARE @plan_handle VARBINARY(MAX) 
SELECT  @plan_handle = plan_handle 
FROM    sys.dm_exec_requests 
WHERE   session_id = 360

-- ===  View the query plan
SELECT  @plan_handle AS plan_handle
SELECT  query_plan 
FROM    sys.dm_exec_query_plan (@plan_handle);