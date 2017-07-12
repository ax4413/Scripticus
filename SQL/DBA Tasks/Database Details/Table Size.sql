SELECT  [alloc_unit_type_desc] AS [Data Structure]
      , [page_count] AS [Pages]
      , [record_count] AS [Rows]
      , [min_record_size_in_bytes] AS [Min Row]
      , [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats (
        DB_ID ()
      , OBJECT_ID (N'LargeVariableWidthTable')
      , NULL
      , NULL
      , N'DETAILED'); -- detailed mode
GO


-- Clinical Image DB
SELECT 'SELECT ''' + S.name + '_' + T.name + '''
	, COUNT(*) AS ImageCount
	, SUM(DATALENGTH(' + QUOTENAME(C.name) + '))/1024 AS TotalClinicalImageFileSizeKB
	, MAX(DATALENGTH(' + QUOTENAME(C.name) + '))/1024 AS MaxClinicalImageFileSizeKB
	, AVG(DATALENGTH(' + QUOTENAME(C.name) + '))/1024 AS AvgClinicalImageFileSizeKB
FROM ' + QUOTENAME(S.name) + '.' + QUOTENAME(T.name) + ''
FROM sys.tables T
	INNER JOIN sys.schemas S on t.schema_id = s.schema_id
	INNER JOIN sys.columns C on C.object_id = T.object_id
WHERE t.name in ('ClinicalImageCentral', 'ClinicalImageCentralFS','PxImageCentral')
	AND  c.name in('FullClinicalImage','FullImage')
ORDER BY S.name, T.name


-- Leightons Clinical Image DB
--select COUNT(*) from [Leightons].[ClinicalImageCentralFS]
--select COUNT(*) from [Leightons].[PxImageCentral]

--SELECT MAX(DATALENGTH(FullClinicalImage))/1024 AS MaxClinicalImageFileSizeKB
--	, AVG(DATALENGTH(FullClinicalImage))/1024 AS AvgClinicalImageFileSizeKB
--FROM [Leightons].[ClinicalImageCentralFS]


--SELECT MAX(DATALENGTH(FullImage))/1024 AS MaxPxImageFileSizeKK
--	, AVG(DATALENGTH(FullImage))/1024 AS AvgPxImageFileSizeKB
--FROM [Leightons].[PxImageCentral]



-------------------------------------------------------------------------------------------------------




CREATE TABLE #temp (
	table_name sysname
	, row_count INT
	, reserved_size VARCHAR(50)
	, data_size VARCHAR(50)
	, index_size VARCHAR(50)
	, unused_size VARCHAR(50));

SET NOCOUNT ON

INSERT #temp
EXEC sp_msforeachtable 'sp_spaceused ''?''';

SELECT a.table_name
	, a.row_count
	, COUNT(*) AS col_count
	, a.data_size
FROM #temp a
	INNER JOIN information_schema.columns b
		ON a.table_name collate database_default
			= b.table_name collate database_default
GROUP BY a.table_name
	, a.row_count
	, a.data_size
ORDER BY CAST(REPLACE(a.data_size, ' KB', '') AS integer) DESC;

DROP TABLE #temp;


