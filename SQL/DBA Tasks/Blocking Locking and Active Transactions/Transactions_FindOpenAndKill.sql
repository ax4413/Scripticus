
-- ===== =======================================================================
-- ===== Author:    Stephen Yeadon
-- ===== Date:    2012-08-30
-- ===== Desc:    Script to find open transactions
-- ===== =======================================================================


-- ==== See a count of Active Connections
SELECT  [DBName]                = DB_NAME(dbid),
        [NumberOfConnections]   = COUNT(dbid),
        [LoginName]             = loginame
FROM    sys.sysprocesses
GROUP BY dbid, loginame
ORDER BY DB_NAME(dbid)





-- == Search for active transactions
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysprocesses-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-tran-session-transactions-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-connections-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sql-text-transact-sql?view=sql-server-2017

SELECT  sp.spid,
        ec.most_recent_session_id,
        tst.transaction_id,
        sp.hostprocess,
        sp.program_name,
        sp.hostname,
        sp.loginame,
        sp.login_time,
        sp.last_batch,
        [database]                   =   DB_NAME(sp.dbid),
        [batch_time dd:hh:mi:ss:mmm] =   RIGHT( '00' + CONVERT( VARCHAR(20), DATEDIFF( hh, 0, GETDATE() - sp.last_batch ) / 24 ), 2 ) + ':' +
                                         RIGHT( '00' + CONVERT( VARCHAR(20), DATEDIFF( hh, 0, GETDATE() -sp.last_batch) % 24 ), 2) + ':' +
                                         SUBSTRING( CONVERT( VARCHAR(20), GETDATE() - sp.last_batch, 114 ), 
                                                    CHARINDEX( ':', CONVERT( VARCHAR(20), GETDATE() - sp.last_batch, 114 ) ) + 1, 
                                                               LEN( CONVERT( VARCHAR(20), GETDATE() - sp.last_batch, 114 ) ) ),
        sqlt.text cmd_text,
        sp.cmd,
        sp.status,        
        ec.last_read,
        ec.num_reads,
        ec.last_write,
        ec.num_writes        
FROM    sys.sysprocesses sp
        LEFT OUTER JOIN sys.dm_tran_session_transactions tst
                ON tst.session_id = sp.spid
        LEFT OUTER JOIN sys.dm_exec_connections ec
                ON tst.session_id = ec.session_id
        OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle)sqlt
WHERE   sp.open_tran > 0
ORDER BY sp.last_batch




-- ==== See the sql executing in that session
SELECT  [Database Name] = DB_NAME(tdt.database_id ),
        [Connect Time]  = ec.connect_time,
        [SQL Text]      = sqlt.text
FROM    sys.dm_tran_database_transactions  tdt
        INNER JOIN sys.dm_tran_session_transactions tst
                ON tst.transaction_id = tdt.transaction_id
        INNER JOIN sys.dm_exec_connections ec
                ON tst.session_id = ec.session_id
        CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle)sqlt
ORDER BY DB_NAME(tdt.database_id ) , ec.connect_time




-- ==== SYS.VIEWS with transaction information
SELECT  [Database Name]     = DB_NAME(tds.Database_id),
        [Database ID]       = tds.database_id,
        [Transaction Name]  = tas.name
FROM    sys.dm_tran_active_transactions tas
        INNER JOIN sys.dm_tran_database_transactions tds
                ON (tas.transaction_id = tds.transaction_id )
ORDER BY DB_NAME(tds.Database_id)



-- ==== Command to provide info re a specific db
-- ==== Displays information about the oldest active transaction and the oldest distributed and nondistributed replicated transactions,
-- ==== if any, within the specified database. Results are displayed only if there is an active transaction or if the database contains
-- ==== replication information. An informational message is displayed if there are no active transactions.
-- ==== See BOL http://msdn.microsoft.com/en-us/library/ms182792.aspx
DBCC OPENTRAN




-- ==== Old faithfull
IF OBJECT_ID('tempdb..#Who2') IS NOT NULL
    DROP TABLE #Who2;
CREATE table #Who2 (
    SPIS INT, [Status] varchar(50), [Login] varchar(150), HostName varchar(150),
    BlkBy varchar(150), DBName varchar(150), Command Varchar(1000), CPUTime int,
    DiskIO int, LastBatch varchar(50), ProgramName Varchar(150), SPID int, requestID int
) ;

INSERT INTO #Who2
    EXEC sp_who2 ;

SELECT  *
FROM    #Who2 w
WHERE   DBNAME LIKE 'it247qa1%' 
ORDER BY DBName;




-- ====    Old faithfull on steroids
-- ==== see http://sqlblog.com/blogs/adam_machanic/archive/2012/03/22/released-who-is-active-v11-11.aspx
-- ==== file can be found @ Sky Drive >    Development > SQL > Third Party Tool Box > Adam Machanic > who_is_active_v11_00.sql




-- =============================================================================
-- ==== Information about blocking sessions
-- ==== See http://blog.sqlauthority.com/2010/10/06/sql-server-quickest-way-to-identify-blocking-query-and-resolution-dirty-solution/
SELECT  [DBName]            = db.name,
        [RequestSession]    = lok.request_session_id,
        [BlockingSession]   = wt.blocking_session_id,
        [BlockedObjectName] = OBJECT_NAME(p.OBJECT_ID),
        [ResourceType]      = lok.resource_type,
        [RequestingText]    = h1.TEXT,
        [BlockingTest]      = h2.TEXT,
        [RequestMode]       = lok.request_mode
FROM    sys.dm_tran_locks lok
        INNER JOIN sys.databases db
                ON db.database_id = lok.resource_database_id
        INNER JOIN sys.dm_os_waiting_tasks wt
                ON lok.lock_owner_address = wt.resource_address
        INNER JOIN sys.partitions p
                ON p.hobt_id = lok.resource_associated_entity_id
        INNER JOIN sys.dm_exec_connections ec1
                ON ec1.session_id = lok.request_session_id
        INNER JOIN sys.dm_exec_connections ec2
                ON ec2.session_id = wt.blocking_session_id
        CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) h1
        CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) h2




-- ==== The same can be done using the following sql, but not as elegently
SELECT  *
FROM    master..SYSPROCESSES victim
        INNER JOIN master..SYSPROCESSES lock
                ON lock.spid = victim.blocked
WHERE   victim.blocked != 0

-- ==== http://technet.microsoft.com/en-us/library/ms187730.aspx
DBCC INPUTBUFFER(##Blocked##)




-- =============================================================================
-- ==== Kill the transaction /session
-- ==== http://msdn.microsoft.com/en-GB/library/ms173730.aspx
KILL ?
kill ? with statusonly -- Does not kill only reports on the current status of teh Roollback
