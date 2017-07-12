-- ===  ==================================================================================================================
-- ===  http://blog.sqlauthority.com/2016/02/16/sql-server-view-dependencies-on-sql-server-hard-soft-way/
-- ===  script to find places where the table is used:
SET NOCOUNT ON;
DECLARE @obj_id INT = OBJECT_ID('DBO.Application');

IF OBJECT_ID('tempdb.dbo.#h') IS NOT NULL
  DROP TABLE #h

CREATE TABLE #h ( obj_id INT NULL
                , obj_name SYSNAME
                , obj_schema SYSNAME NULL
                , obj_type CHAR(5) NULL );

INSERT INTO #h
  SELECT  s.referencing_id
        , COALESCE(t.name, o.name)
        , SCHEMA_NAME(o.[schema_id])
        , CASE s.referencing_class
               WHEN 1THEN o.[type]
               WHEN 7THEN 'U'
               WHEN 9THEN 'U'
               WHEN 12 THEN 'DDLTR'
          END
  FROM    sys.sql_expression_dependencies s
          LEFT OUTER JOIN sys.objects o
                  ON o.[object_id] = s.referencing_id
                  AND o.[type] NOT IN ('D', 'C')
          LEFT OUTER JOIN sys.triggers t
                  ON t.[object_id] = s.referencing_id
                  AND t.parent_class = 0
                  AND s.referencing_class = 12
  WHERE   ( o.[object_id] IS NOT NULL
            OR t.[object_id] IS NOT NULL )
    AND     s.referenced_server_name IS NULL
    AND   ( ( s.referenced_id IS NOT NULL
              AND s.referenced_id = @obj_id)
          OR( s.referenced_id IS NULL
              AND OBJECT_ID(QUOTENAME(ISNULL(s.referenced_schema_name, SCHEMA_NAME())) + '.' +
                            QUOTENAME(s.referenced_entity_name)) = @obj_id))

--  Like in SSMS, we can also find the table dependencies though foreign keys:
INSERT INTO #h
  SELECT  parent_object_id, OBJECT_NAME(parent_object_id), SCHEMA_NAME([schema_id]), 'U'
  FROM    sys.foreign_keys
  WHERE   referenced_object_id = @obj_id
    AND   parent_object_id != referenced_object_id

--  And find out what synonyms use the table:
INSERT INTO #h
  SELECT  [object_id], name, SCHEMA_NAME([schema_id]), [type]
  FROM    sys.synonyms
  WHERE   OBJECT_ID(base_object_name) = @obj_id

--  The temporary table results:
SELECT  DISTINCT *
FROM    #h
WHERE   ISNULL(obj_id, 0) != @obj_id
;
GO