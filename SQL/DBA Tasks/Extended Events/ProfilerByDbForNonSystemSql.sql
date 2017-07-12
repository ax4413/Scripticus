

CREATE EVENT SESSION [Profiler] ON SERVER 
ADD EVENT sqlserver.begin_tran_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.transaction_id,sqlserver.transaction_sequence)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(79)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.rollback_tran_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.transaction_id,sqlserver.transaction_sequence)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(79)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.save_tran_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.transaction_id,sqlserver.transaction_sequence)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(79)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(package0.process_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id,sqlserver.transaction_sequence)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(79)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id,sqlserver.transaction_sequence)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(79)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_transaction(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.transaction_id,sqlserver.transaction_sequence)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(79)) AND [sqlserver].[is_system]=(0))) 
ADD TARGET package0.event_file(SET filename=N'Y:\MSSQL11.DEV\MSSQL\Log\Profiler3.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

