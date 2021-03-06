/*
CREATE DATABASE [InstanceMonitor]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InstanceMonitor', FILENAME = N'Y:\Data\InstanceMonitor.mdf' , SIZE = 3072KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'InstanceMonitor_log', FILENAME = N'Z:\logs\InstanceMonitor_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [InstanceMonitor] SET COMPATIBILITY_LEVEL = 110
GO
ALTER DATABASE [InstanceMonitor] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [InstanceMonitor] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [InstanceMonitor] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [InstanceMonitor] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [InstanceMonitor] SET ARITHABORT OFF 
GO
ALTER DATABASE [InstanceMonitor] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [InstanceMonitor] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [InstanceMonitor] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [InstanceMonitor] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [InstanceMonitor] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [InstanceMonitor] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [InstanceMonitor] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [InstanceMonitor] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [InstanceMonitor] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [InstanceMonitor] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [InstanceMonitor] SET  DISABLE_BROKER 
GO
ALTER DATABASE [InstanceMonitor] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [InstanceMonitor] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [InstanceMonitor] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [InstanceMonitor] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [InstanceMonitor] SET  READ_WRITE 
GO
ALTER DATABASE [InstanceMonitor] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [InstanceMonitor] SET  MULTI_USER 
GO
ALTER DATABASE [InstanceMonitor] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [InstanceMonitor] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [InstanceMonitor]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [InstanceMonitor] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO


*/


-- === Schemas ==================================================================================================================
GO
CREATE SCHEMA [Private]
GO

