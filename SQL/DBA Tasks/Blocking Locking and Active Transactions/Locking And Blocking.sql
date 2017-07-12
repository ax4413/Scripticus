
-- ==============================================================================================================================================================================
-- ====    sys.dm_tran_locks Help:        http://technet.microsoft.com/en-us/library/ms190345.aspx                =====================================================================
-- ====    Lock Compatability Help:    http://technet.microsoft.com/en-us/library/ms186396(v=sql.105).aspx        =====================================================================
-- ==============================================================================================================================================================================


-- ==== This query will show you your locks for a given transaction
; WITH TxLocks AS (
    SELECT  [Resource_Type]         = dtl.resource_type,
            [Request_Mode]          = dtl.request_mode,
            [Locked_Object]         = CASE  WHEN dtl.resource_type = 'KEY' THEN object_name(sp.object_id)
                                            WHEN dtl.resource_type = 'PAGE' THEN object_name(sp.object_id)
                                            WHEN dtl.resource_type = 'RID' THEN object_name(sp.object_id)
                                            WHEN dtl.resource_type = 'HOBT' THEN object_name(sp.object_id)
                                            WHEN dtl.resource_type = 'OBJECT' THEN object_name(DTL.resource_associated_entity_id)
                                            ELSE NULL END ,
            [Request_Type]          = dtl.Request_Type ,
            [Request_Status]        = dtl.Request_Status ,
            [Resource_Description]  = dtl.Resource_Description ,
            [Locked_Index]          = ix.name,
            [Index_type]            = ix.type_desc,
            [SqlStatementText]      = ST.text ,
            [LoginName]             = ES.login_name ,
            [HostName]              = ES.host_name ,
            [IsUserTransaction]     = TST.is_user_transaction ,
            [TransactionName]       = AT.name ,
            [AuthenticationMethod]  = CN.auth_scheme ,
            [Locked_Entity_ID]      = dtl.resource_associated_entity_id,
            [Request_Session_Id]    = dtl.request_session_id,
            [Request_Owner_ID]      = dtl.Request_Owner_Id ,
            [Partition_ID]          = sp.partition_id ,
            [Object_ID]             = sp.object_id ,
            [Index_ID]              = sp.index_id ,
            [Partition_Number]      = sp.partition_number ,
            [Hobt_ID]               = sp.hobt_id
    FROM    sys.dm_tran_locks dtl
            LEFT OUTER JOIN sys.partitions sp
                    ON sp.hobt_id = dtl.resource_associated_entity_id
                        AND dtl.resource_type IN('KEY','PAGE', 'RID', 'HOBT')
            LEFT OUTER JOIN sys.objects o
                    ON o.object_id = sp.object_id
            INNER JOIN sys.dm_exec_sessions es
                    ON es.session_id = dtl.request_session_id
            INNER JOIN sys.dm_tran_session_transactions tst
                    ON es.session_id = tst.session_id
            INNER JOIN sys.dm_tran_active_transactions at
                    ON tst.transaction_id = at.transaction_id
            LEFT OUTER JOIN sys.dm_exec_connections cn
                    ON cn.session_id = es.session_id
            LEFT OUTER JOIN SYS.indexes ix
                    ON ix.object_id = o.object_id
                        AND ix.index_id = sp.index_id
            CROSS APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) AS ST
    WHERE   dtl.resource_database_id = DB_ID()    -- This database
)

-- ==== Query the indexes how you like. A temp table may be more helpfull for you
SELECT  *
FROM    TxLocks txl
ORDER BY txl.Locked_Object ,
        txl.resource_type ,
        txl.Locked_Index ,
        txl.request_mode ,
        txl.Resource_Description ;


-- ==============================================================================================================================================================================


-- ==== Show blocking
SELECT  t1.resource_type,
        t1.resource_database_id,
        t1.resource_associated_entity_id,
        t1.request_mode,
        t1.request_session_id,
        t2.blocking_session_id
FROM    sys.dm_tran_locks as t1
        INNER JOIN sys.dm_os_waiting_tasks as t2
            ON t1.lock_owner_address = t2.resource_address;
