set nocount on

DECLARE @sql VARCHAR(MAX) = '
RAISERROR(''{db} drop starting...'', 0, 0) WITH NOWAIT
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N''{db}''
GO
USE [master]
GO
DROP DATABASE [{db}]
GO
RAISERROR(''{db} drop complete'', 0, 0) WITH NOWAIT
GO


'

SELECT  db  = '-- ' + name
      , sql = REPLACE(@sql, '{db}', name) 
FROM    sys.databases 
WHERE   name LIKE 'xx%'
ORDER BY 
        COALESCE(DB_NAME(source_database_id), name)
      , CASE WHEN source_database_id IS NOT NULL THEN 0 ELSE 1 END


