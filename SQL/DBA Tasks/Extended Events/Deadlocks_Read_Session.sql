/*
    Replace the following values:
        C:\Foo    =>    the actual path to save the file e.g. \\505295-SSCLUQA\Extended_Events
                                                              \\505281-ssclutr\Extended_Events
*/

-- ===  ==============================================================================================================================  === --

-- ===  To see how many deadlocks have been captured by the session since it started running, you can run this query:
SELECT  COUNT(*)
FROM    sys.fn_xe_file_target_read_file ('C:\Foo\Deadlock_Monitor*.xel', 'C:\Foo\Deadlock_Monitor.xem', NULL, NULL)
WHERE   OBJECT_NAME = 'xml_deadlock_report'


-- ===  To get a list of the captured deadlocks and their graphs you can execute this query:
-- ===  Select the database id you wish to query or leave NULL
DECLARE @DbId INT = 79

SELECT  xml_data.value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime') [Execution_Time],
        xml_data.value('(event/data/value)[1]','varchar(max)') [Query],
        xml_data.query('/event/data/value/deadlock')
FROM  ( SELECT OBJECT_NAME AS [event],
               CONVERT(xml, event_data) AS [xml_data]
        FROM   sys.fn_xe_file_target_read_file ('C:\Foo\Deadlock_Monitor*.xel', 'C:\Foo\Deadlock_Monitor.xem', null, null)
        WHERE  OBJECT_NAME = 'xml_deadlock_report' ) v
WHERE   ( @DbId IS NULL OR xml_data.value('(/event/data/value/deadlock/process-list/process[1]/@currentdb)[1]', 'int') = @DbId )
ORDER BY Execution_Time


-- ===  ==============================================================================================================================  === --



-- ===  Get the deadlock graph from the System health ring buffer
-- ===  This can be VERY little slow
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

