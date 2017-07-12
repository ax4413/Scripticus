-- ==== User Statistics Report
SELECT  row_num                 = ( DENSE_RANK() OVER ( ORDER BY login_name ,nt_user_name ) ) % 2,
        session_num             = ( ROW_NUMBER() OVER ( ORDER BY login_name ,nt_user_name, sessions.session_id ) ) % 2 ,
        login_name              = login_name,
        nt_user_name            = nt_user_name,
        session_id              = sessions.session_id,
        connection_count        = COUNT( DISTINCT connections.connection_id) ,
        request_count           = COUNT( DISTINCT CONVERT( CHAR, sessions.session_id) + '_' + CONVERT( CHAR, requests.request_id)),
        cursor_count            = COUNT( DISTINCT cursors.cursor_id),
        transaction_count       = CASE WHEN SUM( requests.open_tran) IS NULL THEN 0 ELSE SUM( requests.open_tran) END,
        cpu_time                = sessions.cpu_time + 0.0,
        memory_usage            = sessions.memory_usage * 8,
        reads                   = sessions.reads,
        writes                  = sessions.writes,
        last_request_start_time = sessions.last_request_start_time,
        last_request_end_time   = sessions.last_request_end_time
FROM    sys.dm_exec_sessions sessions
        LEFT OUTER JOIN sys.dm_exec_connections connections
                ON sessions.session_id = connections.session_id
        LEFT OUTER JOIN MASTER..sysprocesses requests
                ON sessions.session_id = requests.spid
        LEFT OUTER JOIN sys.dm_exec_cursors(NULL) cursors
                ON sessions.session_id = cursors.session_id
WHERE   ( sessions.is_user_process = 1
        AND requests.dbid = DB_ID() )
GROUP BY sessions.login_name
        ,sessions.nt_user_name
        ,sessions.session_id
        ,sessions.cpu_time
        ,sessions.memory_usage
        ,sessions.reads
        ,sessions.writes
        ,sessions.last_request_start_time
        ,sessions.last_request_end_time



EXEC xp_logininfo 'ICENET\Irene.Hall','all';