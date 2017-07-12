/* For more information on ALL of the type conversions, check out http://bit.ly/XFS6On

  Analyzing the plan cache can be incredibly useful to find inconsistencies within your code
  This code comes from Jon's blog post:
      http://bit.ly/17MdijL  Finding Implicit Column Conversions in the Plan Cache

  This returns both sql queries and stored procedures  */

DECLARE @dbname SYSNAME
SET @dbname = QUOTENAME(DB_NAME());

WITH XMLNAMESPACES (
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
    SELECT  stmt.value('(@StatementText)[1]', 'varchar(max)')                                 AS StatementText
          , t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)') AS SchemaName
          , t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')  AS TableName
          , t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') AS ColumnName
          , ic.DATA_TYPE                                                                      AS ConvertFrom
          , ic.CHARACTER_MAXIMUM_LENGTH                                                       AS ConvertFromLength
          , t.value('(@DataType)[1]', 'varchar(128)')                                         AS ConvertTo
          , t.value('(@Length)[1]', 'int')                                                    AS ConvertToLength
          , query_plan                                                                        AS QueryPlan
    FROM    sys.dm_exec_cached_plans AS cp
            CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
            CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
            CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t)
            INNER JOIN INFORMATION_SCHEMA.COLUMNS AS ic
                    ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)')
                    AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')
                    AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)')
    WHERE   t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1
;
