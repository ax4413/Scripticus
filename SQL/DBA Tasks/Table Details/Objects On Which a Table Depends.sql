-- ===  ==================================================================================================================
-- ===  http://blog.sqlauthority.com/2016/02/16/sql-server-view-dependencies-on-sql-server-hard-soft-way/
-- ===  When you need to know what the table depends from. In this case, the script will be hard to understand.


SET NOCOUNT ON;

DECLARE @obj_id INT = OBJECT_ID('dbo.Application')

IF OBJECT_ID('tempdb.dbo.#h') IS NOT NULL
  DROP TABLE #h

CREATE TABLE #h ( obj_id INT NULL
                , obj_name SYSNAME COLLATE database_default
                , obj_schema SYSNAME NULL
                , obj_type CHAR(5) NULL
                , obj_db SYSNAME NULL )

--  First of all, we need to analyze the scripted objects:
INSERT INTO #h (obj_id, obj_name, obj_schema, obj_type, obj_db)
  SELECT  r.referenced_id
        , COALESCE(o.name, t.name, r.referenced_entity_name)
        , COALESCE( SCHEMA_NAME(o.[schema_id])
                  , SCHEMA_NAME(t.[schema_id])
                  , r.referenced_schema_name )
        , CASE r.referenced_class
               WHEN 1THEN o.[type]
               WHEN 6THEN (CASE WHEN t.is_assembly_type = 1 THEN 'CLR'
                                WHEN t.is_table_type = 1 THEN 'TT'
                                ELSE 'UT'
                           END)
               WHEN 7THEN 'U'
               WHEN 9THEN 'U'
               WHEN 10 THEN 'XML'
               WHEN 21 THEN 'PF'
          END
        , CASE WHEN DB_ID(r.referenced_database_name) IS NOT NULL
                    THEN DB_NAME(DB_ID(r.referenced_database_name))
               ELSE ISNULL(r.referenced_database_name, DB_NAME())
          END
FROM (  SELECT  d.referenced_id
              , d.referenced_class
              , d.referenced_entity_name
              , d.referenced_schema_name
              , d.referenced_database_name
        FROM    sys.sql_expression_dependencies d
        WHERE   d.referencing_id = @obj_id
          AND   d.referenced_server_name IS NULL
          AND   ISNULL(d.referenced_id, 0) != @obj_id
        UNION
        SELECT  d.referenced_id
              , d.referenced_class
              , d.referenced_entity_name
              , d.referenced_schema_name
              , d.referenced_database_name
        FROM    sys.objects o
                INNER JOIN sys.sql_expression_dependencies d ON d.referencing_id = o.OBJECT_ID
        WHERE   o.parent_object_id = @obj_id
          AND   d.referenced_server_name IS NULL
          AND   ISNULL(d.referenced_id, 0) != @obj_id
) r
        LEFT OUTER JOIN sys.objects o
                ON r.referenced_class = 1
                AND o.OBJECT_ID = r.referenced_id
                AND DB_ID(ISNULL(r.referenced_database_name, DB_NAME())) = DB_ID()
        LEFT OUTER JOIN sys.types t
                ON r.referenced_class = 6
                AND t.user_type_id = r.referenced_id
WHERE   r.referenced_database_name IS NULL
   OR   DB_ID(r.referenced_database_name) IS NOT NULL


-- After that, we should check what is used inside the child objects of the table. For example, a trigger can use a table from a different database:
DECLARE @DB SYSNAME
      , @SQL NVARCHAR(MAX)

DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
  SELECT  DISTINCT obj_db
  FROM    #h
  WHERE   obj_id IS NULL OR obj_type IS NULL OR obj_schema IS NULL
OPEN cur
FETCH NEXT FROM cur INTO @DB
WHILE @@FETCH_STATUS != -1 BEGIN
  IF NOT EXISTS(SELECT  1
                FROM    #h
                WHERE   obj_id IS NULL
                   OR   obj_type IS NULL
                   OR   obj_schema IS NULL)
    BREAK

  SET @SQL = '
USE [' + @DB + '];
UPDATE #h
SET
obj_id = o.object_id
, obj_name = o.name
, obj_schema = SCHEMA_NAME(o.schema_id)
, obj_type = o.type
FROM sys.objects o
WHERE o.object_id = OBJECT_ID(QUOTENAME(ISNULL(obj_schema, SCHEMA_NAME())) + ''.'' + QUOTENAME(obj_name))
AND #h.obj_db = DB_NAME()
AND #h.obj_id IS NULL'

  IF @DB = DB_NAME() BEGIN
    SET @SQL = @SQL + '
