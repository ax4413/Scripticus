/*  Script for Finding Probe Residuals in the cache.

    Analyzing the plan cache can be incredibly useful to find inconsistencies within your code
    This code is modified code from Jon's blog post:
        http://bit.ly/17MdijL   Finding Implicit Column Conversions in the Plan Cache
*/

SET STATISTICS PROFILE OFF;
GO

DECLARE @dbname SYSNAME = QUOTENAME(DB_NAME());

WITH XMLNAMESPACES (
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)

SELECT  [query_plan]
      , [BuildSchema]
      , [BuildTable]
      , [BuildColumn]
      , [BuildColumnType]    = [ic].[DATA_TYPE]
      , [BuildColumnLength]  = ISNULL (CAST ([ic].[CHARACTER_MAXIMUM_LENGTH]  AS NVARCHAR),
                                      (CAST ([ic].[NUMERIC_PRECISION] AS NVARCHAR)
                                      + N',' + CAST ([ic].[NUMERIC_SCALE] AS NVARCHAR)))
      , [ProbeSchema]
      , [ProbeTable]
      , [ProbeColumn]
      , [ProbeColumnType]     = [ic2].[DATA_TYPE]
      , [ProbeColumnLength]   = ISNULL (CAST ([ic2].[CHARACTER_MAXIMUM_LENGTH] AS NVARCHAR),
                                       (CAST ([ic2].[NUMERIC_PRECISION] AS NVARCHAR)
                                       + N',' + CAST ([ic2].[NUMERIC_SCALE] AS NVARCHAR)))
FROM (
      SELECT  [query_plan]
            , [BuildSchema] = [t].[value]( N'(../HashKeysBuild/ColumnReference/@Schema)[1]', N'NVARCHAR(128)' )
            , [BuildTable]  = [t].[value]( N'(../HashKeysBuild/ColumnReference/@Table)[1]',  N'nvarchar(128)' )
            , [BuildColumn] = [t].[value]( N'(../HashKeysBuild/ColumnReference/@Column)[1]', N'nvarchar(128)' )
            , [ProbeSchema] = [t].[value]( N'(../HashKeysProbe/ColumnReference/@Schema)[1]', N'nvarchar(128)' )
            , [ProbeTable]  = [t].[value]( N'(../HashKeysProbe/ColumnReference/@Table)[1]',  N'nvarchar(128)' )
            , [ProbeColumn] = [t].[value]( N'(../HashKeysProbe/ColumnReference/@Column)[1]', N'nvarchar(128)' )
      FROM    [sys].[dm_exec_cached_plans] AS [cp]
              CROSS APPLY [sys].[dm_exec_query_plan]([plan_handle]) AS [qp]
              CROSS APPLY [query_plan].[nodes]( N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple' ) AS batch(stmt)
              CROSS APPLY [stmt].[nodes]( N'.//Hash/ProbeResidual' ) AS [n]([t])
      WHERE   [t].[exist]( N'../HashKeysProbe/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]' ) = 1
  ) AS [Probes]
      LEFT JOIN [INFORMATION_SCHEMA].[COLUMNS] AS [ic]
            ON  QUOTENAME ([ic].[TABLE_SCHEMA])  = [Probes].[BuildSchema]
            AND QUOTENAME ([ic].[TABLE_NAME])    = [Probes].[BuildTable]
            AND [ic].[COLUMN_NAME]               = [Probes].[BuildColumn]
      LEFT JOIN [INFORMATION_SCHEMA].[COLUMNS] AS [ic2]
            ON  QUOTENAME ([ic2].[TABLE_SCHEMA]) = [Probes].[ProbeSchema]
            AND QUOTENAME ([ic2].[TABLE_NAME])   = [Probes].[ProbeTable]
            AND [ic2].[COLUMN_NAME]              = [Probes].[ProbeColumn]
WHERE [ic].[DATA_TYPE] <> [ic2].[DATA_TYPE]
    OR ( [ic].[DATA_TYPE] = [ic2].[DATA_TYPE]
       AND ISNULL (CAST ([ic].[CHARACTER_MAXIMUM_LENGTH]  AS NVARCHAR),
                  (CAST ([ic].[NUMERIC_PRECISION]         AS NVARCHAR)
                  + N',' + CAST ([ic].[NUMERIC_SCALE]     AS NVARCHAR)))
        <> ISNULL (CAST ([ic2].[CHARACTER_MAXIMUM_LENGTH] AS NVARCHAR),
                (CAST ([ic2].[NUMERIC_PRECISION]          AS NVARCHAR)
                + N',' + CAST ([ic2].[NUMERIC_SCALE]      AS NVARCHAR)))
        )
OPTION (MAXDOP 1);
GO