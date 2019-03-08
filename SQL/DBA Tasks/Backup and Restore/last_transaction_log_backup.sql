
; WITH backup_history AS (
  SELECT  DB_ID(bs.database_name) database_id, bs.database_name, MAX(bs.backup_finish_date) backup_finish_date
  FROM    msdb.dbo.backupmediafamily  bmf
          INNER JOIN msdb.dbo.backupset bs ON bmf.media_set_id = bs.media_set_id 
  WHERE   bs.type = 'L'  -- log
  GROUP BY bs.database_name
  --HAVING MAX(bs.backup_finish_date) < DATEADD(DAY, -1, GETDATE())
)

SELECT  bh.*, 
        mf.name logical_file_name, mf.physical_name physical_file_name, 
        mf.size file_size, mf.max_size max_file_size, mf.max_size - mf.size file_free_space,
        mf.state_desc file_state, mf.is_media_read_only, d.state_desc database_state
FROM    backup_history bh 
        INNER JOIN sys.master_files mf ON bh.database_id = mf.database_id
        INNER JOIN sys.databases d ON d.database_id = bh.database_id
WHERE   mf.type = 1
  AND   d.recovery_model_desc = 'FULL'
ORDER BY mf.max_size - mf.size 
