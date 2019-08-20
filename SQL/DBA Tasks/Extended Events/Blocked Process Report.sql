--  =======================================================================================================
--  Find and replace with valid writable paths:
--        C:\Foo    =>    the actual path to save the file e.g. \\505295-SSCLUQA\Extended_Events
--                                                              \\505281-ssclutr\Extended_Events
--
--  http://www.brentozar.com/sql/locking-and-blocking-in-sql-server/
--  http://michaeljswart.com/2011/04/a-new-way-to-examine-blocked-process-reports/
--  =======================================================================================================



/*  -------------------------------------------------------------------------------------------------------
    Create a extended event to catch blocked processes on a instance                                        */

CREATE EVENT SESSION [blocked_process] ON SERVER
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,
           sqlserver.client_hostname,
           sqlserver.database_name)) ,
ADD EVENT sqlserver.xml_deadlock_report (
    ACTION(sqlserver.client_app_name,
           sqlserver.client_hostname,
           sqlserver.database_name))
ADD TARGET package0.asynchronous_file_target
(SET filename = N'C:\Foo\blocked_process.xel',
     metadatafile = N'C:\Foo\blocked_process.xem',
     max_file_size=(65536),
     max_rollover_files=5)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
GO



/*  -------------------------------------------------------------------------------------------------------
    Make sure this path exists before you start the trace!                                                  */

EXEC sp_configure 'show advanced options', 1 ;
GO
RECONFIGURE ;
GO

-- ===  Enabled the blocked process report
EXEC sp_configure 'blocked process threshold', '5';
RECONFIGURE
GO

-- ===  Enable the session to start capturing events:
ALTER EVENT SESSION [blocked_process] ON SERVER STATE = start;
GO

-- ===  If you want the session to stop capturing events (until you enable the session again)
ALTER EVENT SESSION [blocked_process] ON SERVER STATE = stop;
GO

-- ===  If you want to completely remove (delete) the session from the server
DROP EVENT SESSION [blocked_process] ON SERVER
GO



/*  -------------------------------------------------------------------------------------------------------
    Create the stored procedure and table to convert the blocked process report into a readable format          */
USE master
GO


IF NOT EXISTS(SELECT * FROM SYS.TABLES WHERE NAME = 'bpr') BEGIN
    CREATE TABLE bpr (
        EndTime DATETIME,
        TextData XML,
        EventClass INT DEFAULT(137)
    );
END
GO


IF OBJECT_ID('sp_blocked_process_report_viewer') IS NULL
	 EXEC ('CREATE PROCEDURE dbo.sp_blocked_process_report_viewer AS SELECT ''Replace Me''')
GO

