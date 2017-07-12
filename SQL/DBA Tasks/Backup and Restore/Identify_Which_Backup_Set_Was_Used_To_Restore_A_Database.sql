DECLARE @DatabaseName NVARCHAR(128) = 'Target'

-- ====	If a database has been restored from a backup created on the same server then we can identify the backup that was used
SELECT	bs.database_name,
		rh.restore_history_id,
		rh.restore_date,
		rh.restore_type,
		rh.replace,
		rh.recovery,
		bs.backup_set_id,
		bs.database_name,
		bmf.physical_device_name
FROM	msdb..backupset bs
		INNER JOIN msdb..backupmediafamily bmf 
			ON bmf.media_set_id = bs.media_set_id
		INNER JOIN msdb..restorehistory rh
			ON rh.backup_set_id = bs.backup_set_id
WHERE	( @DatabaseName IS NULL OR bs.database_name = @DatabaseName )




-- ====	If a database has been restored from a backup created on a different server then it is a little bit more difficult to identify the backup from which the 
-- ====	db has been restored, but not impossible.

-- ====	If we know that @DatabaseName was restored from one of two backups then we need to restore the headers of these two backups looking for the following properties
-- ====	LastLSN
-- ==== CheckpointLSN
RESTORE HEADERONLY FROM DISK = 'C:\SqlFiles\Backup\1.bak'
RESTORE HEADERONLY FROM DISK = 'C:\SqlFiles\Backup\2.bak'

-- ====	Below are the mappings to identify which backupset was used
-- ====	LastLSN			=>	dbi_dbbackupLSN
-- ==== CheckpointLSN	=>	dbi_checkptLSN

DBCC DBINFO('Target') WITH TABLERESULTS