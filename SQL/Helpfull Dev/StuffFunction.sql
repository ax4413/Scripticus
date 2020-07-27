/*
Get columns surrount by single quote, remove leading comma all using STUFF
*/
DECLARE @columns NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

SELECT @columns = STUFF(
	(
	SELECT ', ' + QUOTENAME(j.ProductID, CHAR(39)) AS [text()]
	FROM (SELECT p.ProductID
			FROM Product p
			WHERE p.Discontinued = 0)j
	FOR XML PATH('')
	), 1, 1, '');

SELECT @sql = 'UPDATE Product SET Discontinued = 0 WHERE ProductID in (' + @columns + ')';

SELECT @sql
--EXEC @sql;






-- execute dynamic sql statments

DECLARE @sql NVARCHAR(MAX);

SELECT @sql = STUFF((SELECT '; ' + j.query AS [text()]
	FROM (
			SELECT 'truncate table [' + name + ']' AS query 
			FROM sys.tables WHERE name LIKE 'Stage_%'
		)j
	FOR XML PATH('')), 1, 1, '');
	
EXEC(@sql)



/* Working with non illigal xml character >, <, / etc*/

DECLARE @sql NVARCHAR(MAX);

SELECT @sql = STUFF(
	(
		SELECT '; ' + j.query AS [text()]
		FROM (	
				SELECT 'select * from patint where dob > ''20100101''' AS Query
				FROM patient
			)j
		FOR XML PATH(''),TYPE).value('(./text())[1]','NVARCHAR(MAX)')
		, 1, 1, '');

PRINT(@sql);




/* Inserting carrage returns into scripts (usefull with GO statements) */
DECLARE @LineEnd VARCHAR(20) = CHAR(13)+CHAR(10);

DECLARE @imageSQL VARCHAR(MAX);

SELECT @imageSQL = STUFF((SELECT '' + j.query AS [text()]
	FROM (
			SELECT  'ALTER TABLE ' + QUOTENAME(t.name) + ' ADD [new_' + c.name + '] VarBinary(Max);' + @LineEnd
			+ 'GO' + @LineEnd
			+ 'UPDATE ' + QUOTENAME(t.name) + ' SET [new_' + c.name + '] = CONVERT(VarBinary(Max), ' + QUOTENAME(c.name) + ') FROM ' + QUOTENAME(t.name) + ';' + @LineEnd
			+ 'GO' + @LineEnd
			+ 'ALTER TABLE ' + QUOTENAME(t.name) + ' DROP COLUMN ' + QUOTENAME(c.name) + ';' + @LineEnd
			+ 'GO' + @LineEnd
			+ 'EXEC sp_rename ' + QUOTENAME('[dbo].' + QUOTENAME(t.name) + '.[new_'+ c.name +']', CHAR(39)) + ', ' + QUOTENAME(c.name, CHAR(39)) + ', ' + QUOTENAME('COLUMN',CHAR(39)) + ';' + @LineEnd
			+ 'GO' + @LineEnd AS Query
			FROM sys.columns c
			INNER JOIN sys.tables t ON c.object_id = t.object_id
			INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id
			WHERE t.is_ms_shipped = 0
			AND t.name != 'sysdiagrams'
			AND ty.name = 'image'
		)j
	FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		, 1, 0, '');
-- write
PRINT(@imageSQL)



SELECT DISTINCT STUFF((SELECT ', ' + name FROM sys.columns FOR XML PATH('')),1,1,'') AS List FROM sys.tables


-- GENARETE INSERT STATEMENTS
SELECT  DISTINCT 'SELECT' + STUFF((SELECT ', ' + name FROM sys.columns c where c.object_id = t.object_id FOR XML PATH('')),1,1,'') + ' FROM dbo.' + t.name AS q 
FROM    sys.tables t 
WHERE   t.name in ( 
  'TableName')
and t.schema_id = schema_id('dbo')



-- STUFF AS A CORRELATED SUB QUERY
SELECT *
FROM Patient px
OUTER APPLY(
		SELECT   px.PxID, List = STUFF((SELECT DISTINCT  ', ' + ConditionDesc AS [text()]
											FROM PatientMedicalCondition pmc 
												INNER JOIN MedicalCondition mc ON mc.MedicalConditionID = pmc.MedicalConditionID
                            WHERE pmc.PxID = px.PxID
                            FOR XML PATH ('')),1,1,'')) medCondition

/*	********************************************************************************************
	********************************************************************************************
	********************************************************************************************
*/

-- generate a comma seperated string using COALESCE

DECLARE @string AS VARCHAR(MAX);

-- Comma seperated list of branch ID's				###,###,###,###
SELECT @string = COALESCE(@string + ',' + CAST(branchid AS VARCHAR(36)), CAST(branchid AS VARCHAR(36)))
FROM Branch

SELECT @string AS  [Comma Seperated List]
SET @string = NULL;

-- Single Quoted Comma seperated list of branchIDs	'###','###','###','###'
SELECT @string = COALESCE(@string + ',' + QUOTENAME(CAST(branchid AS VARCHAR(36)),CHAR(39)), QUOTENAME(CAST(branchid AS VARCHAR(36)),CHAR(39))) 
FROM Branch

SELECT @string AS [Single Quoted Comma Seperated List]
SET @string = NULL;


-- Basic implemetation
--SELECT @string = COALESCE(@string + ',' + QUOTENAME(VALUE, CHAR(39)), QUOTENAME(VALUE, CHAR(39)))

--SELECT @string