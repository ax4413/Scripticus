select  count(*) as sessions,
        s.host_process_id,
		s.host_name,
        db_name(s.database_id) as database_name,
        s.program_name        
from    sys.dm_exec_sessions s
where   is_user_process = 1
group by host_name, host_process_id, program_name, database_id
order by 1 desc, 4, 3, 2;



declare @host_process_id   int = NULL;
declare @host_name     sysname = NULL;
declare @database_name sysname = NULL;
 
select  s.host_process_id,
        s.host_name,
        db_name(s.database_id) as database_name,
        s.program_name,
        s.session_id,
        t.text as last_sql,        
		datediff(minute, s.last_request_end_time, getdate()) as minutes_asleep
from    sys.dm_exec_connections c
        inner join sys.dm_exec_sessions s
                on c.session_id = s.session_id
        cross apply sys.dm_exec_sql_text(c.most_recent_sql_handle) t
where   s.is_user_process = 1
  and   s.status = 'sleeping'
  and   datediff(second, s.last_request_end_time, getdate()) > 60
  and   (@database_name is null   or db_name(s.database_id) = @database_name)
  and   (@host_process_id is null or s.host_process_id = @host_process_id)
  and   (@host_name is null       or s.host_name = @host_name)
order by count(s.session_id) over(partition by s.host_process_id, s.host_name, s.database_id) desc,
         db_name(s.database_id),
         s.host_name,
         s.host_process_id,
         s.last_request_end_time;