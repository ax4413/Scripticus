USE [master]

--============================================================================================================================
-- 1) SET ENIROMET VARIABLES
-- 2) RESTORE .BAK FILE IN NO RECOVERY MODE
-- 3) RESTORE .TRN LOG FILES
-- 4) RESTORE FINAL .TRN LOG FILE TO A POINT IN TIME IF @STOP_AT_TIME IS NOT NULL
--============================================================================================================================

------------------------------------------------------------------------------------------------------------------------------
-- Set enviromental variable -------------------------------------------------------------------------------------------------

	-- Set the name you wish to restore the database to or as
	DECLARE @DATABASE_NAME NVARCHAR(150)			= N'DDCollectionsProduction';

	-- Set the paths where the .bak & .trn files are kept
	DECLARE @BACKUP_FILE_PATH NVARCHAR(2000)		= N'D:\DDTesting';
	DECLARE @BAK_FILE_NAME NVARCHAR(500)			= N'0.bak';

	-- Set the paths where you want to persist the .mdf & .ldf files
	DECLARE @RESTORE_MDF_FILE_PATH NVARCHAR(2000)	= N'D:\SqlDataFiles\' + @DATABASE_NAME + '.mdf'
	DECLARE @RESTORE_LDF_FILE_PATH NVARCHAR(2000)	= N'D:\SqlLogFiles\' +  @DATABASE_NAME + '_log.ldf'
	
	-- Initialize the trans log name to 1 as 0 is reservedfor the bak file name
	DECLARE @TRNS_LOG_ID INT = 1;
	-- This is the file name of the final .trn file which you want to restore
	DECLARE @FINAL_TRNS_LOG_ID INT = 16;

	-- These logical file names need to be set -- The code to set them will be generated if they are not set, dont worry
	DECLARE @LOGICAL_MDF_FILE_NAME NVARCHAR(2000) = N'';
	DECLARE @LOGICAL_LDF_FILE_NAME NVARCHAR(2000) = N'';

	-- Set the time you wish to restore the last .trn file up to
	DECLARE @STOP_AT_TIME DATETIME = '2012-12-20 12:00';

	-- Declare dynamic sql variables
	DECLARE @BASE_SQL NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------------


/****************************************************************************************************************************/
/************************************** FROM HERE ON EVERY THING IS AUTOMATED ***********************************************/
/****************************************************************************************************************************/

	--------------------------------------------------------------------------------------------------------------------------
	-- Test to see if the logical file names have been set -------------------------------------------------------------------

	IF @LOGICAL_MDF_FILE_NAME = '' OR @LOGICAL_LDF_FILE_NAME = ''
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
	--------------------------------------------------------------------------------------------------------------------------
	
	---------------------------------------------------------------------------------------------------------------------------
	-- Restore the .bak file to NoRecovery mode so the trans logs can be restored ---------------------------------------------
	
		-- Initialize sql variable to empty strings
		SET @BASE_SQL = '';
		SET @SQL ='';

		-- Initialize the sql statement
		SET @SQL = 'RESTORE DATABASE ['+ @DATABASE_NAME +'] 
			FROM  DISK = N''' + @BACKUP_FILE_PATH + '\' + @BAK_FILE_NAME +''' WITH  FILE = 1
			,  MOVE N''' + @LOGICAL_MDF_FILE_NAME + ''' TO N''' + @RESTORE_MDF_FILE_PATH + '''
			,  MOVE N''' + @LOGICAL_LDF_FILE_NAME + ''' TO N''' + @RESTORE_LDF_FILE_PATH + '''
			,  NORECOVERY
			,  NOUNLOAD
			,  REPLACE
			,  STATS = 10';

		-- Log and execute the sql
		PRINT @SQL;
		PRINT '';
		EXEC (@SQL);
		PRINT '--------------------------------------------------------------'
		PRINT '';
	---------------------------------------------------------------------------------------------------------------------------
	
	---------------------------------------------------------------------------------------------------------------------------
	-- Restore all .trn logsexcept the final trn log in No recovery mode ------------------------------------------------------

		-- Initialize sql variable to empty strings
		SET @BASE_SQL = '';
		SET @SQL ='';

		-- Initialize the base sql for restoring trn logs
		SET @BASE_SQL = 
			N'RESTORE LOG ['+ @DATABASE_NAME +'] 
			FROM  DISK = N''##TRANS_LOG_PATH##\##TRANS_LOG_ID##.trn'+''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10';

		-- loop trn logs restoring them as you go up until the final trans log defined
		WHILE @TRNS_LOG_ID < @FINAL_TRNS_LOG_ID
		BEGIN
			SET @SQL = @BASE_SQL;

			-- Replace placeholders with defined enviroment variables
			SET @SQL = REPLACE(@SQL, '##TRANS_LOG_PATH##', @BACKUP_FILE_PATH);
			SET @SQL = REPLACE(@SQL, '##TRANS_LOG_ID##',CAST(@TRNS_LOG_ID AS VARCHAR(3)) );
	
			-- Increment the trans log id so the next time this loop comes round the next trans log will get restored
			SET @TRNS_LOG_ID = @TRNS_LOG_ID + 1;

			-- Log and execute the sql
			PRINT @SQL
			PRINT '';
			EXEC(@SQL);
			PRINT '--------------------------------------------------------------'
			PRINT '';
		END
	---------------------------------------------------------------------------------------------------------------------------
	
	---------------------------------------------------------------------------------------------------------------------------
	-- Restore the last .trn log up to a point in time with recovery ----------------------------------------------------------
	
		-- Initialize sql variable to empty strings
		SET @BASE_SQL = '';
		SET @SQL ='';

		-- Initialize the base sql for restoring .trn logs
		SET @SQL = 
		N'RESTORE LOG ['+ @DATABASE_NAME +'] 
			FROM  DISK = N''##TRANS_LOG_PATH##\##TRANS_LOG_ID##.trn''';

		-- Replace placeholders with defined enviroment variables
		SET @SQL = REPLACE(@SQL, '##TRANS_LOG_PATH##', @BACKUP_FILE_PATH);
		SET @SQL = REPLACE(@SQL, '##TRANS_LOG_ID##',CAST(@TRNS_LOG_ID AS VARCHAR(3)) );
	
		-- Either recover to a point in time or to the end of the .trn log
		IF @STOP_AT_TIME IS NULL
			SET @SQL = @SQL + ' WITH  FILE = 1,  RECOVERY,  NOUNLOAD,  STATS = 10';
		ELSE
			SET @SQL = @SQL + ' WITH  STOPAT = ''' + CONVERT(VARCHAR(50), @STOP_AT_TIME, 121) + ''',  RECOVERY,  NOUNLOAD,  STATS = 10';


		-- Log and execute the sql
		PRINT @SQL
		PRINT '';
		EXEC(@SQL);
		PRINT '--------------------------------------------------------------'
		PRINT '';

		DECLARE @PRINT NVARCHAR(4000);
		SELECT @PRINT = 'RESTORE OF DATABASE ' + @DATABASE_NAME + CASE WHEN @STOP_AT_TIME IS NULL THEN ' ' ELSE ' TO ' + CONVERT(VARCHAR(50), @STOP_AT_TIME, 121) + ' ' END + 'IS COMPLETE...';
		PRINT @PRINT;

	END

	GO
-------------------------------------------------------------------------------------------------------------------------------