ALTER PROCEDURE dbo.sp_blocked_process_report_viewer
(
  	@Trace nvarchar(max),
  	@Type varchar(10) = 'FILE'
)
AS
  SET NOCOUNT ON

  -- Validate @Type
  IF (@Type NOT IN ('FILE', 'TABLE', 'XMLFILE'))
	  RAISERROR ('The @Type parameter must be ''FILE'', ''TABLE'' or ''XMLFILE''', 11, 1)

  IF (@Trace LIKE '%.trc' AND @Type <> 'FILE')
	  RAISERROR ('Warning: You specified a .trc trace. You should also specify @Type = ''FILE''', 10, 1)

  IF (@Trace LIKE '%.xml' AND @Type <> 'XMLFILE')
	  RAISERROR ('Warning: You specified a .xml trace. You should also specify @Type = ''XMLFILE''', 10, 1)


  CREATE TABLE #ReportsXML (
	    monitorloop nvarchar(100) NOT NULL,
	    endTime datetime NULL,
	    blocking_spid INT NOT NULL,
	    blocking_ecid INT NOT NULL,
	    blocked_spid INT NOT NULL,
	    blocked_ecid INT NOT NULL,
	    blocked_hierarchy_string as CAST(blocked_spid as varchar(20)) + '.' + CAST(blocked_ecid as varchar(20)) + '/',
	    blocking_hierarchy_string as CAST(blocking_spid as varchar(20)) + '.' + CAST(blocking_ecid as varchar(20)) + '/',
	    bpReportXml xml not null,
	    primary key clustered (monitorloop, blocked_spid, blocked_ecid),
	    unique nonclustered (monitorloop, blocking_spid, blocking_ecid, blocked_spid, blocked_ecid)
  )

  DECLARE @SQL NVARCHAR(max);
  DECLARE @TableSource nvarchar(max);

  -- define source for table
  IF (@Type = 'TABLE')
  BEGIN
	  -- everything input by users get quoted
	  SET @TableSource = ISNULL(QUOTENAME(PARSENAME(@Trace,4)) + N'.', '')
		  + ISNULL(QUOTENAME(PARSENAME(@Trace,3)) + N'.', '')
		  + ISNULL(QUOTENAME(PARSENAME(@Trace,2)) + N'.', '')
		  + QUOTENAME(PARSENAME(@Trace,1));
  END

  -- define source for trc file
  IF (@Type = 'FILE')
  BEGIN
	  SET @TableSource = N'sys.fn_trace_gettable(N' + QUOTENAME(@Trace, '''') + ', -1)';
  END

  -- load table or file
  IF (@Type IN ('TABLE', 'FILE'))
  BEGIN
	  SET @SQL = N'
		  INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			  monitorloop,bpReportXml,endTime)
		  SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			  COALESCE(monitorloop, CONVERT(nvarchar(100), endTime, 120), ''unknown''),
			  bpReportXml,EndTime
		  FROM ' + @TableSource + N'
		  CROSS APPLY (
			  SELECT CAST(TextData as xml)
			  ) AS bpReports(bpReportXml)
		  CROSS APPLY (
			  SELECT
				  monitorloop = bpReportXml.value(''(//@monitorLoop)[1]'', ''nvarchar(100)''),
				  blocked_spid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@spid)[1]'', ''int''),
				  blocked_ecid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@ecid)[1]'', ''int''),
				  blocking_spid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@spid)[1]'', ''int''),
				  blocking_ecid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@ecid)[1]'', ''int'')
			  ) AS bpShredded
		  WHERE EventClass = 137';

	  EXEC (@SQL);
  END

  IF (@Type = 'XMLFILE')
  BEGIN
	  CREATE TABLE #TraceXML (
		  id int identity primary key,
		  ReportXML xml NOT NULL
	  )

	  SET @SQL = N'
		  INSERT #TraceXML(ReportXML)
		  SELECT col FROM OPENROWSET (
				  BULK ' + QUOTENAME(@Trace, '''') + N', SINGLE_BLOB
			  ) as xmldata(col)';

	  EXEC (@SQL);

	  CREATE PRIMARY XML INDEX PXML_TraceXML ON #TraceXML(ReportXML);

	  WITH XMLNAMESPACES
	  (
		  'http://tempuri.org/TracePersistence.xsd' AS MY
	  ),
	  ShreddedWheat AS
	  (
		  SELECT
			  bpShredded.blocked_ecid,
			  bpShredded.blocked_spid,
			  bpShredded.blocking_ecid,
			  bpShredded.blocking_spid,
			  bpShredded.monitorloop,
			  bpReports.bpReportXml,
			  bpReports.bpReportEndTime
		  FROM #TraceXML
		  CROSS APPLY
			  ReportXML.nodes('/MC:\FooTraceData/MC:\FooEvents/MC:\FooEvent[@name="Blocked process report"]')
			  AS eventNodes(eventNode)
		  CROSS APPLY
			  eventNode.nodes('./MC:\FooColumn[@name="EndTime"]')
			  AS endTimeNodes(endTimeNode)
		  CROSS APPLY
			  eventNode.nodes('./MC:\FooColumn[@name="TextData"]')
			  AS bpNodes(bpNode)
		  CROSS APPLY (
			  SELECT CAST(bpNode.value('(./text())[1]', 'nvarchar(max)') as xml),
				  CAST(LEFT(endTimeNode.value('(./text())[1]', 'varchar(max)'), 19) as datetime)
		  ) AS bpReports(bpReportXml, bpReportEndTime)
		  CROSS APPLY (
			  SELECT
				  monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				  blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
				  blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
				  blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
				  blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
		  ) AS bpShredded
	  )
	  INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
		  monitorloop,bpReportXml,endTime)
	  SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
		  COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), 'unknown'),
		  bpReportXml,bpReportEndTime
	  FROM ShreddedWheat;

	  DROP TABLE #TraceXML

  END

  -- Organize and select blocked process reports
  ;WITH Blockheads AS
  (
	  SELECT blocking_spid, blocking_ecid, monitorloop, blocking_hierarchy_string
	  FROM #ReportsXML
	  EXCEPT
	  SELECT blocked_spid, blocked_ecid, monitorloop, blocked_hierarchy_string
	  FROM #ReportsXML
  ),
  Hierarchy AS
  (
	  SELECT monitorloop, blocking_spid as spid, blocking_ecid as ecid,
		  cast('/' + blocking_hierarchy_string as varchar(max)) as chain,
		  0 as level
	  FROM Blockheads

	  UNION ALL

	  SELECT irx.monitorloop, irx.blocked_spid, irx.blocked_ecid,
		  cast(h.chain + irx.blocked_hierarchy_string as varchar(max)),
		  h.level+1
	  FROM #ReportsXML irx
	  JOIN Hierarchy h
		  ON irx.monitorloop = h.monitorloop
		  AND irx.blocking_spid = h.spid
		  AND irx.blocking_ecid = h.ecid
  )
  SELECT
	  ISNULL(CONVERT(nvarchar(30), irx.endTime, 120),
		  'Lead') as traceTime,
	  SPACE(4 * h.level)
		  + CAST(h.spid as varchar(20))
		  + CASE h.ecid
			  WHEN 0 THEN ''
			  ELSE '(' + CAST(h.ecid as varchar(20)) + ')'
		  END AS blockingTree,
	  irx.bpReportXml
  from Hierarchy h
  left join #ReportsXML irx
	  on irx.monitorloop = h.monitorloop
	  and irx.blocked_spid = h.spid
	  and irx.blocked_ecid = h.ecid
  order by h.monitorloop, h.chain

  DROP TABLE #ReportsXML
