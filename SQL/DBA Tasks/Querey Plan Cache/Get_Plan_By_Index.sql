--  ============================================================================================================
--  Author:     I cant take credit for this one
--  Date:       2013-11-15
--  Desc:       Find out which queries in the plan cach use a specific index
--  Reference:  http://www.sqlskills.com/blogs/jonathan/finding-what-queries-in-the-plan-cache-use-a-specific-index/
--  Notes:
--  ============================================================================================================

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @IndexName AS NVARCHAR(128) = 'PK__marbles__3213E83F669B24EC';

-- ==== Make sure the name passed is appropriately quoted
-- ==== Handle the case where the left or right was quoted manually but not the opposite side
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName;
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']';

-- ====    Dig into the plan cache and find all plans using this index
;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
    SELECT  [SQL_Text]      = stmt.value('(@StatementText)[1]', 'varchar(max)') ,
            [DatabaseName]  = obj.value('(@Database)[1]', 'varchar(128)') ,
            [SchemaName]    = obj.value('(@Schema)[1]', 'varchar(128)') ,
            [TableName]     = obj.value('(@Table)[1]', 'varchar(128)') ,
            [IndexName]     = obj.value('(@Index)[1]', 'varchar(128)') ,
            [IndexKind]     = obj.value('(@IndexKind)[1]', 'varchar(128)') ,
            [PlanHandle]    = cp.plan_handle,
            [QueryPlan]     = query_plan
    FROM sys.dm_exec_cached_plans AS cp
            CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
            CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
            CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj)
    OPTION(MAXDOP 1, RECOMPILE)
;