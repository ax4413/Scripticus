-- ===  ==================================================================================================================
-- ===  http://blog.sqlauthority.com/2016/02/16/sql-server-view-dependencies-on-sql-server-hard-soft-way/
-- ===  Find non-existent objects inside functions, views, and stored procedures
-- ===  https://msdn.microsoft.com/en-us/library/bb677315.aspx
SELECT  DISTINCT 'IF(OBJECT_ID(''' + SCHEMA_NAME(o.[schema_id]) + '.' + o.name + ''', ''' + o.type COLLATE Latin1_General_CI_AS + ''') IS NOT NULL )
    DROP ' + CASE o.type WHEN 'U' THEN 'TABLE' WHEN 'V' THEN 'VIEW' WHEN 'P' THEN 'PROCEDURE' WHEN 'FN' THEN 'FUNCTION' END + ' ' + SCHEMA_NAME(o.[schema_id]) + '.' + o.name
      --, o.type
      --, d.referenced_database_name
      --, d.referenced_schema_name
      --, d.referenced_entity_name
      --,d.*
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



IF(OBJECT_ID('dbo.CaisReportingProcessLoad', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.CaisReportingProcessLoad
IF(OBJECT_ID('dbo.DeleteExpiredLocks', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.DeleteExpiredLocks
IF(OBJECT_ID('dbo.EntityTransfer', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.EntityTransfer
IF(OBJECT_ID('dbo.FinancialTransactionPostProcess', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.FinancialTransactionPostProcess
IF(OBJECT_ID('dbo.GetActionChargesDetailReport', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.GetActionChargesDetailReport
IF(OBJECT_ID('dbo.GetApplicationStatus', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.GetApplicationStatus
IF(OBJECT_ID('dbo.GetWorkingDay', 'FN') IS NOT NULL )
    DROP FUNCTION dbo.GetWorkingDay
IF(OBJECT_ID('dbo.LoadBankBranch', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.LoadBankBranch
IF(OBJECT_ID('dbo.SaveBankBranch', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.SaveBankBranch
IF(OBJECT_ID('dbo.sp_cleardown', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.sp_cleardown
IF(OBJECT_ID('dbo.sp_ICE_FillArrays_ABT', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.sp_ICE_FillArrays_ABT
IF(OBJECT_ID('dbo.sp_ICE_Write_Amort', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.sp_ICE_Write_Amort
IF(OBJECT_ID('dbo.sp_ICE_Write_Amort_NH', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.sp_ICE_Write_Amort_NH
IF(OBJECT_ID('dbo.sp_ICE_writeXbilling', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.sp_ICE_writeXbilling
IF(OBJECT_ID('dbo.TransferApplicationToICEMan', 'P ') IS NOT NULL )
    DROP PROCEDURE dbo.TransferApplicationToICEMan