-- ===  ==================================================================================================================
-- ===  http://blog.sqlauthority.com/2016/02/16/sql-server-view-dependencies-on-sql-server-hard-soft-way/
-- ===  Find non-existent objects inside functions, views, and stored procedures
-- ===  https://msdn.microsoft.com/en-us/library/bb677315.aspx
SELECT  [Object] = SCHEMA_NAME(o.[schema_id]) + '.' + o.name
      , o.type
      , d.referenced_database_name
      , d.referenced_schema_name
      , d.referenced_entity_name
      ,d.*
FROM    sys.sql_expression_dependencies d
        INNER JOIN sys.objects o ON d.referencing_id = o.[object_id]
WHERE   d.is_ambiguous = 0
  AND   d.referenced_id IS NULL
  AND   d.referenced_server_name IS NULL
  AND   CASE d.referenced_class
             WHEN 1 THEN OBJECT_ID( ISNULL(QUOTENAME(d.referenced_database_name), DB_NAME()) + '.' +
                                    ISNULL(QUOTENAME(d.referenced_schema_name), SCHEMA_NAME()) + '.' +
                                    QUOTENAME(d.referenced_entity_name))
             WHEN 6 THEN TYPE_ID( ISNULL(d.referenced_schema_name, SCHEMA_NAME()) + '.' + d.referenced_entity_name)
             WHEN 10 THEN ( SELECT  1
                            FROM    sys.xml_schema_collections x
                            WHERE   x.name = d.referenced_entity_name
                              AND   x.[schema_id] = ISNULL(SCHEMA_ID(d.referenced_schema_name), SCHEMA_ID() ) )
             END IS NULL
;
GO