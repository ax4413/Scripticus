-- ===  A modified version of http://blog.sqlauthority.com/2011/01/03/sql-server-2008-missing-index-script-download/
SELECT  [DatabaseName]          = DB_NAME(dm_mid.database_id),
        [Avg Estimated Impact]  = dm_migs.avg_user_impact * (dm_migs.user_seeks + dm_migs.user_scans),
        [Improvement Measure]   = dm_migs.avg_total_user_cost * (dm_migs.avg_user_impact / 100.0) * (dm_migs.user_seeks + dm_migs.user_scans),
        [Total User Cost]       = avg_total_user_cost,
        [Avg User Impact]       = dm_migs.avg_user_impact,
        [User Seeks]            = dm_migs.user_seeks,
        [User Scans]            = dm_migs.user_scans,
        [Last_User_Seek]        = dm_migs.last_user_seek,
        [Last User Scan]        = dm_migs.last_user_scan,
        [TableName]             = OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id),
        [Create_Statement]      = 'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
                                  + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') +
                                  CASE
                                  WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN '_'
                                  ELSE ''
                                  END
                                  + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
                                  + ']'
                                  + ' ON ' + dm_mid.statement
                                  + ' (' + ISNULL (dm_mid.equality_columns,'')
                                  + CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE
                                  '' END
                                  + ISNULL (dm_mid.inequality_columns, '')
                                  + ')'
                                  + ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '')
FROM  sys.dm_db_missing_index_groups dm_mig
      INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
              ON dm_migs.group_handle = dm_mig.index_group_handle
      INNER JOIN sys.dm_db_missing_index_details dm_mid
              ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY [Avg Estimated Impact] DESC
GO