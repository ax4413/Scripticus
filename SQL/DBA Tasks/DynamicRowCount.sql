
IF(OBJECT_ID('tempdb.dbo.#Results') IS NOT NULL)
    DROP TABLE #Results
CREATE TABLE #Results([SchemaName] SYSNAME, [TableName] SYSNAME, [RowCount] BIGINT)


DECLARE @CurrentSql VARCHAR(2000)


DECLARE RowCount_Cursor CURSOR FOR 
SELECT  'INSERT INTO #Results ([SchemaName], [TableName], [RowCount]) '
        + 'SELECT ' + QUOTENAME(SCHEMA_NAME(schema_id), CHAR(39)) + ' AS SchemaName, ' 
        + QUOTENAME(name, CHAR(39)) + ' AS [TableName], '
        + 'COUNT(*) AS [RowCount] '
        + 'FROM ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
FROM    sys.tables
ORDER BY name

OPEN RowCount_Cursor

FETCH NEXT FROM RowCount_Cursor 
INTO @CurrentSql

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC(@CurrentSql)
    PRINT @CurrentSql

    FETCH NEXT FROM RowCount_Cursor INTO @CurrentSql
END

CLOSE RowCount_Cursor;
DEALLOCATE RowCount_Cursor;

SELECT  * 
FROM    #Results 
ORDER BY SchemaName, TableName