USE MASTER 
IF EXISTS (SELECT * FROM sys.procedures p WHERE p.name  = 'CreateSnapshot' AND p.schema_id = SCHEMA_ID('dbo'))
    DROP PROCEDURE dbo.CreateSnapshot
GO
-- ===  This sproc Creates a snapshot of the supplied database a
CREATE PROCEDURE dbo.CreateSnapshot (
    @SourceDbName             VARCHAR(128),
    @TargetSnapshotDbName     VARCHAR(128) = NULL,
    @LiveMode                 BIT          = 1,
    @VerboseMode              BIT          = 0,
    @DropSnapshotDbIfItExists BIT          = 0
)
AS
BEGIN
    SET NOCOUNT ON

    -- ===  Quit if there is a problem
    IF NOT EXISTS(SELECT * FROM sys.databases d WHERE d.name = @SourceDbName) BEGIN
        RAISERROR('There is no datbase called ''%s'' on this server',16,1, @SourceDbName)  
        RETURN  
    END
    ELSE IF NOT EXISTS(SELECT * FROM sys.databases d WHERE d.name = @SourceDbName AND d.state = 0 AND d.source_database_id IS NULL) BEGIN
        RAISERROR('The datbase ''%s'' is not valid for snapshoting. It is either not online or is already a snapshot',16,1, @SourceDbName)  
        RETURN  
    END

    -- === Ensure that these are configured corectly
    SET @LiveMode                 = COALESCE(@LiveMode, 0)
    SET @VerboseMode              = COALESCE(@VerboseMode, 0)
    SET @DropSnapshotDbIfItExists = COALESCE(@DropSnapshotDbIfItExists, 0)


    -- ===  Defines the snapshot database sql statement
    DECLARE @DropSnapshotdbSQL VARCHAR(MAX)
        SET @DropSnapshotdbSQL = 
'IF EXISTS(SELECT * FROM sys.databases WHERE name = ''$SnapshotDbName$'')
  DROP DATABASE $SnapshotDbName$ 
;'

    DECLARE @CreateSnapshotDbSQL VARCHAR(MAX)
        SET @CreateSnapshotDbSQL = 
'CREATE DATABASE [$SnapshotDbName$] ON $FileGroups$
AS SNAPSHOT OF [$SourceDbName$] 
;'
    
    -- ===  Define the sql snip for deffining the filegroup
    DECLARE @FileGroupDeffinition VARCHAR(8000)
        SET @FileGroupDeffinition ='
