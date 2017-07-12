/* BACK UP A DB ------------------------------------------------------------------------------------------------------------ */

BACKUP DATABASE [OECentral2008] TO  DISK = N'C:\FileLocation.bak' WITH NOFORMAT
	, NOINIT,  NAME = N'Description', SKIP, NOREWIND, NOUNLOAD,  STATS = 10

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------



/* HOW TO RESORE A .bak FILE ------------------------------------------------------------------------------------------------ */

USE [master]
GO
-- this is only necessary if the db is locked
ALTER DATABASE [ECatNikon-v6_4010] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
RESTORE DATABASE [ECatNikon-v6_4010] 
FROM  DISK = N'F:\ECatBackups\Nikon\RegularCatalogue\Dev\ECatNikon-v6_4010_withStageDataPreImport.bak' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10
GO



RESTORE DATABASE [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_19_180006_1413885.bak' WITH  FILE = 1
,  MOVE N'EGOS' TO N'C:\SQL_Files\Data\EGOS3010.mdf'
,  MOVE N'EGOS_log' TO N'C:\SQL_Files\Log\EGOS3010.ldf'
,  RECOVERY,  NOUNLOAD,  REPLACE,  STATS = 10
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------



/* HOW TO RESTORE TRANSACTION LOG ------------------------------------------------------------------------------------------- */

-- RESTORE .BAK WITH NO RECOVERY OPTION 
RESTORE DATABASE [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_19_180006_1413885.bak' WITH  FILE = 1
,  MOVE N'EGOS' TO N'C:\SQL_Files\Data\EGOS3010.mdf'
,  MOVE N'EGOS_log' TO N'C:\SQL_Files\Log\EGOS3010.ldf'
,  NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 10
GO

-- RESTORE .TRN WITH NO RECOVERY
RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_080004_8969098.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_090005_0655822.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_100004_9483936.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_110005_3556396.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_120004_3927159.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_130004_9354258.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

-- RESTORE LAST .TRN WITH RECOVERY
RESTORE LOG [EGOS3010] 
FROM  DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_140005_2008809.trn' WITH  FILE = 1,  RECOVERY,  NOUNLOAD,  STATS = 10
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------



/* HOW TO RESTORE TO A POINT IN TIME ---------------------------------------------------------------------------------------- */
RESTORE LOG [EGOS3010]
FROM DISK = N'C:\Temp\EGOS\EGOS3010_backup_2011_10_20_140005_2008809.trn' 
WITH STOPAT = '2011-10-20 15:15:00', RECOVERY
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------