UPDATE #h
SET
obj_id = x.xml_collection_id
, obj_name = x.name
, obj_schema = SCHEMA_NAME(x.schema_id)
FROM sys.xml_schema_collections x
WHERE x.name = #h.obj_name COLLATE database_default
AND (#h.obj_schema IS NULL OR x.schema_id = SCHEMA_ID(#h.obj_schema))
AND #h.obj_type = ''XML''
AND #h.obj_db = DB_NAME()'
  END

  EXEC sys.sp_executesql @SQL

  UPDATE  #h
     SET  obj_id = o.[object_id]
        , obj_name = o.name
        , obj_schema = s.name
        , obj_type = o.TYPE
        , obj_db = 'master'
  FROM    MASTER.sys.objects o
          INNER JOIN MASTER.sys.schemas s
                  ON s.[schema_id] = o.[schema_id]
  WHERE   o.TYPE IN ('P', 'RF', 'PC')
    AND   o.[schema_id] = 1
    AND   o.name = #h.obj_name COLLATE database_default
    AND   ( SCHEMA_ID(#h.obj_schema) = 1
            OR #h.obj_schema IS NULL )
    AND   #h.obj_name LIKE 'sp/_%' ESCAPE '/'
    AND   #h.obj_id IS NULL

FETCH NEXT FROM cur INTO @DB
END
CLOSE cur
DEALLOCATE cur


--  And after that, we should look through hard dependencies, including:
--  1. Foreign keys
INSERT INTO #h (obj_id, obj_name, obj_schema, obj_type, obj_db)
  SELECT  o.[object_id], o.name, SCHEMA_NAME(o.schema_id), 'U', DB_NAME()
  FROM    sys.foreign_keys fk
          INNER JOIN sys.objects o
                  ON o.[object_id] = fk.referenced_object_id
  WHERE   fk.parent_object_id = @obj_id
    AND   fk.parent_object_id != fk.referenced_object_id


--  2. Rules and default objects
INSERT INTO #h (obj_id, obj_name, obj_schema, obj_type, obj_db)
  SELECT  c.default_object_id, o.name, SCHEMA_NAME(o.[schema_id]), 'DO', DB_NAME()
  FROM    sys.columns c
          INNER JOIN sys.objects o
                  ON o.[object_id] = c.default_object_id
  WHERE   c.[object_id] = @obj_id
    AND   c.default_object_id > 0
    AND   o.parent_object_id = 0
  UNION ALL
  SELECT  c.rule_object_id, o.name, SCHEMA_NAME(o.schema_id), 'R', DB_NAME()
  FROM    sys.columns c
          INNER JOIN sys.objects o
                  ON o.[object_id] = c.rule_object_id
  WHERE   c.[object_id] = @obj_id
    AND   c.rule_object_id > 0


--  3. XML schemas
INSERT INTO #h (obj_id, obj_name, obj_schema, obj_type, obj_db)
  SELECT  x.xml_collection_id, x.name, SCHEMA_NAME(x.[schema_id]), 'XML', DB_NAME()
  FROM    sys.column_xml_schema_collection_usages u
          INNER JOIN sys.xml_schema_collections x
                  ON x.xml_collection_id = u.xml_collection_id
  WHERE   u.[object_id] = @obj_id


--  4. Partition schemas
INSERT INTO #h (obj_id, obj_name, obj_schema, obj_type, obj_db)
  SELECT  ps.data_space_id, ps.name, NULL, 'PS', DB_NAME()
  FROM    sys.indexes i
          INNER JOIN sys.partition_schemes ps
                  ON ps.data_space_id = i.data_space_id
  WHERE   i.[object_id] = @obj_id


--  5. Full-text search objects
INSERT INTO #h (obj_id, obj_name, obj_schema, obj_type, obj_db)
  SELECT  c.fulltext_catalog_id, c.name, NULL, 'FTC', DB_NAME()
  FROM    sys.fulltext_index_catalog_usages i
          INNER JOIN sys.fulltext_catalogs c
                  ON i.fulltext_catalog_id = c.fulltext_catalog_id
  WHERE   i.OBJECT_ID = @obj_id
  UNION ALL
  SELECT  s.stoplist_id, s.name, NULL, 'FTS', DB_NAME()
  FROM    sys.fulltext_indexes i
          INNER JOIN sys.fulltext_stoplists s
                  ON i.stoplist_id = s.stoplist_id
  WHERE   i.OBJECT_ID = @obj_id
  UNION ALL
  SELECT  s.property_list_id, s.name, NULL, 'FP', DB_NAME()
  FROM    sys.fulltext_indexes i
          INNER JOIN sys.registered_search_property_lists s
                  ON i.property_list_id = s.property_list_id
  WHERE   i.OBJECT_ID = @obj_id



--  The temporary table results:
SELECT  DISTINCT *
FROM    #h
WHERE   ISNULL(obj_id, 0) != @obj_id
;
GO