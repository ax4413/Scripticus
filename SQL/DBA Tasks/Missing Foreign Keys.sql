-- ===   Overly simplyfied solution to find tabvles that are missing foreign keys.

WITH pk AS  (
    SELECT  t.name pk_table
          , c.name  pk_column
          , t.object_id table_id
          , c.column_id
    FROM    sys.tables t
            INNER JOIN sys.indexes i
                  ON i.object_id = t.object_id
            INNER JOIN sys.index_columns ic
                  ON i.object_id = ic.object_id
                  AND i.index_id = ic.index_id
            INNER JOIN sys.columns c
                  ON c.object_id = ic.object_id
                  AND c.column_id = ic.column_id
    WHERE   i.index_id = 1
      AND   t.is_ms_shipped = 0
      AND   t.name NOT LIKE '%^_S' ESCAPE '^'
      AND   t.schema_id = SCHEMA_ID('dbo')
)
--SELECT * FROM pk ORDER BY 1, 2 */

, tc AS (
    SELECT  t.name table_name
          , c.name column_name
          , t.object_id table_id
          , c.column_id
    FROM    sys.tables t
            INNER join sys.columns  c
                    ON c.object_id = t.object_id
    WHERE   t.is_ms_shipped = 0
      AND   t.name NOT LIKE '%^_S' ESCAPE '^'
      AND   t.schema_id = SCHEMA_ID('dbo')
)
--SELECT * FROM tc ORDER BY 1, 2 */


, fk AS (
    SELECT  OBJECT_NAME(fkc.referenced_object_id) pk_table
          , rc.name pk_column
          , OBJECT_NAME(fkc.parent_object_id) fk_table
          , pc.name fk_column
    FROM    sys.foreign_key_columns fkc
            INNER JOIN sys.columns pc
                    ON  pc.object_id = fkc.parent_object_id
                    AND pc.column_id = fkc.parent_column_id
            INNER JOIN sys.columns rc
                    ON  rc.object_id = fkc.referenced_object_id
                    AND rc.column_id = fkc.referenced_column_id  
)
--SELECT * FROM fk ORDER BY 1, 2 */

SELECT  pk.pk_table, pk.pk_column
      , tc.table_name Missing_fk_table, tc.column_name Missing_fk_Column
      --, fk.fk_table, fk.fk_column
FROM    pk 
        INNER JOIN tc 
              ON  pk.pk_column = tc.column_name
              AND pk.pk_Table != tc.table_name
        LEFT OUTER JOIN  fk
              ON  fk.pk_table   = pk.pk_table
              AND fk.pk_column  = pk.pk_column
              AND fk.fk_table   = tc.table_name
              AND fk.fk_column  = tc.column_name
WHERE   fk.fk_table  IS NULL
  AND   fk.fk_column IS NULL 
  AND   pk.pk_table  NOT IN ( 'Person', 'BillOfSale', 'CaisMergeDetail', 'Company' )
  AND   pk.pk_table NOT LIKE 'MIG^_%' ESCAPE '^'
  AND   tc.table_name NOT LIKE 'MIG^_%' ESCAPE '^'
ORDER BY 3,4, 1,2



-- */ -- */ -- */ 