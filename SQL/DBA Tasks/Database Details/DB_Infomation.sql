-- ====	DB HEALTH & GENRAL INFOMATION
SELECT	[DBID]					= DB.database_id,
		[DBName]				= CONVERT(VARCHAR(25), DB.name),
		[CreationDate]			= CONVERT( VARCHAR(20), DB.create_date, 103) + ' ' + CONVERT(VARCHAR(20), DB.create_date, 108 ),
		[State]					= DB.state_desc,
		[DataFiles]				= ( SELECT	COUNT(1) 
									FROM	sys.master_files MF 
									WHERE	MF.database_id = DB.database_id 
											AND MF.type_desc = 'rows' ),
		[DataMB]				= ( SELECT	SUM((MF.size*8)/1024) 
									FROM	sys.master_files  MF
									WHERE	MF.database_id = DB.database_id 
											AND MF.type_desc = 'rows' ),
		[LogFiles]				= ( SELECT	COUNT(1) 
									FROM	sys.master_files MF
									WHERE	MF.database_id = DB.database_id 
											AND type_desc = 'log' ),
		[LogMB]					= ( SELECT	SUM((MF.size*8)/1024) 
									FROM	sys.master_files MF
									WHERE	MF.database_id  = DB.database_id 
											AND type_desc = 'log' ),
		[UserAccess]			= DB.user_access_desc,
		[RecoveryModel]			= DB.recovery_model_desc,
		[LastBackup]			= ISNULL( ( SELECT TOP 1 CASE TYPE WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction log' END + ' – ' +
													LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(),Backup_finish_date))) + ' days ago', 'NEVER')) + ' – ' +
													CONVERT(VARCHAR(20), backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) + ' – ' +
													CONVERT(VARCHAR(20), backup_finish_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_finish_date, 108) +
													' (' + CAST(DATEDIFF(second, BK.backup_start_date, BK.backup_finish_date) AS VARCHAR(4)) + ' ' + 'seconds)'
											FROM msdb..backupset BK 
											WHERE BK.database_name = DB.name 
											ORDER BY backup_set_id DESC ), '-' ),
		[CompatibilityLevel]	= CASE DB.compatibility_level
									WHEN 60  THEN '60  (SQL Server 6.0)'
									WHEN 65  THEN '65  (SQL Server 6.5)'
									WHEN 70  THEN '70  (SQL Server 7.0)'
									WHEN 80  THEN '80  (SQL Server 2000)'
									WHEN 90  THEN '90  (SQL Server 2005)'
									WHEN 100 THEN '100 (SQL Server 2008)'
									WHEN 110 THEN '110 (SQL Server 2012)'
								END, 	
		[Collation]				= DB.Collation_Name,
		[SnapshotIssolation]	= CASE WHEN DB.snapshot_isolation_state = 1 THEN 'Snaphot Issolation on' ELSE '-' END,	
		[ReadCommitedSnapshot]	= CASE WHEN DB.is_read_committed_snapshot_on = 1 THEN 'Read commited snaphot on' ELSE '-' END,	
		[PageVerifyOption]		= DB.page_verify_option_desc,
		[FullText]				= CASE WHEN DB.is_fulltext_enabled = 1 THEN 'Fulltext enabled' ELSE '-' END,
		[AutoClose]				= CASE WHEN DB.is_auto_close_on = 1 THEN 'Auto close' ELSE '-' END,
		[ReadOnly]				= CASE WHEN DB.is_read_only = 1 THEN 'Read only' ELSE '-' END,
		[AutoShrink]			= CASE WHEN DB.is_auto_shrink_on = 1 THEN 'Auto shrink on' ELSE '-' END,
		[AutoCreateStatistics]	= CASE WHEN DB.is_auto_create_stats_on = 1 THEN 'Auto create statistics on' ELSE '-' END,
		[Standby]				= CASE WHEN DB.is_in_standby = 1 THEN 'Standby' ELSE '-' END,
		[CleanlyShutdown]		= CASE WHEN DB.is_cleanly_shutdown = 1 THEN 'Cleanly shutdown' ELSE '-' END,
		[Trustworthy]			= CASE WHEN DB.is_trustworthy_on = 1 THEN 'Trustworrthy DB' ELSE '-' END,
		[DbChaining]			= CASE WHEN DB.is_db_chaining_on = 1 THEN 'Db chaining on' ELSE '-' END,
		[Broker]				= CASE WHEN DB.is_broker_enabled = 1 THEN 'Broker enabled' ELSE '-' END
		, CASE WHEN db.name like'%MAIN%' THEN 'Main' WHEN db.name like'%DOCUMENTS%' THEN 'Documents' WHEN db.name like'%EXTERNAL%' THEN 'External' ELSE 'Other' END
		,*
