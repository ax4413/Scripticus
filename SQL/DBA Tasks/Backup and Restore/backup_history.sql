-- Get Backup History for required database
SELECT  TOP 100  
        database_name        = s.database_name
      , physical_device_name = m.physical_device_name
      , backup_Size          = CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB'
      , time_taken           = CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' 
      , backup_start_date    = s.backup_start_date
      , first_lsn            = CAST(s.first_lsn AS VARCHAR(50))
      , last_lsn             = CAST(s.last_lsn AS VARCHAR(50)) 
      , backup_type          = CASE s.[type] 
                                 WHEN 'D' THEN 'Full'
                                 WHEN 'I' THEN 'Differential'
                                 WHEN 'L' THEN 'Transaction Log'
                               END
      , server_name          = s.server_name
      , recovery_model       = s.recovery_model
FROM    msdb.dbo.backupset s
        INNER JOIN msdb.dbo.backupmediafamily m   
                ON s.media_set_id = m.media_set_id
WHERE   s.database_name = DB_NAME()
ORDER BY 
        backup_start_date DESC
      , backup_finish_date
GO