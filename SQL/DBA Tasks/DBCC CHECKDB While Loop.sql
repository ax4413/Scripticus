
USE MASTER
IF ( SELECT OBJECT_ID('[dbo].[dbcc_history_2005]')) IS NOT NULL
    DROP TABLE [dbo].[dbcc_history_2005]
CREATE TABLE [dbo].[dbcc_history_2005](
    [Error]         [BIGINT] NULL,
    [Level]         [BIGINT] NULL,
    [State]         [BIGINT] NULL,
    [RepairLevel]   [BIGINT] NULL,
    [Status]        [BIGINT] NULL,
    [DbId]          [BIGINT] NULL,
    [ObjectId]      [BIGINT] NULL,
    [IndexId]       [BIGINT] NULL,
    [PartitionId]   [BIGINT] NULL,
    [AllocUnitId]   [BIGINT] NULL,
    [File]          [BIGINT] NULL,
    [Page]          [BIGINT] NULL,
    [Slot]          [BIGINT] NULL,
    [RefFile]       [BIGINT] NULL,
    [RefPage]       [BIGINT] NULL,
    [RefSlot]       [BIGINT] NULL,
    [Allocation]    [BIGINT] NULL,
    [MessageText]   [Varchar](8000) NULL,
    [TimeStamp]     [datetime] NULL CONSTRAINT [DF_dbcc_history_2005_TimeStamp] DEFAULT (GETDATE())
) ON [PRIMARY]
GO




-- ===  Put This section in a sql agent job

DECLARE @Databases TABLE (Id INT NOT NULL PRIMARY KEY, DatabaseName VARCHAR(128) NOT NULL)
INSERT INTO @Databases
    SELECT 2,  'ASPSTATE' UNION
    SELECT 1,  'NHCCIceStg' 

DECLARE @ErrorMsg NVARCHAR(2048)
DECLARE @CarriageReturn CHAR(2)
    SET @CarriageReturn = char(10)

DECLARE @DatabaseName VARCHAR(128)
    SET @DatabaseName = ''
DECLARE @Id INT
    SET @Id = 0

SELECT  @Id = MIN(Id)
FROM    @Databases

WHILE( @Id <= (SELECT MAX(Id) FROM @Databases))
BEGIN
    -- ===  Get the name of the current database to be DBCC'd
    SELECT  @DatabaseName = DatabaseName
    FROM    @Databases
    WHERE   Id = @Id

    -- ===  Print to screen
    RAISERROR('Performing DBCC CHECKDB (%s) WITH tableresults',0,0,@DatabaseName) WITH NOWAIT
    
    BEGIN TRY
        INSERT INTO dbcc_history_2005 ( [Error], [Level], [State], [MessageText], [RepairLevel],
                [Status], [DbId], [ObjectId], [IndexId], [PartitionId], [AllocUnitId], [File],
                [Page], [Slot], [RefFile], [RefPage], [RefSlot], [Allocation] )
            EXEC('DBCC CHECKDB('''+@DatabaseName+''') WITH TABLERESULTS')
    END TRY
    BEGIN CATCH
        SELECT  @ErrorMsg = ISNULL(ERROR_MESSAGE(), N'')
        -- ===  wite to teh error log and print to screen
        RAISERROR('ERROR - DBCC CHECKDB (%s) WITH tableresults failed to execute. %s%s', 12, 1, @DatabaseName, @ErrorMsg, @CarriageReturn) WITH LOG
    END CATCH

    -- ===  Get the next database
    SELECT  @Id = MIN(Id)
    FROM    @Databases
    WHERE   id > @Id
END