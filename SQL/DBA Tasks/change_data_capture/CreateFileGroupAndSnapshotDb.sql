-- ===============================================================================================================================
-- ===  USEFULL SQL MANUALLY CREATE THE SECONDARY-CDC FILE GROUPS OUTSIDE OF THE OCTOPUS DEPLOYMENT ==============================
-- ===  Find and replace DVVAPSYMain with ?                                                         ==============================


USE [master]
GO
ALTER DATABASE [DVVAPSYMain] ADD FILEGROUP [SECONDARY-CDC]
GO
ALTER DATABASE [DVVAPSYMain] ADD FILE ( 
    NAME = N'DVVAPSYMain_cdc'
  , FILENAME = N'R:\Data\DVVAPSYMain_cdc.ndf' 
  , SIZE = 512000KB 
  , FILEGROWTH = 1048576KB ) 
  TO FILEGROUP [SECONDARY-CDC]
GO


-- ===============================================================================================================================
-- ===  SQL TO MANUALLY CREATE A SNAPSHOT DATABASE OUTSIDE OF THE OCTOPUS DEPLOYMENT                ==============================
-- ===  This is necessary because the initial load requires a snapshot to run against               ==============================
-- ===  Find and replace DVVAPSYMain with ?                                                         ==============================

EXEC master..CreateSnapshot @SourceDbName              = 'DVVAPSYMain'         
                          , @TargetSnapshotDbName      = NULL /* will chose default name */
                          , @LiveMode                  = 1
                          , @VerboseMode               = 1
                          , @DropSnapshotDbIfItExists  = 0