GO





/*  -------------------------------------------------------------------------------------------------------
    Its time to view the data                                                                               */


-- === Method 1 ===========================================================================================
WITH events_cte AS (
  SELECT
    xevents.event_data,
    DATEADD(mi,
    DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
    xevents.event_data.value(
      '(event/@timestamp)[1]', 'datetime2')) AS [event time] ,
    xevents.event_data.value(
      '(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(128)')
      AS [client app name],
    xevents.event_data.value(
      '(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(max)')
      AS [client host name],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="database_name"]/value)[1]', 'nvarchar(max)')
      AS [database name],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="database_id"]/value)[1]', 'int')
      AS [database_id],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="object_id"]/value)[1]', 'int')
      AS [object_id],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="index_id"]/value)[1]', 'int')
      AS [index_id],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="duration"]/value)[1]', 'bigint') / 1000
      AS [duration (ms)],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="lock_mode"]/text)[1]', 'varchar')
      AS [lock_mode],
    xevents.event_data.value(
      '(event[@name="blocked_process_report"]/data[@name="login_sid"]/value)[1]', 'int')
      AS [login_sid],
    xevents.event_data.query(
      '(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report)[1]')
      AS blocked_process_report,
    xevents.event_data.query(
      '(event/data[@name="xml_report"]/value/deadlock)[1]')
      AS deadlock_graph
  FROM    sys.fn_xe_file_target_read_file (
            'C:\Foo\blocked_process*.xel',
            'C:\Foo\blocked_process*.xem',
            null, null)
    CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) as xevents
)
SELECT
  CASE WHEN blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NULL
       THEN 'Deadlock'
       ELSE 'Blocked Process'
       END AS ReportType,
  [event time],
  CASE [client app name] WHEN '' THEN ' -- N/A -- '
                         ELSE [client app name]
                         END AS [client app _name],
  CASE [client host name] WHEN '' THEN ' -- N/A -- '
                          ELSE [client host name]
                          END AS [client host name],
  [database name],
  COALESCE(OBJECT_SCHEMA_NAME(object_id, database_id), ' -- N/A -- ') AS [schema],
  COALESCE(OBJECT_NAME(object_id, database_id), ' -- N/A -- ') AS [table],
  index_id,
  [duration (ms)],
  lock_mode,
  COALESCE(SUSER_NAME(login_sid), ' -- N/A -- ') AS username,
  CASE WHEN blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NULL
       THEN deadlock_graph
       ELSE blocked_process_report
       END AS Report
FROM events_cte
ORDER BY [event time] DESC ;


-- === Method 2 ===========================================================================================
SELECT  *
FROM    sys.fn_xe_file_target_read_file (
            'C:\Foo\blocked_process*.xel'
          , 'C:\Foo\blocked_process*.xem'
          , null
          , null)




-- === Method 3 View the data using the blocked process report tool =======================================
TRUNCATE TABLE bpr

WITH events_cte AS (
    SELECT
        DATEADD(mi,
        DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
        xevents.event_data.value('(event/@timestamp)[1]',
           'datetime2')) AS [event_time] ,
        xevents.event_data.query('(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report)[1]')
            AS blocked_process_report
    FROM    sys.fn_xe_file_target_read_file (
                'C:\Foo\blocked_process*.xel',
                'C:\Foo\blocked_process*.xem',
                null, null)
        CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) as xevents
)
-- SELECT * FROM events_cte


INSERT INTO   bpr (EndTime, TextData)
     SELECT   [event_time],
              blocked_process_report
       FROM   events_cte
      WHERE   blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NOT NULL
   ORDER BY  [event_time] DESC ;


EXEC sp_blocked_process_report_viewer @Trace='bpr', @Type='TABLE';







