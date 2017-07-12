-- -------------------------------------------------------------------------------------------------
-- SCRIPT TO GENERATE SQL USERS AND PERMISIONS FOR EACH DATABASE ON A SERVER
-- -------------------------------------------------------------------------------------------------

-- The first non system DB
DECLARE @DBID INT = 7;
-- The name of a specific DB to apply users too, NULL = all DBs
DECLARE @DBNAME VARCHAR(150) = NULL

SELECT *
FROM (
	-- Syntax to generate windows authentication user & ServUser 
	-- creation and deletion scripts for each OPTIX login
	-- for each database with adb_id > 7 (this will need changing).
	SELECT d.name DBName, l.loginname UserName
		, 'USE ['+ d.name +']
		GO
		IF NOT EXISTS ( SELECT * FROM SYS.sysusers WHERE name = '''+ L.loginname +''' )
		BEGIN
			CREATE USER ['+ l.loginname + '] FOR LOGIN ['+ l.loginname + '] WITH DEFAULT_SCHEMA=[dbo];

			EXEC sp_addrolemember db_datareader, ['+ l.loginname + '] 

			EXEC sp_addrolemember db_datawriter , ['+ l.loginname + '] ;

			EXEC sp_addrolemember db_backupoperator , ['+ l.loginname + '] ;

			GRANT EXECUTE TO ['+ l.loginname + '] ;

		END
		GO
		' AS CreateUserSyntax

		, 'USE ['+ d.name +']
		GO
		DROP USER ['+ L.loginname +']
		GO' AS DropUserSyntax
	FROM sys.databases d 
		CROSS JOIN (SELECT loginname 
					FROM sys.syslogins 
					WHERE loginname like'OPTIX\%' 
						OR loginname = 'ServUser') l
	WHERE d.database_id >= @DBID
		AND d.is_read_only = 0

	UNION ALL

	-- Syntax to generate ServAdmin creation and deletion scripts for each OPTIX login
	-- for each database with adb_id > 7 (this will need changing).
	SELECT d.name DBName, l.loginname UserName
		, 'USE ['+ d.name +']
		GO
		IF NOT EXISTS ( SELECT * FROM SYS.sysusers WHERE name = '''+ L.loginname +''' )
		BEGIN
			CREATE USER ['+ l.loginname + '] FOR LOGIN ['+ l.loginname + '] WITH DEFAULT_SCHEMA=[dbo];
			EXEC sp_addrolemember db_datareader, ['+ l.loginname + '] 
			EXEC sp_addrolemember db_datawriter , ['+ l.loginname + '] ;
			EXEC sp_addrolemember db_ddladmin , ['+ l.loginname + '] ;
			EXEC sp_addrolemember db_owner  , ['+ l.loginname + '] ;
			GRANT EXECUTE TO ['+ l.loginname + '] ;
		END
		GO
		' AS CreateUserSyntax

		, 'USE ['+ d.name +']
		GO
		DROP USER ['+ L.loginname +']
		GO' AS DropUserSyntax

	FROM sys.databases d 
		CROSS JOIN (SELECT loginname 
					FROM sys.syslogins 
					WHERE loginname ='ServAdmin' ) l
	WHERE d.database_id >= @DBID
		AND d.is_read_only = 0
)Q
WHERE (@DBName IS NULL OR Q.DBName = @DBName)
ORDER BY Q.DBName, Q.UserName;





---- Find out which logins are users of this Database
-- SELECT * FROM SYS.sysusers WHERE name = 'OPTIX\stephen.yeadon' 

---- Find out which schemas are owned by me
--USE [Database]
--SELECT s.name, USER_NAME(s.principal_id)
--FROM sys.schemas s
--WHERE s.principal_id = USER_ID('OPTIX\stephen.yeadon');

---- Remove me as thw owner of a particular schema
--ALTER AUTHORIZATION ON SCHEMA::db_datareader TO dbo;
--ALTER AUTHORIZATION ON SCHEMA::db_datawriter TO dbo;


--select object_name(major_id), user_name(grantee_principal_id), *
--from sys.database_permissions p
--order by p.state_desc

--SELECT name, permission_name, state_desc,*
--FROM sys.database_principals dp
--INNER JOIN sys.server_permissions sp
--ON dp.principal_id = sp.grantee_principal_id
--WHERE name = 'guest' 
--AND permission_name = 'CONNECT'


