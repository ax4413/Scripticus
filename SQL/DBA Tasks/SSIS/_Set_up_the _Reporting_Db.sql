TRUNCATE TABLE ExtractConfiguration

/*
    Specifically this sets up the main datbase for use with the reporting database
*/

-- ===  ====================================================================================================================================================
-- ===  Generic configuration
DECLARE @ReportingConnectionString  VARCHAR(500) = 'Provider=SQLNCLI11;Server=172.22.38.252;Database=VirginMediaReportingDev_SY;Uid=syeadon;Pwd=diamonds;'
      , @MainConnectionString       VARCHAR(500) = 'Provider=SQLNCLI11;Data Source=172.22.38.252;User Id=syeadon;Password=FOO;Initial Catalog=VirginSITMainTRN'


INSERT INTO ExtractConfiguration (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType, CreateDate, ChangeDate, CreateUserId, ChangeUserId)
    SELECT  'ExtractConfigurationSQLServer', @MainConnectionString
          ,	'\Package.Connections[MainDB].Properties[ConnectionString]'
          , 'String', GETDATE(),	NULL,	-1,	NULL
    UNION
    SELECT  'ExtractConfigurationSQLServer', @MainConnectionString
          , '\Package.Connections[SourceDB].Properties[ConnectionString]'
          , 'String', GETDATE(),	NULL,	-1,	NULL
    UNION
    SELECT  'ExtractConfigurationSQLServer', NULL
          , '\Package.Variables[User::OutputFolder].Properties[Value]'
          , 'String', GETDATE(),	NULL,	-1,	NULL
    UNION
    SELECT  'ExtractConfigurationSQLServer', null
          , '\Package.Variables[User::BatchRequestHistoryId].Properties[Value]'
          , 'Int32',	 GETDATE(),	NULL,	-1, NULL
    UNION
    SELECT  'ExtractConfigurationSQLServer', @ReportingConnectionString
          , '\Package.Connections[TargetDB].Properties[ConnectionString]'
          , 'String', GETDATE(),	NULL,	-1,	NULL
GO


SELECT  PackagePath, ConfiguredValue
FROM    ExtractConfiguration
WHERE   ConfigurationFilter = 'ExtractConfigurationSQLServer'



-- ===  ====================================================================================================================================================
-- ===  Specific configuration
SELECT  l.ListId, l.InternalValue, l.Description, fl.*
FROM    list  l
        INNER JOIN listdescription ld 
                ON l.ListDescriptionId = ld.ListDescriptionId
        LEFT OUTER JOIN FolderLocation Fl 
                ON fl.FolderLocationType = l.ListId
WHERE   ld.code = 'Folder Location Type' 
ORDER BY l.InternalValue

/*

INSERT INTO LIST (ListDescriptionId, Description, InternalValue, IsAvailable)
    SELECT  ListDescriptionId , 'Document Audit Folder', 33, 1
    FROM    ListDescription  WHERE Code = 'Folder Location Type'

UPDATE  fl
   SET  FolderLocation = 'd:\tmp'
FROM    FolderLocation fl 
        INNER JOIN list  l
                ON fl.FolderLocationType = l.ListId
        INNER JOIN listdescription ld 
                ON l.ListDescriptionId = ld.ListDescriptionId
WHERE   ld.code = 'Folder Location Type' 

*/

INSERT INTO folderlocation (folderlocationtype, folderlocation, createdate, createuserid)
    VALUES  ( 2120, 'D:\temp', getdate(), -1 ),  ( 2121, 'D:\temp', getdate(), -1 ),  ( 2122, 'D:\temp', getdate(), -1 )
GO






-- ===  ====================================================================================================================================================
-- ===  Set up the table control stuff. This is normally done by the MI Extract
DECLARE @TableControlId   INT = 1059
      , @ExtractDate DATETIME = GETDATE()
      , @FromDate    DATETIME = '19000101'
      , @StartDate   DATETIME
      , @ToDate      DATETIME

SELECT  @StartDate  = @ExtractDate
      , @ToDate     = @ExtractDate

INSERT INTO UpdateHistory(ExtractTargetDate, StartDate)
  VALUES (@ExtractDate, @StartDate)

INSERT INTO TableUpdateHistory(TableControlId, UpdateHistoryId, FromDate, ToDate, startDate)
  VALUES(@TableControlId, SCOPE_IDENTITY(), @FromDate, @ToDate, @StartDate)