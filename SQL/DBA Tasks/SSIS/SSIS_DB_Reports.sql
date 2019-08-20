USE SSISDB


RAISERROR ('
Don''t forget that its the version Id that you want!!!
', 11, 0)

-- ===  These are all of your SSIS Project / Packages and their current versions
SELECT  [Folder]                  = f.name
      , [ProjectId]               = proj.project_id
      , [ProjectName]             = proj.name
      , [PackageId]               = pac.package_id
      , [PackageName]             = pac.Name
      , [Description]             = pac.Description
      , [VersionId]               = proj.object_version_lsn
      , [PreviousProjectVersions] = PreviousVersions.Value
FROM    catalog.Projects proj
        INNER JOIN catalog.Packages pac
                ON pac.project_id = proj.project_id
        INNER JOIN internal.projects p
                ON p.project_id = proj.Project_id
        INNER JOIN internal.folders f
                ON f.folder_id = p.folder_id
        CROSS APPLY ( SELECT proj.project_id, Value = STUFF( (  SELECT  ', ' + CAST( ObjVer.object_version_lsn AS VARCHAR(50) ) AS [text()]
											                                          FROM    [catalog].[object_versions] ObjVer
											                                          WHERE   ObjVer.object_id = proj.project_id
                                                                        AND ObjVer.object_version_lsn != proj.object_version_lsn
                                                                ORDER BY ObjVer.created_time DESC
                                                            FOR XML PATH(''), TYPE).value('(./text())[1]','VARCHAR(MAX)'), 1, 1, '' ) ) PreviousVersions
ORDER BY f.name, proj.name,pac.Name
;
-- ===  ====================================================================================================================



-- ===  Can be found above
DECLARE @VersionId INT = 668

IF(@VersionId = 0 ) BEGIN
    RAISERROR ('
Details about "previous package executions" will not be accurate. Please set the variable @VersionId which has a value of %i

', 11, 0, @VersionId)
END

-- ===  Details about previous package executions
SELECT  e.start_time
      , CASE status WHEN 1 THEN 'Created' 
                    WHEN 2 THEN 'Running'
                    WHEN 3 THEN 'Canceled'
                    WHEN 4 THEN 'Failed'
                    WHEN 5 THEN 'Pending'
                    WHEN 6 THEN 'Ended Unexpectedly'
                    WHEN 7 THEN 'Succeeded'
                    WHEN 8 THEN 'Stopping'
                    WHEN 9 THEN ''
                    ELSE 'n/a' END
      , *
FROM    SSISDB.catalog.executions e
WHERE   e.project_lsn = @VersionId
ORDER BY e.start_time DESC
;
-- ===  ====================================================================================================================



-- ===  Can be found above
DECLARE @ExecutionId INT = 605095

IF(@ExecutionId = 0) BEGIN
    RAISERROR ('
Details about "general pacakage execution and their statistics" will not be accurate. Please set the variable @ExecutionId which has a value of %i

', 11, 1, @ExecutionId)
END

-- ===  Details about pacakage execution statistics
SELECT  *
      , [Execution Result Description] = CASE es.execution_result
                                            WHEN 0 THEN 'Success'
                                            WHEN 1 THEN 'Failure'
                                            WHEN 2 THEN 'Completion'
                                            WHEN 3 THEN 'Cancelled' END 
FROM    catalog.executable_statistics es
WHERE   es.execution_id = @ExecutionId
;


-- ===  Details about general package execution
SELECT  em.event_message_id
      , em.message_time
      , em.execution_path
      , em.event_name
      , [Message Source Type] = CASE em.message_source_type 
                                  WHEN 10 THEN 'Entry APIs, such as T-SQL and CLR Stored procedures'
                                  WHEN 20 THEN 'External process used to run package (ISServerExec.exe)'
                                  WHEN 30 THEN 'Package-level objects'
                                  WHEN 40 THEN 'Control Flow tasks'
                                  WHEN 50 THEN 'Control Flow containers'
                                  WHEN 60 THEN 'Data Flow task'
                                  ELSE 'WTF - https://msdn.microsoft.com/en-us/library/ff877994.aspx' END
      , em.Message 
        --, em.*
FROM    SSISDB.catalog.event_messages em
WHERE   em.operation_id = @ExecutionId
        AND em.event_name NOT LIKE '%Validate%'
        --AND em.event_name = 'OnError'
        --AND em.event_name = 'OnInformation'
        --AND execution_path LIKE '%<some executable>%'
ORDER BY em.message_time DESC
      , em.event_message_id 
;