-- === Tables ===================================================================================================================
CREATE TABLE dbo.Db(
    [DbId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [DatabaseName] VARCHAR(128)
)
GO

CREATE TABLE dbo.[Snapshot](
    [SnapshotId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [Created] DATETIME
)
GO

CREATE TABLE dbo.DbSnapshot(
    [DbSnapshotId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [DbId] INT NOT NULL,
    [SnapshotId] INT NOT NULL,
    CONSTRAINT FK_DbSnapshot_DB FOREIGN KEY ([DbId]) 
    REFERENCES dbo.Db ([DbId]) ,
    CONSTRAINT FK_DbSnapshot_Snapshot FOREIGN KEY ([SnapshotId]) 
    REFERENCES dbo.[Snapshot] ([SnapshotId]) 
)
GO

CREATE TABLE dbo.FileSizeSnapshot(
    [FileSizeSnapshot] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [DbSnapshotId] INT NOT NULL,
    [FileGroup] VARCHAR(128),
    [Used_MB] INT,
    [Free_MB] INT,
    [Size_MB] INT,
    [Used%] DECIMAL(20,2),
    [Free%] DECIMAL(20,2)
    CONSTRAINT FK_FileSizeSnapshot_DbSnapshot FOREIGN KEY ([DbSnapshotId]) 
    REFERENCES dbo.DbSnapshot ([DbSnapshotId]) 
)
GO


-- === Views ====================================================================================================================
CREATE VIEW dbo.vFileSizeDetails 
AS
    SELECT  db.DatabaseName, s.Created, fss.FileGroup, fss.Used_MB, fss.Free_MB, fss.Size_MB, fss.[Used%], fss.[Free%]
    FROM    Db db
            INNER JOIN DbSnapshot dbs
                    ON dbs.DbId = db.DbId
            INNER JOIN Snapshot s
                    ON S.SnapshotId = DBS.SnapshotId
            INNER JOIN FileSizeSnapshot fss
                    ON fss.DbSnapshotId = dbs.DbSnapshotId
GO

CREATE VIEW dbo.vFileSizeGrowth
AS
    WITH Details AS (
        SELECT  DatabaseName, Created, SUM(Size_MB) Size_MB
        FROM    vFileSizeDetails
        GROUP BY DatabaseName, Created
    )

    SELECT  *, Growth_mb = LEAD(Size_MB) OVER (PARTITION BY DatabaseName ORDER BY Created) - Size_MB
    FROM    Details
GO


-- === Procedures ===============================================================================================================
CREATE PROCEDURE [Private].[SnapshotDiskUsage]
AS
  -- ===  Global temp table to hold the result set
  IF(OBJECT_ID('tempdb..##FileGroupSize') IS NOT NULL)
    DROP TABLE ##FileGroupSize
  CREATE TABLE ##FileGroupSize
  (      DB VarChar(128)
      , FileGroup VarChar(128)
      , Used_MB Int
      , Free_MB Int
      , Size_MB Int
  )

  -- ===  Loop through all our database to get the size on disk
  EXEC sp_MSforeachdb N'use [?]; 
  INSERT INTO ##FileGroupSize
  SELECT DB = db_name()
      , FileGroup = ISNULL(g.name, f.Type_Desc) 
      , Used_MB = SUM(FileProperty(f.name, ''SpaceUsed'')) / 128
      , Free_MB = SUM(f.size - FileProperty(f.name, ''SpaceUsed'')) / 128
      , Size_MB = SUM(f.size) / 128 
  FROM sys.database_files f
      LEFT JOIN sys.filegroups g on f.data_space_id = g.data_space_id
  GROUP BY f.Type_Desc, g.name
  '

  -- ===  Create the FileSizeSnapshot
  INSERT INTO FileSizeSnapshot([DbSnapshotId], [FileGroup], [Used_MB], [Free_MB], [Size_MB], [Used%], [Free%])
      SELECT  lstDbSnap.DbSnapshotId, t.[FileGroup], t.[Used_MB], t.[Free_MB], t.[Size_MB],
              [Used%] = Cast(100 * t.[Used_MB] / (Cast(t.[Size_MB] as Dec(20,2)) + .01) as Dec(20,2)),
              [Free%] = 100 - Cast(100 * t.[Used_MB] / (Cast(t.[Size_MB] as Dec(20,2)) + .01) as Dec(20,2))
      FROM    ##FileGroupSize t
              INNER JOIN (  SELECT  db.DatabaseName, MAX(dbs.DbSnapshotId) DbSnapshotId
                            FROM    Db db
                                    INNER JOIN DbSnapshot dbs
                                            ON dbs.[dbid] = db.[dbid]
                            GROUP BY db.DatabaseName ) lstDbSnap
                      ON lstDbSnap.DatabaseName = t.db
      ORDER BY DB, FileGroup  

GO

CREATE PROCEDURE [dbo].[TakeSnapshot]
AS

  -- ===  Insert any new database records into our db table
  -- ===  things will start to go wrong if database get renamed
  INSERT INTO Db (DatabaseName)
      SELECT  DISTINCT sysdb.name
      FROM    sys.databases sysdb
              LEFT OUTER JOIN Db db
                      ON db.DatabaseName = sysdb.name
      WHERE   Db.DbId IS NULL


  -- ===  Create a snapshot
  DECLARE @SnapshotId INT = 0
  INSERT INTO [Snapshot](Created)
      SELECT GETDATE()
  SELECT @SnapshotId = SCOPE_IDENTITY()
      

  -- ===  Create the database snapshots
  INSERT INTO DbSnapshot
      SELECT  DISTINCT Db.DbId, @SnapshotId
      FROM    Db
      ORDER BY Db.DbId

  EXEC [Private].SnapshotDiskUsage
  -- Extend monitoring here
GO


-- === Sql Agent Job ============================================================================================================
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SnapshotInstance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'syeadon', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SnapshotInstance', @server_name = N'505297-SSCLUDV\DEV'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SnapshotInstance', @step_name=N'TakeSnapshot', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.TakeSnapshot', 
		@database_name=N'InstanceMonitor', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SnapshotInstance', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'syeadon', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SnapshotInstance', @name=N'TakeSnapshotSchedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150313, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

-- === ==========================================================================================================================
-- === ==========================================================================================================================
-- === ==========================================================================================================================
-- === Test Setup ===============================================================================================================
exec SnapshotDiskUsage    
go 10


UPDATE SNAPSHOT
  SET CREATED = DATEADD(DAY, -(10-SNAPSHOTID), CREATED)


DECLARE @snapshotid int = 0, @p int = 3
SELECT  @snapshotid = MAX(snapshotid) FROM [Snapshot] 

WHILE (@snapshotid>0)
BEGIN
    
    --SELECT  DbId, FileGroup, size_mb, (size_mb/100)*@p, size_mb - ((size_mb/100)*@p)
    --FROM    FileSizeSnapshot fss
    --        INNER JOIN DbSnapshot dbs
    --                ON dbs.DbSnapshotId = fss.DbSnapshotId

    UPDATE  FileSizeSnapshot
    SET     size_mb = size_mb - ((size_mb/100)*@p)
    FROM    FileSizeSnapshot fss
            INNER JOIN DbSnapshot dbs
                    ON dbs.DbSnapshotId = fss.DbSnapshotId
    WHERE   dbs.SnapshotId = @snapshotid
    
    SELECT  @p = @p + 3
    SELECT  @snapshotid = MAX(snapshotid) FROM [Snapshot] WHERE SnapshotId < @snapshotid
END
-- === End of test setup ========================================================================================================


--select * from db
--select * from snapshot
--select * from dbsnapshot
--SELECT * FROM FileSizeSnapshot  


--DROP TABLE dbo.FileSizeSnapshot
--DROP TABLE dbo.DbSnapshot
--DROP TABLE dbo.[Snapshot]
--DROP TABLE Db
--GO
--DROP VIEW dbo.vFileSizeDetails
--DROP VIEW dbo.vFileSizeGrowth
--GO
--DROP PROCEDURE [Private].[SnapshotDiskUsage]
--DROP PROCEDURE [dbo].[TakeSnapshot]
--GO
--DROP SCHEMA [Private]
--GO

EXEC [dbo].[TakeSnapshot]


SELECT * FROM vFileSizeDetails

SELECT * FROM vFileSizeGrowth