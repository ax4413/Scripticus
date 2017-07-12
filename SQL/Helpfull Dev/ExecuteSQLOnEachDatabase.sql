use MetaDB
/*
This script will need to be run against the metaDB on all servers where we house customer DB's

This script will provide you with a list of orgaisations and their latest opening hours for
a given day.

The @StartDate variable needs to be set 
*/
USE MetaDB

-- Create a table to hold the result set. this result set will be local to the MetaDB
IF object_id('tempdb..#Results') IS NOT NULL
	BEGIN
   DROP TABLE #Results;
END
CREATE TABLE #Results(ServerName Varchar(100), DBName VarChar(100), data VarChar(150));

-- Create variables
DECLARE @sql VarChar(max);
DECLARE @DBName VarChar(100);

-- get the first db name from the meta list where the db is a customer database
SELECT @DBName = min(DBName) 
FROM DBMetaList
WHERE CustomerDB = 1


-- Loop the customer dbs on this server
WHILE @DBName is not null
BEGIN

	-- Create the dynamic sql for this db
	SET @sql = 
	'INSERT INTO #Results
	SELECT ''' + @@SERVERNAME +''',''' + @DBName + ''' as DBName, TracerName 
	from [' + @DBName + ']..branchTracer
	'
	
	--PRINT @SQL
	
	-- execute the code
	EXEC(@sql)
	
	-- get the next customer db from the list
	SELECT @DBName = min(DBName) 
	FROM DBMetaList
	WHERE CustomerDB = 1 
		AND DBName > @DBName

END

-- veiw your results
select *
from #Results

-- drop temp results table
drop table #Results