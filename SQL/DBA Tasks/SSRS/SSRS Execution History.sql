/* ===========================================================================================================================================

    This script contains a number of seperate queries to provide some insight into our SSRS server
       Q1 - Subscriptions         - http://jasonbrimhall.info/2013/01/07/ssrs-subscriptions-report/ it has since been extended considerably
       Q2 - Execution history
       Q3 - Data source details   - http://sqlmentalist.com/2013/09/25/bi-sql-174-sql-server-dba-scripts-list-connection-strings-of-all-ssrs-shared-data-sources/
       Q4 - Data source useage    - http://stackoverflow.com/questions/9638431/listing-all-data-sources-and-their-dependencies-reports-items-etc-in-sql-ser
       Q5 - server configuration

   ======================================================================================================================================== */

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



DECLARE @ClientName          VARCHAR(100) = 'VirginMedia'
      , @ReportName          VARCHAR(100) = 'Transactions and Fees Data Extract'
      , @ExecutionTimeStart  DATETIME     = NULL -- '20160310'
      , @ExecutionTimeEnd    DATETIME     = NULL
      , @ExecutionStatus     VARCHAR(100) = NULL

--SELECT DISTINCT Path FROM catalog WHERE path LIKE '%' + @ClientName + '%' ORDER BY 1

-- ===  Query 1
IF ( OBJECT_ID('tempdb.dbo.#morepower') IS NOT NULL )
  DROP TABLE #morepower;

CREATE TABLE #morepower (
     MonthDate BIGINT,
     N BIGINT,
     PowerN BIGINT PRIMARY KEY CLUSTERED,
     NameofMonth VARCHAR(25),
     WkDay VARCHAR(25))
;