( NAME = $LogicalFileName$,
  FILENAME = ''$PhysicalName$.ss'' )'
    
    -- ===  Deffine a string representation of the date yyyMMddHHmmss
    DECLARE @DateString VARCHAR(50)
    SELECT  @DateString = CONVERT(VARCHAR(20),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(8),GETDATE(),108),':','')
    
    -- ===  This is the name of the database that we are going to create
    IF(@TargetSnapshotDbName IS NULL OR @TargetSnapshotDbName = '')
        SELECT  @TargetSnapshotDbName = REPLACE( REPLACE( '$SourceDbName$_$DateTime$', '$SourceDbName$', @SourceDbName), '$DateTime$', @DateString)


    -- ===  Create a comma seperated list of file descriptions. This is necessary as there may be multiple file groups
    -- ===  Replace the logical file name paramater with the actual logical file name of te file group
    -- ===  Replace the physical file name with the actuall physical file name with a date appended and the extension removed so the extension .ss can be added
    DECLARE @FileGroupDeffinitionList VARCHAR(MAX)
    SELECT  @FileGroupDeffinitionList = COALESCE( @FileGroupDeffinitionList + ', ' + 
                                                      REPLACE( REPLACE( @FileGroupDeffinition, '$LogicalFileName$', df.name), '$PhysicalName$', 
                                                          REVERSE( SUBSTRING( REVERSE(df.physical_name), 
                                                              CHARINDEX( '.', REVERSE( df.physical_name)) + 1, 999)) + '_' + @DateString),
                                                  REPLACE( REPLACE( @FileGroupDeffinition, '$LogicalFileName$', df.name), '$PhysicalName$', 
                                                      REVERSE( SUBSTRING( REVERSE(df.physical_name), 
                                                          CHARINDEX( '.', REVERSE( df.physical_name)) + 1, 999)) + '_' + @DateString))
    FROM    sys.databases d
            INNER JOIN sys.master_files df
                    ON df.database_id = d.database_id
                    AND df.type = 0 -- Data
    WHERE   d.name = @SourceDbName
            AND d.state = 0 -- Online
    
    
    -- ===  The final representation of the create database command
    SELECT  @CreateSnapshotDbSQL = REPLACE( REPLACE( REPLACE( @CreateSnapshotDbSQL,'$SourceDbName$',@SourceDbName), '$SnapshotDbName$', @TargetSnapshotDbName), '$FileGroups$', @FileGroupDeffinitionList)
    
    SELECT @DropSnapshotdbSQL = REPLACE( @DropSnapshotdbSQL, '$SnapshotDbName$', @TargetSnapshotDbName )

    -- ===  Create the database with verbose logging
    IF( @LiveMode = 1 ) BEGIN
        IF( @VerboseMode = 1 ) BEGIN
            PRINT 'Use the following sql to create a database snap shot of ' + @SourceDbName
            PRINT '  '
            IF (@DropSnapshotDbIfItExists = 1 ) BEGIN
                PRINT @DropSnapshotdbSQL
                PRINT '  '
                EXEC(@DropSnapshotdbSQL)  
            END
            PRINT @CreateSnapshotDbSQL
            PRINT '  '
            EXEC(@CreateSnapshotDbSQL)
        END   
        -- Create the database no logging
        ELSE IF( @VerboseMode = 0 ) BEGIN 
            EXEC(@CreateSnapshotDbSQL)
        END
    END
    -- Only log the details of the request. Dont actually do anything
    ELSE IF( @LiveMode = 0 ) BEGIN  
        PRINT 'Use the following sql to create a database snap shot of ' + @SourceDbName
        PRINT '  '
        IF (@DropSnapshotDbIfItExists = 1 ) BEGIN
            PRINT @DropSnapshotdbSQL
            PRINT '  '
        END
        PRINT @CreateSnapshotDbSQL
        PRINT '  '
    END
    
    -- ===  Quit if the db has failed to snapshot
    IF @LiveMode = 1 BEGIN
        IF NOT EXISTS (SELECT * FROM sys.databases d WHERE d.name = @TargetSnapshotDbName AND d.source_database_id = DB_ID(@SourceDbName)) BEGIN
            RAISERROR('The datbase ''%s'' has not been created as a snapshot of %s.', 16, 1, @TargetSnapshotDbName, @SourceDbName)  
        END
        ELSE BEGIN
            PRINT @TargetSnapshotDbName + ' has been created as a snapshot of ' + @SourceDbName
        END
    END
    ELSE IF @LiveMode = 0 BEGIN
        PRINT @TargetSnapshotDbName + ' would have created as a snapshot of ' + @SourceDbName + ' if we were not executiong in test mode.'
    END    
    
    SELECT  SourceDatabase        = @SourceDbName 
          , SnapshotDatabase      = @TargetSnapshotDbName 
          , SqlToDropSnapshot     = @DropSnapshotdbSQL
          , SqlToCreateSnapShot   = @CreateSnapshotDbSQL
          , LiveMode              = @LiveMode
          , VerboseMode           = @VerboseMode
          , DropSnapshotMode      = @DropSnapshotDbIfItExists
END
GO

/*

EXEC dbo.CreateSnapshot @SourceDbName             = 'XXXMAINdev_trunk'
                      , @TargetSnapshotDbName     = 'xxxfoodah'
                      , @LiveMode                 = 1
                      , @VerboseMode              = 1
                      , @DropSnapshotDbIfItExists = 1

*/