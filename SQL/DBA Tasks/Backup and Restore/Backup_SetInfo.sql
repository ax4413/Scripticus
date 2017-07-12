--	======	=================================================================================================== 
--	======	A collection of scripts to query the MSDB backup tables.
--	======	
--	======	This script should be run against the db you are intersetd in finding backup set information about
--	======	Each script sbipit is independent of the next
--	======	===================================================================================================



--	======	=================================================================================================== 
--	======	Show the last 10 database backups for the current database
--	======	===================================================================================================
SELECT TOP 10
	CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Server]
    , BS.database_name
    , BS.backup_start_date
    , BS.backup_finish_date
    , BS.expiration_date
    , CASE BS.[type] WHEN 'D' THEN 'Database' WHEN 'L' THEN 'Log' END AS backup_type
    , BS.backup_size
    , BF.logical_device_name
    , BF.physical_device_name
    , BS.name AS backupset_name
    , BS.[description ]
FROM msdb.dbo.backupmediafamily BF 
   INNER JOIN msdb.dbo.backupset BS ON BF.media_set_id = BS.media_set_id 
WHERE ( BS.database_name = db_name() )  
ORDER BY BS.database_name, 
   BS.backup_start_date DESC
;



--	======	=================================================================================================== 
--	======	Show all Database Backups created today 
--	======	===================================================================================================
DECLARE @CutOffDate DATETIME;
SELECT  @CutOffDate = DATEADD(DAY, 0, DATEDIFF(DAY, 0,GETDATE()));

SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Server]
    , msdb.dbo.backupset.database_name
    , msdb.dbo.backupset.backup_start_date
    , CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102)
    , msdb.dbo.backupset.backup_finish_date
    , msdb.dbo.backupset.expiration_date
    , CASE msdb..backupset.type WHEN 'D' THEN 'Database' WHEN 'L' THEN 'Log' END AS backup_type
    , msdb.dbo.backupset.backup_size
    , msdb.dbo.backupmediafamily.logical_device_name
    , msdb.dbo.backupmediafamily.physical_device_name
    , msdb.dbo.backupset.name AS backupset_name
    , msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE ( msdb.dbo.backupset.backup_start_date >= @CutOffDate )  
ORDER BY msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_finish_date DESC
;



--	======	===================================================================================================
--	======	Show the most recent database backup for each database 
--	======	===================================================================================================
SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Server]
    , msdb.dbo.backupset.database_name
    , MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date 
FROM msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE msdb..backupset.type = 'D' 
GROUP BY msdb.dbo.backupset.database_name  
ORDER BY msdb.dbo.backupset.database_name
;



--	======	===================================================================================================
--	======	Show the most recent trans log backup for each database 
--	======	===================================================================================================
SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Server]
    , msdb.dbo.backupset.database_name
    , MAX(msdb.dbo.backupset.backup_finish_date) AS last_trans_log_backup_date 
FROM msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE msdb..backupset.type = 'L' 
GROUP BY msdb.dbo.backupset.database_name  
ORDER BY msdb.dbo.backupset.database_name
;



--	======	===================================================================================================
--	======	Returns a result set containing all the backup header information for all backup sets on a 
--	======	particular backup device.
--	======	===================================================================================================
RESTORE HEADERONLY 
FROM DISK = N'###' 
WITH NOUNLOAD;
GO