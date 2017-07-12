-- ====	How much space is fee on our sql server

EXEC MASTER..xp_fixeddrives

SELECT	DISTINCT 
		[LogicalName]	= dovs.logical_volume_name,
		[Drive]			= dovs.volume_mount_point,
		[FreeSpaceInMB] = CONVERT(INT, dovs.available_bytes/1048576.0)
FROM	sys.master_files mf
		CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
ORDER BY FreeSpaceInMB ASC


SELECT	DISTINCT 
		[DBName]				= DB_NAME(dovs.database_id),
		[PhysicalFileLocation]	= mf.physical_name,
		[LogicalName]			= dovs.logical_volume_name,
		[Drive]					= dovs.volume_mount_point,
		[FreeSpaceInMB]			= CONVERT(INT, dovs.available_bytes/1048576.0)
FROM	sys.master_files mf
		CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
ORDER BY FreeSpaceInMB ASC