-- CREATE A TABLE TO HOLD OUR DBCC CHECKDB RESULTS
USE MASTER
IF ( SELECT OBJECT_ID('[dbo].[dbcc_history_2005]')) IS NOT NULL
    DROP TABLE [dbo].[dbcc_history]
CREATE TABLE [dbo].[dbcc_history_2005](
    [Error]         [INT] NULL,
    [Level]         [INT] NULL,
    [State]         [INT] NULL,
    [MessageText]   [Varchar](8000) NULL,
    [RepairLevel]   [INT] NULL,
    [Status]        [INT] NULL,
    [DbId]          [INT] NULL,
    [ObjectId]      [INT] NULL,
    [IndexId]       [INT] NULL,
    [PartitionId]   [INT] NULL,
    [AllocUnitId]   [INT] NULL,
    [File]          [INT] NULL,
    [Page]          [INT] NULL,
    [Slot]          [INT] NULL,
    [RefFile]       [INT] NULL,
    [RefPage]       [INT] NULL,
    [RefSlot]       [INT] NULL,
    [Allocation]    [INT] NULL,
    [TimeStamp]     [datetime] NULL CONSTRAINT [DF_dbcc_history_TimeStamp] DEFAULT (GETDATE())
) ON [PRIMARY]
GO


-- USE THIS IN A SQL AGENT JOB
USE MASTER

DECLARE @DatabaseName VARCHAR(128)

DECLARE db_cursor CURSOR FOR 
    SELECT  name
    FROM    sys.databases db
    WHERE   db.database_id > 4              -- Not system db
            AND db.user_access = 0          -- multi user
            AND db.state_desc = 'ONLINE'
            AND source_database_id IS NULL  -- Not Snapshots
            AND is_read_only = 0
    ORDER BY db.database_id;

OPEN db_cursor

FETCH NEXT FROM db_cursor 
INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbcc_history_2005 ( [Error], [Level], [State], [MessageText], [RepairLevel],
        [Status], [DbId], [ObjectId], [IndexId], [PartitionId], [AllocUnitId], [File],
        [Page], [Slot], [RefFile], [RefPage], [RefSlot], [Allocation] )
    EXEC('DBCC CHECKDB('''+@DatabaseName+''') WITH TABLERESULTS')
    
    FETCH NEXT FROM db_cursor 
    INTO @DatabaseName
END
CLOSE db_cursor;
DEALLOCATE db_cursor;
