
-- ===  Replace the following text:
--              Date_Version                  - used for distinct naming
--              y:\PathToProfileFiles         - the path to your file
--              profiler*                     - not all profile files use this name. If IT have created them...


-- ===  =========================================================================================================
-- ===  Create a table to hold the event data
CREATE TABLE [dbo].[Trace_Date_Version](
    [Id]              [BIGINT]          NOT NULL IDENTITY(1,1),
    [event_time]      [datetime2](7)        NULL,
    [event_name]      [nvarchar](max)       NULL,
    [transaction_id]  [decimal](38, 0)      NULL,
    [session_id]      [decimal](38, 0)      NULL,
    [process_id]      [decimal](38, 0)      NULL,
    [event_data]      [xml]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO




-- ===  Load said data. - This can take a LONG time and should NOT be run on PROD
INSERT INTO Trace_Date_Version(event_name, event_data)
    SELECT  [event_name] = f.object_name,
            [event_data] = x.event_data
    FROM    sys.fn_xe_file_target_read_file ( 'y:\PathToProfileFiles\profiler*.xel',
                                              'y:\PathToProfileFiles\profiler*.xem', NULL, NULL ) f
            CROSS APPLY (SELECT CAST(f.event_data AS XML) AS event_data) AS x
;



-- ===  =========================================================================================================
-- ===  shred the xml, but only enough so we can filter effectivly later on
UPDATE Trace_Date_Version
   SET event_time     = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), event_data.value('(event/@timestamp)[1]', 'datetime2')),
       transaction_id = event_data.value('(event/action)[@name="transaction_id"][1]', 'decimal(38,0)'),
       session_id     = event_data.value('(event/action)[@name="session_id"][1]', 'decimal(38,0)'),
       process_id     = event_data.value('(event/action)[@name="process_id"][1]', 'decimal(38,0)')
;




-- ===  =========================================================================================================
-- ===  Query the data to get what we want. We are not shreding all of the xml
SELECT  * ,
        [query_hash]      = x.event_data.value('(event/action[@name="query_hash"])[1]', 'decimal(38,0)'),
        [plan_handle]     = x.event_data.value('(event/action[@name="plan_handle"])[1]', 'varbinary(64)'),
        [query_plan_hash] = x.event_data.value('(event/action[@name="query_plan_hash"])[1]', 'decimal(38,0)'),
        [sql_text]        = x.event_data.value('(event/action[@name="sql_text"])[1]', 'nvarchar(max)'),
        [statement]       = x.event_data.value('(event/data[@name="statement"])[1]', 'nvarchar(max)')
INTO    #Profile_Date_Version
FROM    Trace_Date_Version x
--WHERE ?



-- ===  =========================================================================================================
-- ===  High level analysis of the profile session of the time a tx takes and teh time between tx i.e. time spent not in sql
SELECT  transaction_id, MIN(event_time) StartOfTx, MAX(event_time) EndOfTx,  DATEDIFF(MILLISECOND, MIN(event_time), MAX(event_time)) TxDuration
INTO      #Meteric_Date_Version
FROM      #Profile_Date_Version
WHERE     ( sql_text like '%Auto Created by Start of Day%' or statement like '%Auto Created by Start of Day%' )
GROUP BY transaction_id


SELECT  StartOfRun                        = Min(StartOfTx),
            EndOfRun                      = Max(EndOfTx),
            [Tx count]                    = COUNT(transaction_id),
            [Total duration seconds]      = DATEDIFF(MILLISECOND, Min(StartOfTx), Max(EndOfTx)) / 1000.00,
            [Avg time per tx millisecond] = DATEDIFF(MILLISECOND, Min(StartOfTx), Max(EndOfTx)) / COUNT(transaction_id)
FROM      #Meteric_Date_Version


SELECT  transaction_id
      , StartofTx
      , EndOfTx
      , TxDuration
      , [Time untill the next tx starts] = DATEDIFF(MILLISECOND, EndOfTx, LEAD(StartOfTx) OVER(ORDER BY StartOfTx))
FROM      #Meteric_Date_Version
;



-- ===  =========================================================================================================
-- ===  Analysis of the profile
SELECT  Id
      , Event_Time
      , Event_name
      , p.Transaction_id
        , sql_text  = replace(replace(Sql_Text,  char(13), ' '), char(10), ' ') -- Remove new lines, so we can paste into excell
        , Statement = replace(replace(Statement, char(13), ' '), char(10), ' ') -- Remove new lines, so we can paste into excell
FROM      #Profile_Date_Version p
WHERE     p.transaction_id = 2118698813
ORDER BY event_time, Id
;



-- ===  =========================================================================================================
-- ===  Deadlock analysis
; WITH victim1 AS (
    SELECT  *
    FROM    #Profile_Date_Version x
    WHERE   x.transaction_id = 5286142382
    --AND       (  x.statement like '% FinancialTransaction %'
    --      OR x.statement like '%\[FinancialTransaction\] %' ESCAPE  '\'
)

, blocker1 AS (
    SELECT  *
    FROM    #Profile_Date_Version x
    WHERE   x.transaction_id = 5286142129
    --AND       (  x.statement like '% FinancialTransaction %'
    --      OR x.statement like '%\[FinancialTransaction\] %' ESCAPE  '\'  )
)

SELECT  event_time      = COALESCE(v1.event_time, b1.event_time)
      , '5286142129 N'  = b1.event_name
      , '5286142129 Q'  = b1.statement
      , '5286142382 N'  = v1.event_name
      , '5286142382 Q'  = v1.statement
FROM    blocker1 b1
        FULL OUTER JOIN victim1 v1
                    ON v1.event_time = b1.event_time
ORDER BY COALESCE(v1.event_time, b1.event_time)
;





-- ===  =========================================================================================================
SELECT  cp.plan_handle, st.text, qp.query_plan
FROM    sys.dm_exec_cached_plans cp
        CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
        OUTER APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE   plan_handle in ( 0x0300160079cd756d26a4220170a3000001000000000000000000000000000000000000000000000000000000,
                         0x02000000f269eb04bf54cbf976d91331985badc98f6b13e70000000000000000000000000000000000000000,
                         0x02000000c92d9224d3240c4fea7bc4cc4416168d7a468ec70000000000000000000000000000000000000000,
                         0x020000007bc7bc2dd3fee97a4a1d7fc4500c49d327c844a40000000000000000000000000000000000000000,
                         0x02000000f9642a34a2f136d8560c7acd684c9c9ebb6104020000000000000000000000000000000000000000,
                         0x0300160052ad5761feaed90031a3000001000000000000000000000000000000000000000000000000000000,
                         0x02000000c92d9224d3240c4fea7bc4cc4416168d7a468ec70000000000000000000000000000000000000000,
                         0x0300160052ad5761feaed90031a3000001000000000000000000000000000000000000000000000000000000 )

