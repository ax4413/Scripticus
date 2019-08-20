/*
    Replace the following values:
        C:\Foo    =>    the actual path to save the file e.g. \\505295-SSCLUQA\Extended_Events
                                                              \\505281-ssclutr\Extended_Events
*/


USE master

-- ===  Create a new event session (it is better to create a new session and not modify the system’s built-in session “system_health”):
CREATE EVENT SESSION [Deadlock_Monitor] ON SERVER
ADD EVENT sqlserver.lock_deadlock(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id,sqlserver.username)),
ADD EVENT sqlserver.lock_deadlock_chain(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id,sqlserver.username)),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'C:\Foo\Deadlock_Monitor.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


-- ===  Enable the session to start capturing events:
ALTER EVENT SESSION [Deadlock_Monitor] ON SERVER STATE = start;


-- ===  If you want the session to stop capturing events (until you enable the session again), you can use this query:
ALTER EVENT SESSION [Deadlock_Monitor] ON SERVER STATE = stop;


-- ===  If you want to completely remove (delete) the session from the server, you can use this query:
DROP EVENT SESSION [Deadlock_Monitor] ON SERVER


