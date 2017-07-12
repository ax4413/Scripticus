USE [master]
-------------------------------------------------------------------------------------------------------------------
-- Initialize enviromental variables ------------------------------------------------------------------------------

	-- Set the name you wish to restore the database to or as
	DECLARE @DATABASE_NAME NVARCHAR(150)			= N'DDTest_linklater_wrk'

	-- Set the paths where the .bak & .trn files are kept
	DECLARE @BACKUP_FILE_PATH NVARCHAR(2000)		= N'D:\DDTesting';
	DECLARE @BAK_FILE_NAME NVARCHAR(500)			= N'Linklater_753085ee-0052-4a1b-ac1e-08dd67d1214b_backup_2012_12_20_060009_4403416';
	SET @BAK_FILE_NAME = @BAK_FILE_NAME + '.bak';

	-- Set the paths where you want to persist the .mdf & .ldf files
	DECLARE @RESTORE_MDF_FILE_PATH NVARCHAR(2000)	= N'D:\SqlDataFiles\' + @DATABASE_NAME + '.mdf'
	DECLARE @RESTORE_LDF_FILE_PATH NVARCHAR(2000)	= N'D:\SqlLogFiles\' +  @DATABASE_NAME + '_log.ldf'

	-- These logical file names need to be set -- The code to set them will be generated if they are not set, dont worry
	DECLARE @LOGICAL_MDF_FILE_NAME NVARCHAR(2000) = N''
	DECLARE @LOGICAL_LDF_FILE_NAME NVARCHAR(2000) = N''

	-- Declare dynamic sql variables
	DECLARE @BASE_SQL NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX);

-------------------------------------------------------------------------------------------------------------------

/*****************************************************************************************************************/
/************************************** FROM HERE ON EVERY THING IS AUTOMATED ************************************/
/*****************************************************************************************************************/


-------------------------------------------------------------------------------------------------------------------
-- Test to see if the logical file names have been set ------------------------------------------------------------

	IF @LOGICAL_MDF_FILE_NAME = '' OR @LOGICAL_LDF_FILE_NAME =''
	BEGIN
		-- Code to get the logical path details - Do NOT change
		SET @BASE_SQL = 'RESTORE FILELISTONLY FROM DISK = ''##BACKUP_FILE_PATH##\##DOT_BAK_FILE##''  WITH FILE=1;';
		SET @SQL = @BASE_SQL;
		SET @SQL = REPLACE(@SQL, '##BACKUP_FILE_PATH##', @BACKUP_FILE_PATH);
		SET @SQL = REPLACE(@SQL, '##DOT_BAK_FILE##', @BAK_FILE_NAME);
	
		-- Print the code requred to get the logical file names
		PRINT 'Sql to get logical file names: ' 
		PRINT @SQL
		PRINT '';

		RAISERROR('Logical file names are empty. These must be set to restore a db',18,18);
	END
	ELSE
	BEGIN
	---------------------------------------------------------------------------------------------------------------
	
	-- Restore a Database -----------------------------------------------------------------------------------------
	
		-- Base sql to restore a databse from a .bak file
		SET @BASE_SQL = 'RESTORE DATABASE [##DATABASE_NAME##] 
			FROM  DISK = N''##BACKUP_FILE_PATH##\##DOT_BAK_FILE##'' WITH  FILE = 1
			,  MOVE N''##LOGICAL_MDF_FILE_NAME##'' TO N''##RESTORE_MDF_FILE_PATH##''
			,  MOVE N''##LOGICAL_LDF_FILE_NAME##'' TO N''##RESTORE_LDF_FILE_PATH##''
			,  NOUNLOAD
			,  STATS = 10';

		-- Replace place holder text with enviromental variables
		SET @SQL = @BASE_SQL;
		SET @SQL = REPLACE(@SQL, '##DATABASE_NAME##', @DATABASE_NAME);
		SET @SQL = REPLACE(@SQL, '##BACKUP_FILE_PATH##', @BACKUP_FILE_PATH);
		SET @SQL = REPLACE(@SQL, '##DOT_BAK_FILE##', @BAK_FILE_NAME);
		SET @SQL = REPLACE(@SQL, '##LOGICAL_MDF_FILE_NAME##', @LOGICAL_MDF_FILE_NAME);
		SET @SQL = REPLACE(@SQL, '##RESTORE_MDF_FILE_PATH##', @RESTORE_MDF_FILE_PATH);
		SET @SQL = REPLACE(@SQL, '##LOGICAL_LDF_FILE_NAME##', @LOGICAL_LDF_FILE_NAME);
		SET @SQL = REPLACE(@SQL, '##RESTORE_LDF_FILE_PATH##', @RESTORE_LDF_FILE_PATH);


		-- Log and execute the sql
		PRINT @SQL
		PRINT '';
		EXEC(@SQL);
		PRINT '--------------------------------------------------------------'
		PRINT '';

	END
-------------------------------------------------------------------------------------------------------------------


GO








--RESTORE DATABASE [BNL_live] 
--	FROM  DISK = N'D:\DDTesting\BNL_e1cab0e8-7d67-499e-8f95-104c36f33298_backup_2012_12_21_073002_4407906.bak' WITH  FILE = 1
--	,  MOVE N'BNL_e1cab0e8-7d67-499e-8f95-104c36f33298' TO N'D:\SqlDataFiles\BNL_live.mdf'
--	,  MOVE N'BNL_e1cab0e8-7d67-499e-8f95-104c36f33298_log' TO N'D:\SqlLogFiles\BNL_live.ldf'
--	,  NOUNLOAD
--	,  STATS = 10

--GO