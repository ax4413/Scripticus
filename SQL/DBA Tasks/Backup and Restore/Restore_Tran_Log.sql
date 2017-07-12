-- Get data about the .bak file
RESTORE HEADERONLY 
FROM DISK = N'C:\SQL_Files\Backup\DDCOLL\0.bak' 
WITH NOUNLOAD;
GO


-- get file data about the backup
RESTORE FILELISTONLY FROM DISK = N'C:\SQL_Files\Backup\DDCOLL\0.bak' 
   WITH FILE=1;
GO

-- get data abouut the .bak
RESTORE LABELONLY 
FROM DISK = N'C:\SQL_Files\Backup\DDCOLL\0.bak' 
GO

RESTORE DATABASE [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\0.bak' WITH  FILE = 1,  
MOVE N'DDCollections' TO N'C:\SQL_Files\Data\DDCollectionsProduction.mdf',  
MOVE N'DDCollections_log' TO N'C:\SQL_Files\Log\DDCollectionsProduction.ldf',  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 10
GO


-- RESTORE .TRN WITH NO RECOVERY
RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\1.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\2.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\3.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\4.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\5.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\6.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\7.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\8.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\9.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\10.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

-- RESTORE LAST .TRN WITH RECOVERY
RESTORE LOG [DDCollectionsProduction] 
FROM  DISK = N'C:\SQL_Files\Backup\DDCOLL\11.trn' WITH  FILE = 1,  RECOVERY,  NOUNLOAD,  STATS = 10
GO