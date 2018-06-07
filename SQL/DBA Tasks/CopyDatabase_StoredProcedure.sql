USE MASTER 
IF EXISTS (SELECT * FROM sys.procedures p WHERE p.name  = 'CopyDatabase' AND p.schema_id = SCHEMA_ID('dbo'))
    DROP PROCEDURE dbo.CopyDatabase
GO
-- ===  This sproc Creates a snapshot of the supplied database a
CREATE PROCEDURE dbo.CopyDatabase (
    @SourceDatabaseName           VARCHAR(128),
    @TargetDatabaseName           VARCHAR(128) = NULL,
    @BackupDir                    VARCHAR(256) = 'H:\Backup',
    @LiveMode                     BIT          = 1,
    @DropTargetDatabaseIfItExists BIT          = 0
)
AS
BEGIN
    SET NOCOUNT ON

    -- ===  Quit if there is a problem
    IF NOT EXISTS(SELECT * FROM sys.databases d WHERE d.name = @SourceDatabaseName) BEGIN
        RAISERROR('There is no datbase called ''%s'' on this server',16,1, @SourceDatabaseName)  
        RETURN  -1
    END
    ELSE IF NOT EXISTS(SELECT * FROM sys.databases d WHERE d.name = @SourceDatabaseName AND d.state = 0 AND d.source_database_id IS NULL) BEGIN
        RAISERROR('The datbase ''%s'' is not valid for copying. It is either not online or it is a snapshot',16,1, @SourceDatabaseName)  
        RETURN  -1
    END
    ELSE BEGIN
        SELECT @SourceDatabaseName = name FROM sys.databases d WHERE d.name = @SourceDatabaseName
    END

    IF(@BackupDir IS NULL OR LTRIM(RTRIM(@BackupDir)) = '') BEGIN 
        RAISERROR('The path you supplied to a backup dir is not valid ''''',16, 1, @BackupDir)  
        RETURN  -1
    END

    -- trim trailing spaces
    IF(SUBSTRING(@BackupDir, LEN(@BackupDir), 1) = '\') BEGIN
      SET @BackupDir = SUBSTRING(@BackupDir, 0, LEN(@BackupDir))
    END 

    -- === Ensure that these are configured corectly
    SET @LiveMode                     = COALESCE(@LiveMode, 0)
    SET @DropTargetDatabaseIfItExists = COALESCE(@DropTargetDatabaseIfItExists, 0)


    -- ===  Defines the snapshot database sql statement
    DECLARE @DropDatabaseSQL VARCHAR(MAX)
        SET @DropDatabaseSQL = '
IF EXISTS(SELECT * FROM sys.databases WHERE name = ''$TargetDbName$'')
  DROP DATABASE $TargetDbName$ 
;'

    
      DECLARE @BackupSQL NVARCHAR(MAX) 
          SET @BackupSQL = '
BACKUP DATABASE [$SourceDbName$]
TO DISK = ''$PathToBackupFile$'' 
WITH COPY_ONLY
;'
    
    
    DECLARE @RestoreDatabaseSQL VARCHAR(MAX)
        SET @RestoreDatabaseSQL = '
RESTORE DATABASE [$TargetDbName$]
FROM DISK = ''$PathToBackupFile$''
WITH
$FileGroups$
REPLACE, RECOVERY
;'

    

    -- ===  Deffine a string representation of the date yyyMMddHHmmss
    DECLARE @DateString VARCHAR(50)
    SELECT  @DateString = CONVERT(VARCHAR(20),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(8),GETDATE(),108),':','')
    
    -- ===  This is the name of the database that we are going to create
    IF(@TargetDatabaseName IS NULL OR @TargetDatabaseName = '')
        SELECT  @TargetDatabaseName = REPLACE( REPLACE( '$SourceDbName$_$DateTime$', '$SourceDbName$', @SourceDatabaseName), '$DateTime$', @DateString)

    -- ===  This is the location we will persist the .bak file to
    DECLARE @PathToBackupFile NVARCHAR(256) = @BackupDir + '\' + @TargetDatabaseName + '.bak'

    -- ===  Create a comma seperated list of files to move. This is necessary as there may be multiple file groups
    -- ===  Replace the logical file name paramater with the actual logical file name of the file group
    -- ===  Replace the physical file name with the actuall physical file name with a date
    DECLARE @DataFileDefinitionList VARCHAR(MAX) = ''
    ; WITH a AS (
        SELECT  logical_name  = df.name
              , physical_name = SUBSTRING(physical_name, 0,  LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name), 0)+1) + '\' + @TargetDatabaseName + '_' + CAST(ROW_NUMBER() OVER(partition by df.type ORDER BY df.file_id) AS VARCHAR(2)) + CASE WHEN df.type = 0 THEN '.mdf' ELSE '.log' END
              , df.type 
        FROM    sys.databases d
                INNER JOIN sys.master_files df
                        ON df.database_id = d.database_id
        WHERE   d.name = @SourceDatabaseName
                AND d.state = 0 -- Online
    ) 
    --SELECT * FROM a
    , b AS (
        SELECT move_sql = REPLACE ( 
                            REPLACE ( 'MOVE ''$LogicalFileName$'' TO ''$PhysicalFileName$'','
                                     , '$LogicalFileName$'
                                     , logical_name )
                              , '$PhysicalFileName$'
                              , physical_name )
        FROM a
    )
    --SELECT * FROM b

    SELECT @DataFileDefinitionList = COALESCE( @DataFileDefinitionList, '' ) + move_sql + CHAR(9)+CHAR(10)
    FROM b
    
    -- === Remove the last trailing line ending
    SELECT @DataFileDefinitionList = LEFT(@DataFileDefinitionList,LEN(@DataFileDefinitionList)-PATINDEX('%[^'+CHAR(13)+CHAR(10)+']%',REVERSE(@DataFileDefinitionList))+1)
    
    -- ===  The final representation of the create database command
    SELECT @DropDatabaseSQL    = REPLACE( @DropDatabaseSQL, '$TargetDbName$', @TargetDatabaseName )
    SELECT @BackupSQL          = REPLACE( REPLACE( @BackupSQL,'$SourceDbName$', @SourceDatabaseName), '$PathToBackupFile$', @PathToBackupFile)    
    SELECT @RestoreDatabaseSQL = REPLACE( REPLACE( REPLACE( REPLACE( @RestoreDatabaseSQL,'$SourceDbName$',@SourceDatabaseName), '$TargetDbName$', @TargetDatabaseName), '$FileGroups$', @DataFileDefinitionList), '$PathToBackupFile$', @PathToBackupFile )
    
    

    -- ===  Create the database with verbose logging
    
    PRINT '--  ' + 'Use the following sql to copy your database [' + @SourceDatabaseName +'] to [' + @TargetDatabaseName  + ']'
    IF @LiveMode = 0 BEGIN
        PRINT '  '
        PRINT '--  ' +  @TargetDatabaseName + ' would have been copied from ' + @SourceDatabaseName + ' if we were not executiong in test mode.'
    END   
    PRINT '  '

    PRINT @BackupSQL
    IF (@LiveMode= 1) BEGIN
      BEGIN TRY
          EXEC(@BackupSQL)
      END TRY
      BEGIN CATCH
          SELECT  ERROR_MESSAGE() AS [error_message]
          SET @LiveMode = 0  -- DO NOT EXECUTE ANY MORE CMDs
      END CATCH
    END
    PRINT '  '
    
    IF (@DropTargetDatabaseIfItExists = 1 ) BEGIN
        PRINT @DropDatabaseSQL
        IF (@LiveMode= 1) BEGIN
             BEGIN TRY
                EXEC(@DropDatabaseSQL) 
            END TRY
            BEGIN CATCH
                SELECT  ERROR_MESSAGE() AS [error_message]
                SET @LiveMode = 0  -- DO NOT EXECUTE ANY MORE CMDs
            END CATCH
        END
        PRINT '  '         
    END


    PRINT @RestoreDatabaseSQL
    PRINT '  '
    IF (@LiveMode= 1) BEGIN
        BEGIN TRY
            EXEC(@RestoreDatabaseSQL)
        END TRY
        BEGIN CATCH
            SELECT  ERROR_MESSAGE() AS [error_message]
            SET @LiveMode = 0  -- DO NOT EXECUTE ANY MORE CMDs
        END CATCH
    END
     

    
    -- ===  Quit if the db has failed to created
    IF @LiveMode = 1 BEGIN
        IF NOT EXISTS (SELECT * FROM sys.databases d WHERE d.name = @TargetDatabaseName) BEGIN
            RAISERROR('The datbase ''%s'' has not been created.', 16, 1, @TargetDatabaseName)  
        END
        ELSE BEGIN
            PRINT '--  ' + @TargetDatabaseName + ' has been created'
        END
    END 
    
    SELECT  SourceDatabase               = @SourceDatabaseName 
          , TargetDatabaseName           = @TargetDatabaseName 
          , DropDatabaseSQL              = @DropDatabaseSQL
          , BackupDatabaseSQL            = @BackupSQL
          , RestoreDatabaseSQL           = @RestoreDatabaseSQL
          , LiveMode                     = @LiveMode
          , DropTargetDatabaseIfItExists = @DropTargetDatabaseIfItExists
END
GO



EXEC dbo.CopyDatabase @SourceDatabaseName           = 'zzzTrunkMain'
                    , @LiveMode                     = 0
                    , @DropTargetDatabaseIfItExists = 1