WITH powers(powerN, n) AS (
    SELECT  POWER(2,number), number
    FROM    master.dbo.spt_values
    WHERE   type = 'P'
            AND number < 31
)
--SELECT * FROM powers /*

INSERT INTO #morepower ( MonthDate, N, PowerN ,NameofMonth ,WkDay)
  SELECT  ROW_NUMBER() OVER (ORDER BY N) AS MonthDate,
          N,PowerN,
          CASE WHEN N BETWEEN 0 AND 11
            THEN DateName(month,DATEADD(month,N+1,0)-1)
            ELSE NULL
            END AS NameofMonth,
          CASE WHEN N BETWEEN 0 AND 6
            THEN DATENAME(weekday,DATEADD(DAY,n+1,0)-2)
            ELSE NULL
            END AS WkDay
  FROM  powers

-- ===  Subscription Details
SELECT  DISTINCT
        [ClientName]                = CA.ClientName
      , [ReportName]                = Ca.ReportName
      , [SubscriptionCreator]       = U.UserName
      , [SubscriptionDescription]   = Su.Description
      , [StartDate]                 = S.StartDate
      , [LastRunTime]               = Su.LastRunTime
      , [LastRunStatus]             = su.LastStatus
      , [RecurrenceType]            = CASE WHEN s.RecurrenceType = 1 THEN 'One Off'
                                            WHEN s.RecurrenceType = 2 THEN 'Hour'
                                            WHEN s.RecurrenceType = 4 THEN 'Daily'
                                            WHEN s.RecurrenceType = 5 THEN 'Monthly'
                                            WHEN s.RecurrenceType = 6 THEN 'Week of Month' END
      , [EventType]                 = s.EventType
      , [DaysofMonth]               = ISNULL( REPLACE( REPLACE( STUFF( ( SELECT  ', ['+CONVERT(VARCHAR(20),MonthDate)+']' AS [text()]
                                                                         FROM    #morepower m1
                                                                         WHERE   m1.powerN < s.DaysofMonth+1
                                                                                 AND s.DaysofMonth & m1.powerN <> 0
                                                                         ORDER BY N FOR XML PATH(''), TYPE).value('.','VARCHAR(MAX)')
                                      , 1, 2, ''), '[', ''), ']', ''), 'N/A')
      , [MonthString]               = ISNULL(c1.NameOfMonth,'N/A')
      , [DaysofWeek]                = ISNULL(cds.WkDays,'N/A')
      , [MonthlyWeek]               = CASE MonthlyWeek WHEN 1 THEN 'First'
                                                       WHEN 2 THEN 'Second'
                                                       WHEN 3 THEN 'Third'
                                                       WHEN 4 THEN 'Fourth'
                                                       WHEN 5 THEN 'Last'
                                                       ELSE 'N/A' END
      , [DaysInterval]              = ISNULL(CONVERT(VARCHAR(10),s.DaysInterval),'N/A')
      , [MinutesInterval]           = ISNULL(CONVERT(VARCHAR(10),s.MinutesInterval),'N/A')
      , [WeeksInterval]             = ISNULL(CONVERT(VARCHAR(10),s.WeeksInterval),'N/A')
      , [ReportManagerPath]         = Ca.Path
      , [ScheduleID]                = s.ScheduleID
      , [SubscriptionId]            = su.SubscriptionId
      , [ReportId]                  = rs.ReportId
      , [DataSourceLinkId]          = ds.Link
      , [DataSourcePath]            = dsc.Path
      , [StartSubscriptionSql]      = 'EXEC dbo.AddEvent @EventType=''Timedsubscription'', @EventData='+ QUOTENAME(CAST(su.SubscriptionId AS VARCHAR(38)), CHAR(39)) +''
  FROM  #morepower mp,
        dbo.Schedule s
        INNER JOIN ReportSchedule RS
                ON S.ScheduleID = RS.ScheduleID
        INNER JOIN (   SELECT [ItemId]      = ItemId
                            , [ReportName]  = Name
                            , [Path]        = Path
                            --, [Reversed]    = REVERSE(Path)
                            --, [Pos1]        = CHARINDEX('/', REVERSE(Path), 0) + 1
                            --, [Pos2]        = ABS(( CHARINDEX('/', REVERSE(Path), CHARINDEX('/', REVERSE(Path), 0)+1) ) - ( CHARINDEX('/', REVERSE(Path), 0) + 1) )
                            --, [SubString]   = SUBSTRING( REVERSE(Path), CHARINDEX('/', REVERSE(Path), 0) + 1, ABS(( CHARINDEX('/', REVERSE(Path), CHARINDEX('/', REVERSE(Path), 0)+1) ) - ( CHARINDEX('/', REVERSE(Path), 0) + 1) ) )
                            , [ClientName]  = REVERSE( SUBSTRING( REVERSE(Path), CHARINDEX('/', REVERSE(Path), 0) + 1, ABS(( CHARINDEX('/', REVERSE(Path), CHARINDEX('/', REVERSE(Path), 0)+1) ) - ( CHARINDEX('/', REVERSE(Path), 0) + 1) ) ) )
                      FROM    Catalog ) Ca
                ON Ca.ItemID = RS.ReportID
        INNER JOIN Subscriptions Su
                ON Su.SubscriptionID = RS.SubscriptionID
        INNER JOIN Users U
                ON U.UserID = S.CreatedById
                OR U.UserID = Su.OwnerID
        CROSS APPLY ( SELECT s.ScheduleID,
                              REPLACE( REPLACE( STUFF( (  SELECT  ', ['+ NameofMonth + ']' AS [text()]
                                                          FROM    #morepower m1 ,
                                                                  dbo.Schedule s1
                                                          WHERE   m1.NameofMonth IS NOT NULL
                                                                  AND m1.powerN & s1.Month <> 0
                                                                  AND s1.ScheduleID = s.ScheduleID
                                                          ORDER BY N FOR XML PATH(''), TYPE).value('.','VARCHAR(MAX)')
                              , 1, 2, ''),'[',''),']','') AS NameOfMonth) c1
        CROSS APPLY ( SELECT  s.ScheduleID,
                              REPLACE( REPLACE( STUFF( ( SELECT  ', [' + WkDay + ']' AS [text()]
                                                          FROM    #morepower m1 ,
                                                                  dbo.Schedule s2
                                                          WHERE   m1.WkDay IS NOT NULL
                                                                  AND DaysOfWeek & m1.powerN <> 0
                                                                  AND  s2.ScheduleID = s.ScheduleID
                                                          ORDER BY N FOR XML PATH(''), TYPE).value('.','VARCHAR(MAX)')
                              , 1, 2, ''),'[',''),']','') AS WkDays) cds
        LEFT OUTER JOIN DataSource ds
                ON ds.SubscriptionID = su.SubscriptionID
        LEFT OUTER JOIN Catalog dsc
                on dsc.ItemID = ds.Link
WHERE  ( @ClientName         IS NULL OR ClientName LIKE '%' + @ClientName + '%' )
  AND  ( @ReportName         IS NULL OR ReportName LIKE '%' + @ReportName + '%' )
  AND  ( @ExecutionStatus    IS NULL OR Su.LastStatus      = @ExecutionStatus )
  AND  ( @ExecutionTimeStart IS NULL OR Su.LastRunTime    >= @ExecutionTimeStart )
  AND  ( @ExecutionTimeEnd   IS NULL OR Su.LastRunTime    <= @ExecutionTimeEnd )
ORDER BY ClientName, ReportName, Su.LastRunTime DESC




-- ===========================================================================================================================================
-- ===  Query 2 - Execution history and the paramater that the reports were executed with
IF ( OBJECT_ID('tempdb.dbo.#ReportHistory') IS NOT NULL )
  DROP TABLE #ReportHistory;
IF ( OBJECT_ID('tempdb.dbo.#FilterdData') IS NOT NULL )
  DROP TABLE #FilterdData;

; WITH ReportData AS (
    SELECT   [ClientName]              = REPLACE(PARSENAME(REPLACE(RIGHT(e.ItemPath, LEN(e.ItemPath)-1), '/', '.'),2), 'Exec-', '')
        , [ReportName]              = PARSENAME(REPLACE(RIGHT(e.ItemPath, LEN(e.ItemPath)-1), '/', '.'),1)
        , [TimeStart]               = e.[TimeStart]
        , [TimeEnd]                 = e.[TimeEnd]
        , [RequestType]             = e.[RequestType]
        , [Format]                  = e.[Format]
        , [Status]                  = e.[Status]
        , [ExecutionId]             = e.[ExecutionId]
        , [ItemAction]              = e.[ItemAction]
        , [TimeDataRetrieval]       = e.[TimeDataRetrieval]
        , [TimeProcessing]          = e.[TimeProcessing]
        , [TimeRendering]           = e.[TimeRendering]
        , [Source]                  = e.[Source]
        , [ByteCount]               = e.[ByteCount]
        , [RowCount]                = e.[RowCount]
        , [InstanceName]            = e.[InstanceName]
        , [UserName]                = e.[UserName]
        , [AdditionalInfo]          = e.[AdditionalInfo]
        , [ParamaterString]         = REPLACE(REPLACE(REPLACE(REPLACE(cast(e.Parameters as nvarchar(max)), '%2F', '/'),'%3A',':'), '%20', ' '), '&', ', ' + CHAR(13) + CHAR(10))
        , [ParamaterXml]            = CAST (N'<h><r>' + REPLACE(REPLACE(REPLACE(REPLACE(cast(e.Parameters as nvarchar(max)), '%2F', '/'),'%3A',':'), '%20', ' '), '&', '</r><r>')  + '</r></h>' AS XML)
        , [CatalogueExecutionFlag]  = c.executionFlag
        , [CatalogueParamater]      = c.Parameter
        , [CatalogueProperty]       = c.property
        , [CatalogueType]           = c.type
        , [CataloguePath]           = c.path
    FROM  ExecutionLog3 e
          INNER JOIN ExecutionLogStorage els
                  ON els.ExecutionId = e.ExecutionId
                  AND els.TimeStart  = e.TimeStart
                  AND els.TimeEnd    = e.TimeEnd
          INNER JOIN catalog c
                  ON els.reportID = c.itemID
    WHERE ( @ExecutionStatus    IS NULL OR e.Status      = @ExecutionStatus )
      AND ( @ExecutionTimeStart IS NULL OR e.TimeStart  >= @ExecutionTimeStart )
      AND ( @ExecutionTimeEnd   IS NULL OR e.TimeEnd    <= @ExecutionTimeEnd )
)

SELECT  [Id] = IDENTITY( INT, 1 , 1) , *
INTO    #FilterdData
FROM    ReportData
WHERE   ( @ClientName         IS NULL OR ClientName LIKE '%' + @ClientName + '%' )
  AND   ( @ReportName         IS NULL OR ReportName LIKE '%' + @ReportName + '%' )


SELECT  DISTINCT ID,       
        [ClientName]
      , [ReportName]
      , [TimeStart]
      , [TimeEnd]
      , [RequestType]
      , [Format]
      , [Status]
      , [ExecutionId]
      , [ItemAction]
      , [TimeDataRetrieval]
      , [TimeProcessing]
      , [TimeRendering]
      , [Source]
      , [ByteCount]
      , [RowCount]
      , [InstanceName]
      , [UserName]
      , [Param1]  = ISNULL(param.value('(/h/r)[1]'  , 'varchar(150)'), '      -')
      , [Param2]  = ISNULL(param.value('(/h/r)[2]'  , 'varchar(150)'), '      -')
      , [Param3]  = ISNULL(param.value('(/h/r)[3]'  , 'varchar(150)'), '      -')
      , [Param4]  = ISNULL(param.value('(/h/r)[4]'  , 'varchar(150)'), '      -')
      , [Param5]  = ISNULL(param.value('(/h/r)[5]'  , 'varchar(150)'), '      -')
      , [Param6]  = ISNULL(param.value('(/h/r)[6]'  , 'varchar(150)'), '      -')
      , [Param7]  = ISNULL(param.value('(/h/r)[7]'  , 'varchar(150)'), '      -')
      , [Param8]  = ISNULL(param.value('(/h/r)[8]'  , 'varchar(150)'), '      -')
      , [Param9]  = ISNULL(param.value('(/h/r)[9]'  , 'varchar(150)'), '      -')
      , [Param10] = ISNULL(param.value('(/h/r)[10]' , 'varchar(150)'), '      -')
      , [Param11] = ISNULL(param.value('(/h/r)[11]' , 'varchar(150)'), '      -')
      , [Param12] = ISNULL(param.value('(/h/r)[12]' , 'varchar(150)'), '      -')
      , [Param13] = ISNULL(param.value('(/h/r)[13]' , 'varchar(150)'), '      -')
      , [Param14] = ISNULL(param.value('(/h/r)[14]' , 'varchar(150)'), '      -')
      , [Param15] = ISNULL(param.value('(/h/r)[15]' , 'varchar(150)'), '      -')
      , [Param16] = ISNULL(param.value('(/h/r)[16]' , 'varchar(150)'), '      -')
      , [Param17] = ISNULL(param.value('(/h/r)[17]' , 'varchar(150)'), '      -')
      , [Param18] = ISNULL(param.value('(/h/r)[18]' , 'varchar(150)'), '      -')
      , [Param19] = ISNULL(param.value('(/h/r)[19]' , 'varchar(150)'), '      -')
      , [Param20] = ISNULL(param.value('(/h/r)[20]' , 'varchar(150)'), '      -')
      , [Param21] = ISNULL(param.value('(/h/r)[21]' , 'varchar(150)'), '      -')
      , [Param22] = ISNULL(param.value('(/h/r)[22]' , 'varchar(150)'), '      -')
      , [Param23] = ISNULL(param.value('(/h/r)[23]' , 'varchar(150)'), '      -')
      , [Param24] = ISNULL(param.value('(/h/r)[24]' , 'varchar(150)'), '      -')
      , [Param25] = ISNULL(param.value('(/h/r)[25]' , 'varchar(150)'), '      -')
      , [Param26] = ISNULL(param.value('(/h/r)[26]' , 'varchar(150)'), '      -')
      , [Param27] = ISNULL(param.value('(/h/r)[27]' , 'varchar(150)'), '      -')
      , [Param28] = ISNULL(param.value('(/h/r)[28]' , 'varchar(150)'), '      -')
      , [Param29] = ISNULL(param.value('(/h/r)[29]' , 'varchar(150)'), '      -')
      , [Param30] = ISNULL(param.value('(/h/r)[30]' , 'varchar(150)'), '      -')
      , [Param31] = ISNULL(param.value('(/h/r)[31]' , 'varchar(150)'), '      -')
      , [Param32] = ISNULL(param.value('(/h/r)[32]' , 'varchar(150)'), '      -')
      , [Param33] = ISNULL(param.value('(/h/r)[33]' , 'varchar(150)'), '      -')
      , [Param34] = ISNULL(param.value('(/h/r)[34]' , 'varchar(150)'), '      -')
      , [Param35] = ISNULL(param.value('(/h/r)[35]' , 'varchar(150)'), '      -')
      , [Param36] = ISNULL(param.value('(/h/r)[36]' , 'varchar(150)'), '      -')
      , [Param37] = ISNULL(param.value('(/h/r)[37]' , 'varchar(150)'), '      -')
      , [Param38] = ISNULL(param.value('(/h/r)[38]' , 'varchar(150)'), '      -')
      , [Param39] = ISNULL(param.value('(/h/r)[39]' , 'varchar(150)'), '      -')
      , [Param40] = ISNULL(param.value('(/h/r)[40]' , 'varchar(150)'), '      -')
INTO    #ReportHistory
FROM    #FilterdData fd
        OUTER APPLY fd.ParamaterXml.nodes('h/r') p(param)
;



SELECT * 
FROM    #FilterdData
ORDER BY ID

SELECT  *
FROM    #ReportHistory
ORDER BY id,TimeStart, ClientName, ReportName

 

-- ===========================================================================================================================================
-- ===  Query 3 - Data Source Details
; WITH XMLNAMESPACES  /* XML namespace def must be the first in with clause. */
    ( DEFAULT  'http://schemas.microsoft.com/sqlserver/reporting/2006/03/reportdatasource'
    , 'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd )

, Sds AS (
    SELECT  ItemID
          , [SharedDSName]  = NAME
          , [Path]          = [Path]
          , [Definition]    = CONVERT(XML, CONVERT(VARBINARY(max), content))
    FROM    dbo.[Catalog]
    WHERE   [Type] = 5  /* 5 = Shared Datasource  */
)
-- SELECT * FROM Sds /*

SELECT  con.ItemID
      , con.[Path]
      , con.ShareddsName
      , con.ConnString
FROM (  SELECT  sds.ItemId
              , sds.[Path]
              , sds.ShareddsName
              , dsn.value('ConnectString[1]', 'varchar(150)') AS ConnString
        FROM    sds
                CROSS APPLY Sds.Definition.nodes('/DataSourceDefinition') AS R(dsn)
) AS con
WHERE  ( @ClientName  IS NULL OR [Path] LIKE '%' + @ClientName + '%' )
ORDER BY con.[Path]
    , con.ShareddsName
;




-- ===========================================================================================================================================
-- ===  Query 4 - Data Source Dependencies
SELECT  SharedDSName      = cds.Name
      , DependentItemName = di.Name
      , DependentItemPath = di.Path
FROM    DataSource AS ds
        INNER JOIN Catalog di
                ON  ds.ItemID = di.ItemID
                AND ds.Link IN (  SELECT  ItemID
                                  FROM    Catalog
                                  WHERE   Type = 5  ) --Type 5 identifies data sources
        FULL OUTER JOIN Catalog cds
                ON ds.Link = cds.ItemID
WHERE   cds.Type = 5
        AND  ( @ClientName IS NULL OR cds.Name LIKE '%' + @ClientName + '%' )
        AND  ( @ReportName IS NULL OR di.Name  LIKE '%' + @ReportName + '%' )
ORDER BY
        cds.Name ASC
      , di.Name ASC
;





-- ===========================================================================================================================================
-- ===  Query 5 - SSRS Configuration Details
SELECT  *
FROM    ConfigurationInfo



-- /* --*/ -- */ -- */ -- */