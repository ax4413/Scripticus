




DECLARE @backup_type       VARCHAR(1)   = 'L'  /* 'F' (Full) or 'L' (transaction log) */
DECLARE @dbname            VARCHAR(128) = NULL
DECLARE @backupDrive       VARCHAR(500) = 'J:\BACKUP\'
DECLARE @transLogBackupCmd VARCHAR(MAX) 
DECLARE @fullBackupCmd     VARCHAR(MAX)


-- validation
IF(@backup_type IS NULL OR (@backup_type != 'F' AND @backup_type != 'L')) BEGIN
    RAISERROR ('The @backup_type variable must be either F or L. NO OTHER VALUE IS SUPPORTED', 18, 1)
    RETURN
END


IF(OBJECT_ID('tempdb..#backup_sql') is not null)
  DROP TABLE #backup_sql


-- set up our templates
SET @transLogBackupCmd = '
BACKUP LOG [#DbName#] 
TO  DISK = N''#BackupDrive#\#BackupName#'' WITH NOFORMAT, NOINIT,  
    NAME = N''#DbName#-Transaction Log Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
'
SET @fullBackupCmd    = '
BACKUP DATABASE [#Dbname#] TO  DISK = N''#BackupDrive#\#BackupName#'' WITH NOFORMAT, NOINIT,  NAME = N''#DbName#-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
'


-- the query
SELECT  database_id          = d.database_id
      , database_name        = d.name
      , backup_type          = bs.type
      , backup_dir           = @backupDrive
      , physical_device_name = bmf.physical_device_name
      , backup_finish_date   = MAX(bs.backup_finish_date) OVER (PARTITION BY bs.database_name) 
      , backup_translog_name = d.name + parsename(replace(replace(replace(convert(varchar(50), getdate(), 121), '-', ''), ':',''), ' ', '_'),2)
      , backup_translog_cmd  = @transLogBackupCmd
      , backup_full_name     = d.name + parsename(replace(replace(replace(convert(varchar(50), getdate(), 121), '-', ''), ':',''), ' ', '_'),2)
      , backup_full_cmd      = @fullBackupCmd
INTO    #backup_sql
FROM    sys.databases d 
        LEFT OUTER JOIN msdb.dbo.backupset bs ON OBJECT_id(bs.database_name) = d.database_id
        LEFT OUTER JOIN  msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   (@dbname IS NULL OR d.name LIKE @dbname)
  AND   d.recovery_model_desc = 'FULL'
  AND   d.database_id > 5


UPDATE  #backup_sql 
SET     backup_translog_cmd = REPLACE(REPLACE(REPLACE(backup_translog_cmd, '#DbName#', database_name), '#BackupDrive#', backup_dir), '#BackupName#', backup_translog_name)
      , backup_full_cmd     = REPLACE(REPLACE(REPLACE(backup_full_cmd,     '#DbName#', database_name), '#BackupDrive#', backup_dir), '#BackupName#', backup_full_name)


-- SELECT * FROM #backup_sql /*



DECLARE @backup_translog_cmd VARCHAR(MAX)
DECLARE @backup_full_cmd     VARCHAR(MAX)

DECLARE Db_Cursor CURSOR FOR
	SELECT  backup_translog_cmd, backup_full_cmd
	FROM    #backup_sql
  ORDER BY database_name

OPEN Db_Cursor;  

FETCH NEXT FROM Db_Cursor INTO @backup_translog_cmd, @backup_full_cmd  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    IF(@backup_type = 'F') BEGIN 
        RAISERROR(@backup_full_cmd, 0, 0) WITH NOWAIT
        EXEC(@backup_full_cmd)
    END
    ELSE BEGIN
        RAISERROR(@backup_translog_cmd, 0, 0) WITH NOWAIT
        EXEC(@backup_translog_cmd)
    END
    FETCH NEXT FROM Db_Cursor INTO @backup_translog_cmd, @backup_full_cmd  
END;  

CLOSE Db_Cursor;  
DEALLOCATE Db_Cursor;  


--*/