-------------------------------------------------------------------------------------
-- Execution Plans ------------------------------------------------------------------
use [AdventureWorks2012]
GO

-------------------------------------------------------------------------------------
-- Text - Estimated Execution Plan ---------------------------------------------------
SET SHOWPLAN_ALL ON;
GO
SELECT * FROM [dbo].[DatabaseLog] ;
GO
SET SHOWPLAN_ALL OFF;
GO

-------------------------------------------------------------------------------------
-- Text - Actuall execution plan ----------------------------------------------------
SET STATISTICS PROFILE ON;
GO
SELECT * FROM [dbo].[DatabaseLog] ;
GO
SET STATISTICS PROFILE OFF;
GO



-------------------------------------------------------------------------------------
-- XML - Estimated execution plan ---------------------------------------------------
SET SHOWPLAN_XML ON;
GO
SELECT * FROM [dbo].[DatabaseLog] ;
GO
SET SHOWPLAN_XML OFF;
GO

-------------------------------------------------------------------------------------
-- XML - Actuall execution plan -----------------------------------------------------
SET STATISTICS XML ON;
GO
SELECT * FROM [dbo].[DatabaseLog] ;
GO
SET STATISTICS XML OFF;
GO



-------------------------------------------------------------------------------------
-- Get execution plans out of the plan cache aka procedure cache --------------------
SELECT [cp].[refcounts] ,
[cp].[usecounts] ,
[cp].[objtype] ,
[cp].[plan_handle] ,
[st].[dbid] ,
[st].[objectid] ,
[st].[text] ,
[qp].[query_plan]
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp;


-------------------------------------------------------------------------------------
-- Drop a plan from the cache by passing the pan_handle to this DBCC funcyion -------
DBCC FREEPROCCACHE(plan_handel)