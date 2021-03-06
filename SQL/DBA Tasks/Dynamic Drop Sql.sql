USE master  

DECLARE @Dbs TABLE(Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, Name sysname)
INSERT INTO @Dbs
  VALUES('TestMain'), ('TestDocuments'), ('TestExternal'), ('TestReporting')

--SELECT * FROM sys.databases WHERE name IN(SELECT Name FROM @Dbs)


DECLARE @Db NVARCHAR(128), @DropSyntax NVARCHAR(4000), @TmpDropSyntax NVARCHAR(4000)
SELECT  @DropSyntax = N'
ALTER DATABASE [@Db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;
DROP DATABASE  [@Db] ;'

DECLARE cur CURSOR 
    FOR SELECT Name FROM @Dbs oRDER BY Id

OPEN cur
    FETCH NEXT FROM cur INTO @db

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS( SELECT * FROM sys.databases WHERE name = @Db) BEGIN
        RAISERROR('[%s] - Droping... ', 0, 0, @Db) WITH NOWAIT
        SELECT @TmpDropSyntax = REPLACE(@DropSyntax, '@Db', @Db)   
        EXEC (@TmpDropSyntax)
    END
    FETCH NEXT FROM cur INTO @db
END 

CLOSE cur;
DEALLOCATE cur;
