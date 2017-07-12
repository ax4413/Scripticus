
USE [master];
GO
ALTER DATABASE [master]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
USE [master]
GO
DBCC SHRINKFILE (N'master' , 0, TRUNCATEONLY)
GO
ALTER DATABASE [master]
SET MULTI_USER;
GO





SELECT '
USE [master];
GO
ALTER DATABASE ' + QUOTENAME(d.name) + '
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
USE ' + QUOTENAME(d.name) + '
GO
DBCC SHRINKFILE (N' + QUOTENAME(d.name, CHAR(39)) + ' , 0, TRUNCATEONLY)
GO
ALTER DATABASE ' + QUOTENAME(d.name) + '
SET MULTI_USER;
GO
' , d.*
FROM sys.databases d
   INNER JOIN sys.master_files mf ON mf.database_id = d.database_id AND mf.type_desc = 'LOG'
WHERE d.database_id  > 6




USE [master];
GO
ALTER DATABASE [master]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
USE [master]
GO
DBCC SHRINKFILE (N'master' , 0, TRUNCATEONLY)
GO
ALTER DATABASE [master]
SET MULTI_USER;
GO



