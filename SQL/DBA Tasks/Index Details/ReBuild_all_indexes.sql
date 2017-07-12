DECLARE @schema SYSNAME
      , @table  SYSNAME
      , @sql    NVARCHAR(4000)

DECLARE _cursor CURSOR FOR
	SELECT  SCHEMA_NAME(t.schema_id)
		  , t.name TableName
		  --, sum(avg_fragmentation_in_percent)
	FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ps
			INNER JOIN sys.indexes AS i
					ON ps.OBJECT_ID = i.OBJECT_ID AND ps.index_id = i.index_id
			INNER JOIN sys.tables t 
					on t.object_id = ps.object_id
	WHERE   ps.database_id = DB_ID()
	AND		ps.index_id > 0
	GROUP BY  SCHEMA_NAME(t.schema_id)
		  , t.name
	HAVING	SUM(avg_fragmentation_in_percent) > 0
	ORDER BY SUM(avg_fragmentation_in_percent) DESC
	

OPEN _cursor
FETCH NEXT FROM _cursor
 INTO @schema, @table

WHILE @@FETCH_STATUS = 0  
BEGIN 
    SET @sql = N'ALTER INDEX ALL ON ' + QUOTENAME(@schema) + '.' + quotename(@table) + ' REBUILD'
    
    RAISERROR('Processing %s.%s ...', 0, 0, @schema, @table) WITH NOWAIT
    EXEC sp_executesql @sql

    FETCH NEXT FROM _cursor
     INTO @schema, @table
END
CLOSE _cursor;  
DEALLOCATE _cursor;  

RAISERROR('Processing complete', 0, 0, @schema, @table) WITH NOWAIT