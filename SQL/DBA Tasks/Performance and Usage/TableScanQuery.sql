/* Get a list of table which have had a full scan in the last 24 hours for a given db*/
SELECT 	DB_NAME(sis.database_id) as DBName
		, ISNULL(i.name, 'Table') AS IndexName
		, ISNULL(SO.name, '') AS TableName
		, ps.used_page_count * 8 AS IndexSizeKB
		, ps.row_count
		, sis.user_seeks
		, sis.user_scans
		, sis.user_lookups
		, sis.user_updates
		, sis.last_user_scan
FROM 	sys.dm_db_index_usage_stats AS sis
		INNER JOIN sys.objects AS so 
			ON so.object_id = sis.object_id
		LEFT OUTER JOIN sys.indexes AS i 
			ON i.object_id = sis.object_id 
				AND i.index_id = sis.index_id
		INNER JOIN sys.dm_db_partition_stats AS ps 
			ON ps.object_id = sis.object_id 
				AND ps.index_id = sis.index_id
WHERE 	sis.database_id = DB_ID() 
		AND sis.last_user_scan > DATEADD(DAY,-1,GETDATE()) 
		AND i.name is null 
		AND so.type = 'U' 
		AND so.is_ms_shipped = 0 
		AND sis.user_scans > 0
ORDER BY ISNULL(SO.name, ''), DB_NAME(sis.database_id), sis.user_scans
