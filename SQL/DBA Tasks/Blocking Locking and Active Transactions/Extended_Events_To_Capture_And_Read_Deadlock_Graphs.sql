-- Create a new event session (it is better to create a new session and not modify the system’s built-in session “system_health”):
CREATE EVENT SESSION [Deadlock_Monitor] ON SERVER
ADD EVENT sqlserver.xml_deadlock_report , -- The deadlock graph
ADD EVENT sqlserver.lock_deadlock (     -- The deadlock
  ACTION( package0.process_id,
          sqlserver.client_app_name,
          sqlserver.client_hostname,
          sqlserver.context_info,
          sqlserver.database_id,
          sqlserver.database_name,
          sqlserver.plan_handle ) ),
ADD EVENT sqlserver.lock_deadlock_chain ( -- The deadlock chain (can be a bit noisy)
  ACTION( package0.process_id,
          sqlserver.client_app_name,
          sqlserver.client_hostname,
          sqlserver.context_info,
          sqlserver.database_id,
          sqlserver.database_name,
          sqlserver.plan_handle ) )
ADD TARGET package0.asynchronous_file_target (SET filename= N'C:\temp\deadlock.xel' )
WITH (  MAX_MEMORY=4096 KB,
        EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY=10 SECONDS,
        MAX_EVENT_SIZE=0 KB,
        MEMORY_PARTITION_MODE=NONE,
        TRACK_CAUSALITY=OFF,
        STARTUP_STATE=ON )


-- Enable the session to start capturing events:
ALTER EVENT SESSION [Deadlock_Monitor] ON SERVER STATE = start;


-- If you want the session to stop capturing events (until you enable the session again), you can use this query:
ALTER EVENT SESSION [Deadlock_Monitor] ON SERVER STATE = stop;


-- If you want to completely remove (delete) the session from the server, you can use this query:
DROP EVENT SESSION [Deadlock_Monitor] ON SERVER


-- To see how many deadlocks have been captured by the session since it started running, you can run this query:
SELECT  COUNT(*)
FROM    sys.fn_xe_file_target_read_file ('c:\temp\deadlock*.xel', 'c:\temp\deadlock*.xem', NULL, NULL)
WHERE   OBJECT_NAME = 'xml_deadlock_report'


-- To get a list of the captured deadlocks and their graphs you can execute this query:
SELECT  xml_data.value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') [Execution_Time],
        xml_data.value('(event/data/value)[1]','varchar(max)') [Query],
        xml_data
FROM  ( SELECT OBJECT_NAME AS [event],
               CONVERT(xml, event_data) AS [xml_data]
        FROM   sys.fn_xe_file_target_read_file ('c:\temp\deadlock*.xel', 'c:\temp\deadlock*.xem', null, null)
        WHERE  OBJECT_NAME = 'xml_deadlock_report' ) v
ORDER BY Execution_Time

-- SSMS can also be used to get the same data and see the graphical deadlock graph




-- Get the deadlock graph from the System health ring buffer
SELECT  [EventTime]     = CAST(x.EventXml.value('(//event/@timestamp)[1]','varchar(50)') AS DATETIME),
        [DeadlockGraph] = CAST(x.EventXml.query('/event/data/value/deadlock') AS XML),
        [Queries]       = x.Queries
FROM (  SELECT  [EventXml]  = CAST(XEventData.XEvent.query('.') AS XML),
                [Queries]   = CAST(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)') AS XML)
        FROM  ( SELECT  CAST(target_data as xml) as TargetData
                FROM    sys.dm_xe_session_targets st
                        INNER JOIN sys.dm_xe_sessions s
                                ON s.address = st.event_session_address
                WHERE   name = 'system_health'  ) AS Data
        CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
WHERE   XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report' ) x
ORDER BY EventTime

