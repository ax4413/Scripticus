/*
    http://databasehealth.com/server-overview/instance-level-reports/quick-scan-report/quick-scan-report-high-vlf-count/
*/

GO
 
DECLARE @logInfoResults AS TABLE
(
 [RecoveryUnitId] BIGINT, -- only on SQL Server 2012 and newer
 [FileId] TINYINT,
 [FileSize] BIGINT,
 [StartOffset] BIGINT,
 [FSeqNo] INTEGER,
 [Status] TINYINT,
 [Parity] TINYINT,
 [CreateLSN] NUMERIC(38,0)
);
  
INSERT INTO @logInfoResults
EXEC sp_executesql N'DBCC LOGINFO WITH NO_INFOMSGS';
 
SELECT FileSize / 1024 / 1024 as FileSizeInMB, 
 [Status] ,
 REPLICATE('x', FileSize / 1024 / 1024 ) as [BarChart ________________________________________________________________________________________________]
 FROM @logInfoResults ;