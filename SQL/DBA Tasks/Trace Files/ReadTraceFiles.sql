SELECT  *
INTO    Trace
FROM    fn_trace_gettable('C:\Temp\Activation_Multithread_5.trc', default)


SELECT  SPID, TE.Name, DatabaseName, StartTime, EndTime, Duration, TextData, ObjectId, ClientProcessId, Reads, Writes, CPU
FROM    Trace T
        LEFT OUTER JOIN sys.trace_events TE
                ON T.EventClass = TE.trace_event_id
ORDER BY StartTime ASC
