-- ================================================================================================
-- Script to unlock a single user database
--  http://www.sqlservercentral.com/blogs/pearlknows/2014/04/07/help-i-m-stuck-in-single-user-mode-and-can-t-get-out/
--  Variables:
--    {DbStuckInSingleUserMode}
-- ================================================================================================



--		Find out if anything has access to on your database
sp_who2

SELECT * FROM master.dbo.sp_who3() where DbName like '{DbStuckInSingleUserMode}'

SELECT	* 
FROM	master.sys.sysprocesses
WHERE	spid > 50
  AND	dbid = DB_ID('{DbStuckInSingleUserMode}')



-- ===	Investigate sql agent jobs	===============================================================

-- figure out which job the sp_who2 etc 
SELECT	*
FROM	( SELECT JobStepName = 'SQLAgent - TSQL JobStep (Job 0x' + 
		  	   				   CONVERT(char(32),CAST(j.job_id AS binary(16)),2) + 
		  	   				   ' : Step ' + 
		  	   				   CAST(js.step_id AS VARCHAR(3)) + ')'
		  	   , j.job_id
		  	   , j.name 
		  FROM	 msdb.dbo.sysjobs AS j 
		  		 INNER JOIN msdb.dbo.sysjobsteps AS js 
		  		 		 ON j.job_id = js.job_id ) x
WHERE	x.JobStepName LIKE '%?%'


EXEC msdb.dbo.sp_help_jobactivity ;


SELECT	* 
FROM	msdb.dbo.sysjobs
WHERE   job_id = '?'

                                                
SELECT	* 
FROM	msdb.dbo.sysjobsteps 
WHERE   job_id = '?'


-- stop the job
EXEC msdb.dbo.sp_stop_job @job_id = '?'

-- disable the job
EXEC msdb.dbo.sp_update_job  @job_id = '?', @enabled = 0 ;  
GO  

-- ===	End of sql agent job section =============================================================


-- get back multi user mode
ALTER DATABASE {DbStuckInSingleUserMode} 
SET MULTI_USER

-- rollback trans
ALTER DATABASE {DbStuckInSingleUserMode} 
SET MULTI_USER WITH ROLLBACK IMMEDIATE

-- dont wait for the tran to commit or roll back, kill it
ALTER DATABASE {DbStuckInSingleUserMode} 
SET MULTI_USER WITH NO_WAIT

-- Put all this together into a neat little scriptlet, we have
USE [master] 
SET DEADLOCK_PRIORITY HIGH
ALTER DATABASE [{DbStuckInSingleUserMode}] SET MULTI_USER WITH NO_WAIT
ALTER DATABASE [{DbStuckInSingleUserMode}] SET MULTI_USER WITH ROLLBACK IMMEDIATE

-- ohh shit #@$%&

-- === 	Use the DAC
-- https://msdn.microsoft.com/en-us/library/ms189595.aspx
-- ALTER DATABASE AdventureWorks2012SET MULTI_USER

-- ===	What do you mean YOU DONT HAVE DAC. We're getting desperate now


-- ===============================================================================================
-- ===============================================================================================
-- ===============================================================================================
-- Alternate aproaches


-- ===	Figure out who to Kill
-- http://www.cjsommer.com/sql-stuck-in-single-user-mode/

USE [master] ;
 
DECLARE @DatabaseName VARCHAR(255) ;
SET @DatabaseName = '{DbStuckInSingleUserMode}' ;
 
SELECT spr.spid AS [spid]
     , sdb.NAME AS [DatabaseName]
     , spr.open_tran AS [OpenTransactions]
     , spr.status AS [Status]
     , ('kill ' + CAST(spr.spid AS VARCHAR)) AS [KillCommand]
FROM sys.sysprocesses spr
INNER JOIN sys.databases sdb ON sdb.database_id = spr.dbid
WHERE sdb.NAME = @DatabaseName ;

ALTER DATABASE {DbStuckInSingleUserMode} MULTI_USER