FROM	sys.databases DB
--WHERE	DB.database_id > 4
--		AND CONVERT(VARCHAR(25), DB.name) NOT LIKE '%ReportServer%'
ORDER BY [DBName], [LastBackup] DESC ;



-- ====	DB FILE SIZES AND THE ACTIVENESS OF THE DBS - (ORDER BY BYTES READ TO ACHIVE THIS)
SELECT	[Database_Name]		= DB_NAME(mf.database_id),
		[File_Logical_Name]	= name,
		[File_Type_Desc]	= CASE
								WHEN type_desc = 'LOG' THEN 'Log File'
								WHEN type_desc = 'ROWS' THEN 'Data File'
								ELSE type_desc
							END,
		mf.physical_name,
		num_of_reads,
		num_of_bytes_read,
		io_stall_read_ms,
		num_of_writes,
		num_of_bytes_written,
		io_stall_write_ms,
		io_stall,
		size_on_disk_bytes,
		[Size_on_disk_KB]	= CAST( ROUND( ( size_on_disk_bytes / 1024.0 ), 2 ) AS FLOAT ),
		[Size_on_disk_MB]	= CAST( ROUND( ( size_on_disk_bytes / 1024 / 1024.0 ), 2) AS FLOAT ),
		[Size_on_disk_GB]	= CAST( ROUND( ( size_on_disk_bytes / 1024 / 1024 / 1024.0 ), 2 ) AS FLOAT )
FROM	sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs
		INNER JOIN sys.master_files AS mf 
			ON mf.database_id = divfs.database_id
				AND mf.FILE_ID = divfs.FILE_ID
ORDER BY Database_name, File_type_desc ;



-- ====	Database file names on a server
SELECT	[DB Name]		= db_name(database_id),
		[FileName] 		= name,
		[FileType] 		= type_desc,
		[FileLocation]	= physical_name,
		[Status]		= state_desc,
		[Size]			= size,
		[MaxSize]		= max_size,
		[Growth]		= growth
FROM 	sys.master_files
ORDER BY physical_name, type_desc ;




-- ====	The following query returns which database is very busy and which database is bit slow 
-- ====	because of IO issue. Sometime, and which MDF or NDF is busiest and doing most of the work. 
SELECT	[DatabaseName]	= DB_NAME(vfs.DbId),
		mf.name,
		mf.physical_name,
		vfs.BytesRead,
		vfs.BytesWritten,
		vfs.IoStallMS,
		vfs.IoStallReadMS,
		vfs.IoStallWriteMS,
		vfs.NumberReads,
		vfs.NumberWrites,
		(Size *8 ) / 1024 Size_MB
FROM	::fn_virtualfilestats(NULL,NULL) vfs	-- :: (the double colon) allows access to system functions in sql 2000 and earlier
		INNER JOIN sys.master_files mf 
			ON mf.database_id = vfs.DbId
				AND mf.FILE_ID = vfs.FileId;




-- ====	Returns the current setting of the specified database option or property for the specified database.
-- ====	http://technet.microsoft.com/en-us/library/ms186823.aspx
SELECT 	DATABASEPROPERTYEX(db_name(db_id()), 'status')



-- ===  database size
SELECT  name, physical_name
      , PageCount       =         CAST( FILEPROPERTY(name, 'spaceused') AS BIGINT)
      , DbSizeInBytes   = CAST(   CAST( FILEPROPERTY(name, 'spaceused') AS BIGINT) * 8192.00                        AS DECIMAL(18,4) )
      , DbSizeInMB      = CAST( ( CAST( FILEPROPERTY(name, 'spaceused') AS BIGINT) * 8192.00 ) / 1024 / 1024        AS DECIMAL(18,4) )
      , DbSizeInGB      = CAST( ( CAST( FILEPROPERTY(name, 'spaceused') AS BIGINT) * 8192.00 ) / 1024 / 1024 / 1024 AS DECIMAL(18,4) )
FROM sys.database_files
WHERE type_desc = 'ROWS';