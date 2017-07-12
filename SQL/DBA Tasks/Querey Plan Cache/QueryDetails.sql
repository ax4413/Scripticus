
-- ===	Get last executed sql queries by time
-- ===  (cross apply allows joining to a table value fnc)
SELECT 	[Time]	= deqs.last_execution_time,
		    [Query] = dest.text
FROM 	  sys.dm_exec_query_stats as deqs
		    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) as dest
ORDER BY deqs.last_execution_time desc
;



-- ===  Get currently executing queries from cache
sys.sp_who2 'active'

DECLARE @spid INT = 148 -- From above

SELECT  EQP.query_plan, *
FROM    sys.dm_exec_requests AS ER
        CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) AS EQP
WHERE   ER.session_id = @spid
;



--  ============================================================================================================
--  Author:     Stephen Yeadon
--  Date:       2013-11-15
--  Desc:       Code to remove a bad plan
--  Reference:
--  Notes:      Removes 1 plan. Do not execute without a plan_handle or the entire plan cach would be emptied.
--              This would be very bad
--  ============================================================================================================
DBCC FREEPROCCACHE (0x060014009EB44523209C45640F00000001000000000000000000000000000000000000000000000000000000);



-- ===  what are the SET properties of teh query
select * from sys.dm_exec_plan_attributes (0x0500060085C0FC594001ED010B0000000000000000000000)



-- ==== Details on what the query opermiser has been up to (these are reset at startup)
SELECT *
FROM    sys.dm_exec_query_optimizer_info
WHERE   counter IN ('optimizations', 'elapsed time','final cost',
                    'insert stmt','delete stmt','update stmt',
                    'merge stmt','contains subquery','tables',
                    'hints','order hint','join hint',
                    'view reference','remote query','maximum DOP',
                    'maximum recursion level','indexed views loaded',
                    'indexed views matched','indexed views used',
                    'indexed views updated','dynamic cursor request',
                    'fast forward cursor request')
;
