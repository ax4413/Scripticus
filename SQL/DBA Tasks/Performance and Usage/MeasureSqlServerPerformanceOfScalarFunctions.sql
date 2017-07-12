-- https://www.mssqltips.com/sqlservertip/4100/how-to-find-udfs-causing-sql-server-performance-issues/
-- More queries can be found here to identify poorly behaving udf's

SELECT TOP 100 
        DatabaseName            = DB_NAME()
      , TotalWorkerTime         = qs.total_worker_time /1000000
      , TotalElapsedTime_Sec    = QS.total_elapsed_time/1000000
      , Avg_elapsed_time_Sec    = QS.total_elapsed_time/(1000000*qs.execution_count)
      , Execution_count         = QS.execution_count
      , Avg_logical_reads       = QS.total_logical_reads/QS.execution_count
      , Max_logical_writes      = QS.max_logical_writes
      , ParentQueryText         = ST.text
      , Query_Text              = SUBSTRING( ST.[text], QS.statement_start_offset/2+1, 
                                             ( CASE WHEN QS.statement_end_offset = -1 
                                                         THEN LEN(CONVERT(nvarchar(max), ST.[text])) * 2 
                                                    ELSE QS.statement_end_offset 
                                                END - QS.statement_start_offset)/2)
      , QP.query_plan 
      , O.type_desc
FROM  sys.dm_exec_query_stats QS 
      CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST 
      CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) QP 
      LEFT OUTER JOIN Sys.objects O 
              ON O.object_id =St.objectid 
WHERE O.type_desc like '%Function%'
ORDER by qs.total_worker_time DESC ;
