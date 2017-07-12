DECLARE @row_num     INT
      , @max_row_num INT
      , @schema      SYSNAME
      , @table       SYSNAME
      , @index       SYSNAME
      , @sql         NVARCHAR(4000)
      , @level_of_fragmentation DECIMAL(7,2)

IF(OBJECT_ID('tempdb.dbo.#Fragmented') IS NOT NULL)
	  DROP TABLE #Fragmented

SELECT  [row_num]                 = IDENTITY(INT, 1, 1)
      , [schema_name]             = SCHEMA_NAME(t.schema_id)
	    , [table_name]              = t.name
      , [index_name]              = i.name
	    , [level_of_fragmentation]  = ps.avg_fragmentation_in_percent
INTO    #Fragmented
FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ps
		    INNER JOIN sys.indexes AS i
				        ON  ps.OBJECT_ID = i.OBJECT_ID 
                AND ps.index_id = i.index_id
		    INNER JOIN sys.tables t 
				        ON  t.object_id = ps.object_id
WHERE   ps.database_id = DB_ID()
  AND		ps.index_id > 0
  AND   ps.avg_fragmentation_in_percent > 0
  AND   ps.page_count > 500
ORDER BY ps.avg_fragmentation_in_percent DESC

RAISERROR('Initial query complete', 0, 0, @schema, @table) WITH NOWAIT


SELECT	* FROM	#Fragmented


DECLARE _cursor CURSOR FOR
	SELECT  f.row_num
        , f.schema_name
		    , f.table_name
        , f.index_name
        , f.level_of_fragmentation
        , ( SELECT MAX(row_num) from #Fragmented )
	FROM	  #Fragmented f
	
OPEN _cursor
FETCH NEXT FROM _cursor
INTO @row_num, @schema, @table, @index, @level_of_fragmentation, @max_row_num

WHILE @@FETCH_STATUS = 0  
BEGIN 
    IF(@level_of_fragmentation < 30.00)
        SET @sql = N'ALTER INDEX ' + @index + ' ON ' + QUOTENAME(@schema) +'.' + QUOTENAME(@table) +' REORGANIZE ; '
    ELSE
        SET @sql = N'ALTER INDEX ' + @index + ' ON ' + QUOTENAME(@schema) +'.' + QUOTENAME(@table) +' REBUILD ; '
    
    RAISERROR('%i/%i Processing %s on %s.%s ...', 0, 0, @row_num, @max_row_num, @index, @schema, @table) WITH NOWAIT
    EXEC sp_executesql @sql

    FETCH NEXT FROM _cursor
    INTO @row_num, @schema, @table, @index, @level_of_fragmentation, @max_row_num
END
CLOSE _cursor;  
DEALLOCATE _cursor;  

RAISERROR('Processing complete', 0, 0, @schema, @table) WITH NOWAIT
