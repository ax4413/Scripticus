
/*	SELECT STORED PROCS THAT CONTAIN TEXT WITHIN THE STORED PROC ITS SELF	********************************************************/

SELECT Name, OBJECT_ID 
FROM sys.procedures
WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%PatientNotes%'
ORDER BY Name


/* select stored procedures which have paramateres of type x and y */
SELECT p.name AS ProcedureName, pa.name AS ParamName, t.name AS TypeName
FROM sys.procedures p
	INNER JOIN sys.parameters pa ON pa.object_id = p.object_id
	INNER JOIN sys.types t ON t.user_type_id = pa.user_type_id
WHERE p.is_ms_shipped = 0
	AND (t.name = 'x' OR t.name = 'y' )
ORDER BY p.name, pa.name

-------------------------------------------------------------------------------------------------------------------------------------

/* GENERATE SQL TO QUERY EVEY COLUMN OF EVERY TABLE FOR A PREDICATE ***************************************************************/

DECLARE @queryString AS VARCHAR(50)
SET @queryString = '''%QUERYSTRING%'''

SELECT 'select * from [' + C.table_name + '] where [' + C.column_name + '] like ' + @queryString
FROM information_schema.columns C 
	INNER JOIN information_schema.tables T ON C.table_name = T.table_name
WHERE T.table_type='base table'

-------------------------------------------------------------------------------------------------------------------------------------


/* GET HELP ABOUT DATABASE OBJECTS	************************************************************************************************/

sp_help [PxSummaryWarehouse]

-------------------------------------------------------------------------------------------------------------------------------------


/*	GENERATE 8000 CHARACTERS FROM THE ALPHABET	************************************************************************************/

SELECT REPLICATE('ABCDEFGHIJKLMNOPQRSTUVWXYZ',8000)

-------------------------------------------------------------------------------------------------------------------------------------

/* BUILT IN SPROC TO QUERY EACH DB OR TABLE ****************************************************************************************/

/* execut a command against each db on a instance */ 
EXECUTE sp_MSforeachdb 'USE [?]; EXEC sp_helpfile'

/* execute a command against each table in a db */
EXECUTE sp_MSforeachtable 'EXECUTE sp_spaceused [?];';

-------------------------------------------------------------------------------------------------------------------------------------

/*  DROP IF EXISTS *****************************************************************************************************************/


/*	DROP A TABLE IF IT EXISTS */
IF EXISTS(SELECT name FROM sysobjects WHERE name = N'TableName' AND xtype='U')
	DROP TABLE bob


/* DROP A TEMP TABLES IF IT EXISTS */
IF OBJECT_ID('tempdb..#TableName') IS NOT NULL
BEGIN
   DROP TABLE #bob
END

-------------------------------------------------------------------------------------------------------------------------------------