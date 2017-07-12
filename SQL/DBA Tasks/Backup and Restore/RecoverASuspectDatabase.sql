-- -----------------------------------------------------------------------------------
-- Recover a suspect database to a useable state
-- http://www.sql-server-performance.com/2012/recovery-sql-server-suspect-mode/
-- -----------------------------------------------------------------------------------


-- Take db out of suspect mode
EXEC sp_resetstatus 'OECentral_V420x';


-- Set in emergency mode -  READ_ONLY where only members of sysadmin fixed server roles
-- have privileges to access it
ALTER DATABASE OECentral_V420x SET EMERGENCY


-- Check the db for consistency
DBCC checkdb('OECentral_V420x')


-- Force single user mode and rollback any open transactions
ALTER DATABASE OECentral_V420x 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE


-- Try to repair data sing the allow data loss flag
DBCC CheckDB ('OECentral_V420x', REPAIR_ALLOW_DATA_LOSS)


-- Put back into multi user mode
ALTER DATABASE OECentral_V420x SET MULTI_USER


-- Test your db by checking the datbase consistency once more
DBCC CheckDB ('OECentral_V420x')

