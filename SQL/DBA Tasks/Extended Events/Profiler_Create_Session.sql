/*
    Replace the following values:
        DbName            =>    the actual database name
        DbId              =>    the atual db_id() value for the database you want to profile e.g.
                                  SELECT DB_ID('DbName')
        C:\Foo            =>    the actual path to save the file e.g. \\505295-SSCLUQA\Extended_Events
                                                                      \\505281-ssclutr\Extended_Events
        max_file_size_mb  = > the max sixe of the file in mb
        max_no_of_files   = > the max number of file to roll through
*/

-- ===  Create a profiler session for a particular database
CREATE EVENT SESSION [DbName_Profiler] ON SERVER
ADD EVENT sqlserver.begin_tran_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(DbId)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.rollback_tran_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(DbId)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.rpc_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([sqlserver].[database_id]=(DbId) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.rpc_starting(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([sqlserver].[database_id]=(DbId) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.save_tran_completed(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(DbId)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(DbId)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(DbId)) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_transaction(
    ACTION(package0.process_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.transaction_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(DbId)) AND [sqlserver].[is_system]=(0)))
ADD TARGET package0.event_file( SET filename=N'C:\Foo\Profiler.xel', max_file_size=(max_file_size_mb),max_rollover_files=(max_no_of_files) )
WITH (  MAX_MEMORY            = 4096 KB
      , EVENT_RETENTION_MODE  = ALLOW_SINGLE_EVENT_LOSS
      , MAX_DISPATCH_LATENCY  = 30 SECONDS
      , MAX_EVENT_SIZE        = 0 KB
      , MEMORY_PARTITION_MODE = NONE
      , TRACK_CAUSALITY       = OFF
      , STARTUP_STATE         = OFF )
GO


-- ===  Enable the session to start capturing events:
ALTER EVENT SESSION [DbName_Profiler] ON SERVER STATE = start;


-- ===  If you want the session to stop capturing events (until you enable the session again), you can use this quer\505295-SSCLUQA\Extended_Events
ALTER EVENT SESSION [DbName_Profiler] ON SERVER STATE = stop;


-- ===  If you want to completely remove (delete) the session from the server, you can use this quer\505295-SSCLUQA\Extended_Events
DROP EVENT SESSION [DbName_Profiler] ON SERVER



















CREATE EVENT SESSION [VirginMediaReportingDev_SY_Profiler] ON SERVER 
ADD EVENT sqlserver.begin_tran_completed(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.rollback_tran_completed(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.rpc_completed(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.rpc_starting(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.save_tran_completed(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) ),
ADD EVENT sqlserver.sql_transaction(
    ACTION (  package0.process_id
            , sqlserver.database_id
            , sqlserver.is_system
            , sqlserver.plan_handle
            , sqlserver.query_hash
            , sqlserver.query_plan_hash
            , sqlserver.session_id
            , sqlserver.sql_text
            , sqlserver.transaction_id )
    WHERE   ( [package0].[equal_uint64] ( [sqlserver].[database_id], (317) ) 
              AND [package0].[equal_boolean] ( [sqlserver].[is_system], (0) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%SQL Diagnostic Manager%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%select collationname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%sp_oledb_ro_usrname%' ) ) 
              AND ( NOT [sqlserver].[like_i_sql_unicode_string] ( [sqlserver].[sql_text], N'%BACKUP LOG%' ) )
            ) )
ADD TARGET package0.event_file( SET filename       = N'R:\Extended Events Logs\Test\Profiler.xel'
                              , max_file_size      = (500)
                              , max_rollover_files = (4) )
WITH (  MAX_MEMORY            = 4096 KB
      , EVENT_RETENTION_MODE  = ALLOW_SINGLE_EVENT_LOSS
      , MAX_DISPATCH_LATENCY  = 30 SECONDS
      , MAX_EVENT_SIZE        = 0 KB
      , MEMORY_PARTITION_MODE = NONE
      , TRACK_CAUSALITY       = OFF
      , STARTUP_STATE         = OFF )
GO

