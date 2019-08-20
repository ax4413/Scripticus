-- =============================================================================================
-- This script is to be run when setting up a SSIS package to run as part of a batch process
-- The script does the following
--    1.  Create a credential object to be used by the proxy
--    2.  Create a proxy object and configure it
--    3.  Grant execute permisions on some system sql agent job sprocs to the service logon
--  
--    The sql agent job now needs to have 
--    1.  Its owner set to the logon
--    2.  Its step to execute under the context of the proxy
-- =============================================================================================

DECLARE @LogonContextFromApp NVARCHAR(128)  = N'TestAppUser'

DECLARE @LoginContextForSSIS NVARCHAR(128)  = N'Test'

DECLARE @CredentialName NVARCHAR(128)       = N'TestCeds'
DECLARE @CredentialSecret NVARCHAR(128)     = N'pa55w0rd'

DECLARE @ProxyName NVARCHAR(128)            = N'TestProxy' 

DECLARE @mainDb SYSNAME                     = 'MainDb'
DECLARE @ReportingDb SYSNAME                = 'ReportsDb'


DECLARE @SqlCommand VARCHAR(8000)


-- ===  Step #1 - Creating a logon for the proxy to execute under the context of ===============
USE MASTER

SET @SqlCommand = 'CREATE LOGIN [''' + @LogonContextFromApp + '''] FROM WINDOWS;'
EXEC(@SqmCommand)

-- Grant public access to msdb
SET @SqlCommand = 'USE [msdb]
  CREATE USER [''' + @LoginContextForSSIS + '''] FOR LOGIN [''' + @LoginContextForSSIS + ''']'
EXEC(@SqmCommand)

-- Grant public access to ssisdb
SET @SqlCommand = 'USE [ssisdb]
  CREATE USER [''' + @LoginContextForSSIS + '''] FOR LOGIN [''' + @LoginContextForSSIS + ''']'
EXEC(@SqmCommand)

-- Grant public access to main
SET @SqlCommand = 'USE [''' + @MainDb + ''']
  CREATE USER [''' + @LoginContextForSSIS + '''] FOR LOGIN [''' + @LoginContextForSSIS + ''']'
EXEC(@SqmCommand)

-- Grant public access to reports
SET @SqlCommand = 'USE [''' + @ReportingDb + ''']
  CREATE USER [''' + @LoginContextForSSIS + '''] FOR LOGIN [''' + @LoginContextForSSIS + ''']'
EXEC(@SqmCommand)

/* we may need to grant more priveledges here */



-- ===  Step #1 - Creating a credential to be used by proxy ====================================
USE MASTER

-- Delete the credential if it exists
SET @SqlCommand = 'IF EXISTS (SELECT 1 FROM sys.credentials WHERE name = N''' + @CredentialName +''')
  DROP CREDENTIAL [' + @CredentialName + ']'  
EXEC(@SqlCommand)

-- create the credential
SET @SqlCommand = 'CREATE CREDENTIAL [' + @CredentialName + '] 
WITH IDENTITY = N''' + @LoginContextForSSIS + ''', 
SECRET = N''' + @CredentialSecret + '''' 
EXEC(@SqlCommand)



-- ===  Step #2 - Creating a proxy account  ====================================================
USE msdb

-- delete the proxy if it exists
SET @SqlCommand = 'IF EXISTS (SELECT 1 FROM msdb.dbo.sysproxies WHERE name = N''' + @ProxyName +''') 
  EXEC dbo.sp_delete_proxy @proxy_name = N''' + @ProxyName + ''''
EXEC(@SqlCommand)

-- create the proxy
EXEC msdb.dbo.sp_add_proxy 
  @proxy_name = @ProxyName,
  @credential_name = @CredentialName,
  @enabled = 1 

-- enable the proxy
EXEC msdb.dbo.sp_update_proxy 
  @proxy_name = @ProxyName, 
  @enabled = 1

-- grant the proxy access to the SSIS subsystem
EXEC msdb.dbo.sp_grant_proxy_to_subsystem 
  @proxy_name = @ProxyName, 
  @subsystem_id = 11 -- SSIS. See EXEC sp_enum_sqlagent_subsystems 

-- Test to ensure that the proxy has access to the sub system
--EXEC dbo.sp_enum_proxy_for_subsystem


-- Grant proxy account access to security principals that could be
-- either login name or fixed server role or msdb role
EXEC msdb.dbo.sp_grant_login_to_proxy 
  @proxy_name = @ProxyName,
  @login_name = @LogonContextFromApp
  --,@fixed_server_role=N'' 
  --,@msdb_role=N'' 

-- test to see if the login has been granted to the proxy. not ethat sys adming users have access by default
--EXEC dbo.sp_enum_login_for_proxy 



-- ===  Step #3 - Grant execute permisions to the service user =================================

SET @SqlCommand = 'grant execute on sp_start_job to ''' + @LogonContextFromApp + ''''
EXEC(@SqlCommand)

SET @SqlCommand = 'grant execute on sp_help_job to ''' + @LogonContextFromApp + ''''
EXEC(@SqlCommand)


SET @SqlCommand = 'grant execute on sp_help_jobhistory to ''' + @LogonContextFromApp + ''''
EXEC(@SqlCommand)



EXEC dbo.sp_help_job
    @job_name = N'IceNet.Data.Extract.PrintControlFile.VirginMedia'

*/





USE [msdb]
GO
ALTER ROLE [SQLAgentReaderRole] ADD MEMBER [#UserName#]
GO

ALTER ROLE [SQLAgentUserRole] ADD MEMBER [#UserName#]
GO

ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [#UserName#]
GO

