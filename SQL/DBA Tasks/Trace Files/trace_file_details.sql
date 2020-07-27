
select  id
      , [Status]     = case tr.[status] when 1 THEN 'Running' when 0 THEN 'Stopped' end
      , [Default]    = case tr.is_default when 1 THEN 'System TRACE' when 0 THEN 'User TRACE' end
      , [login_name] = coalesce(se.login_name,se.login_name,'No reader spid')
      , [Trace Path] = coalesce(tr.[Path],tr.[Path],'OLE DB Client Side Trace')
from      sys.traces tr
          left join sys.dm_exec_sessions se on tr.reader_spid = se.session_id

-- https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-trace-getinfo-transact-sql?view=sql-server-ver15
SELECT * FROM ::fn_trace_getinfo(NULL)



declare @trace_id int = 2

EXEC sp_trace_setstatus @traceid = @trace_id , @status = 0 -- STOP
EXEC sp_trace_setstatus @traceid = @trace_id , @status = 2 -- DELETE
