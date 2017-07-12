--================================================================================
-- This script will move mdf and ldf files for selecetd databases on a server
--
-- Script to be run all at once, to generate all required dynamic sql and 
-- powershell.
-- The dynamic scripts should be run in the following order:
-- 1) detach DBs
-- 2) Move Files
-- 3) Attach DBs
-- 4) Delete old files
--
-- Note: Once you have detached the dbs they will not appear in sys.master_files
-- which this script uses heavely
--================================================================================

--exec sp_detach_db 'EDIZeiss-v1','true'

--CREATE DATABASE [EDIZeiss-v1] 
--    ON (FILENAME = 'D:\SqlDataFiles\EDIZeiss-v1.mdf'), 
--    (FILENAME = 'D:\SqlLogFiles\EDIZeiss-v1_1.ldf') 
--    FOR ATTACH; 

--ALTER DATABASE [EDIRodenstock-v14] SET READ_ONLY WITH NO_WAIT




-- SQL script to detatch the dbs
SELECT distinct
'exec sp_detach_db  ''' + db_name(database_id)+ ''', ''true'''
FROM sys.master_files
where physical_name like 'D:\SqlDataFiles\Moon Migration%'


--Powershel script to move mdf and ldf files
SELECT 
'Copy-Item ' + '"' + physical_name +'"' + 
	case 
		when type_desc = 'ROWS' then ' D:\SqlDataFiles' 
		else ' D:\SqllogFiles' end 
FROM sys.master_files
where physical_name like 'D:\SqlDataFiles\Moon Migration%'
ORDER BY physical_name, type_desc


-- SQL script to attach the dbs to the new mdf and ldf files
select 'CREATE DATABASE [' + mdf.DBName + '] 
    ON (FILENAME = '''+ mdf.FileName + '''), 
    (FILENAME = '''+ ldf.FileName +''') 
    FOR ATTACH; 
	'
from	(
		select database_id, db_name(database_id) DBName
			, physical_name, 'D:\SqlDataFiles\'  + right(physical_name, charindex('\', reverse(physical_name))-1) FileName
		FROM sys.master_files
		where type = 0
	) mdf
	inner join (
		select database_id, db_name(database_id) DBName
			, physical_name, 'D:\SqlLogFiles\'  + right(physical_name, charindex('\', reverse(physical_name))-1) FileName
		FROM sys.master_files
		where type = 1
	)ldf on ldf.database_id = mdf.database_id
where mdf.physical_name like 'D:\SqlDataFiles\Moon Migration%'
	and ldf.physical_name like 'D:\SqlDataFiles\Moon Migration%'
ORDER BY mdf.DBName


-- Power shell script to delete the old files
SELECT 
'Remove-Item "' + physical_name+ '"'
FROM sys.master_files
where physical_name like 'D:\SqlDataFiles\Moon Migration%'
ORDER BY physical_name, type_desc



