-- ===  ==================================================================================================================
-- ===  http://blog.sqlauthority.com/2016/02/16/sql-server-view-dependencies-on-sql-server-hard-soft-way/
-- ===  Show hard dependencies on dbo.table1
DECLARE @t TABLE ([object_id] INT PRIMARY KEY)

INSERT INTO @t ([object_id])
  VALUES(OBJECT_ID('dbo.Table1'))

DECLARE @rows INT = 1
WHILE @rows > 0 BEGIN
  SET @rows = 0
  INSERT INTO @t
  SELECT  f.parent_object_id
  FROM    @t t
          INNER JOIN sys.foreign_keys f ON f.referenced_object_id = t.[object_id]
  WHERE NOT EXISTS( SELECT  1
                    FROM    @t t2
                    WHERE   t2.[object_id] = f.parent_object_id )
  SET @rows += @@ROWCOUNT
END

SELECT OBJECT_NAME([object_id]) FROM @t
;
GO
