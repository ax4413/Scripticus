
-- ===  used to generate a list of tables and their columns
SELECT  t.name, c.list
FROM    sys.tables t
        CROSS APPLY ( SELECT list = STUFF( (  SELECT  ',' + name 
                                              FROM    sys.columns x 
                                              WHERE   x.object_id = t.object_id 
                                                AND   x.name NOT IN ('LastLSN', 'ODSChangeDate','ODSCreateDate')
                                              ORDER BY column_Id
                                            FOR XML PATH(''),TYPE).value('(./text())[1]','NVARCHAR(MAX)')
		                                      , 1, 1, '' ) ) c
WHERE   t.name NOT LIKE '%^_S' ESCAPE '^'
  AND   t.name NOT IN ('applicationsummary', 'SchemaVersions')
ORDER BY t.name










--  ========================================================================================================================
--  ================                     INFORMATION REGARDING THE CAPTURE INSTANCES                        ================
--  ========================================================================================================================

/*  Get information about the captured data   */

EXEC sys.sp_cdc_help_change_data_capture  
EXEC sys.sp_cdc_get_captured_columns @capture_instance = N'dbo_Address_A'

SELECT  * 
FROM    cdc.captured_columns
GO





--  ========================================================================================================================
--  ================                                  SQL AGENT JOBS                                        ================
--  ========================================================================================================================

/*  https://msdn.microsoft.com/en-us/library/bb500247.aspx
    Stores the change data capture configuration parameters for capture and cleanup jobs. This table is stored in msdb.   */

SELECT  * 
FROM    msdb.dbo.cdc_jobs 
WHERE   database_id = db_id()
GO



/*  https://msdn.microsoft.com/en-us/library/bb500303.aspx
    Reports information about all change data capture cleanup or capture jobs in the current database.    */

EXEC sp_cdc_help_jobs
GO



/*  https://msdn.microsoft.com/en-us/library/bb510748.aspx
    Modifies the configuration of a change data capture cleanup or capture job in the current database. To view the current configuration of a job, 
    query the dbo.cdc_jobs table, or use sp_cdc_help_jobs.    */

EXECUTE sys.sp_cdc_change_job   
    @job_type = N'cleanup',  
    @threshold = 500000,
    @retention = 2880
GO  



/*  https://technet.microsoft.com/en-us/library/bb522509(v=sql.110).aspx
    https://technet.microsoft.com/en-us/library/bb510685(v=sql.110).aspx
    Start and stop cdc jobs   */
EXEC sys.sp_cdc_stop_job @job_type = 'cleanup' 
EXEC sys.sp_cdc_start_job @job_type = 'cleanup' 
GO





--  ========================================================================================================================
--  ================                                  DATA RETREVAL                                         ================
--  ========================================================================================================================


/*  https://msdn.microsoft.com/en-us/library/bb510627.aspx
    Returns one row for each change applied to the source table within the specified log sequence number (LSN) range. 
    If a source row had multiple changes during the interval, each change is represented in the returned result set. 
    In addition to returning the change data, four metadata columns provide the information you need to apply the changes 
    to another data source. Row filtering options govern the content of the metadata columns as well as the rows returned 
    in the result set. When the 'all' row filter option is specified, each change has exactly one row to identify the change. 
    When the 'all update old' option is specified, update operations are represented as two rows: one containing the values 
    of the captured columns before the update and another containing the values of the captured columns after the update.

    This enumeration function is created at the time that a source table is enabled for change data capture. The function 
    name is derived and uses the format cdc.fn_cdc_get_all_changes_capture_instance where capture_instance is the value 
    specified for the capture instance when the source table is enabled for change data capture.    */

DECLARE @min_lsn BINARY(10) = sys.fn_cdc_get_min_lsn('dbo_person_A')
      , @max_lsn BINARY(10) = sys.fn_cdc_get_max_lsn()

SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_person_A(@min_lsn, @max_lsn, 'all update old')
SELECT * FROM cdc.fn_cdc_get_net_changes_dbo_person_A(@min_lsn, @max_lsn, 'all')
GO





--  ========================================================================================================================
--  ================                           LOG SEQUENCE NUMBERS ETC                                     ================
--  ========================================================================================================================


/*  https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/change-data-capture-sys-dm-cdc-log-scan-sessions
    Returns one row for each log scan session in the current database. The last row returned represents the current session. 
    You can use this view to return status information about the current log scan session, or aggregated information about 
    all sessions since the instance of SQL Server was last started.   */

SELECT  *
FROM    sys.dm_cdc_log_scan_sessions  
WHERE   session_id = (SELECT MAX(b.session_id) FROM sys.dm_cdc_log_scan_sessions AS b);  
GO


SELECT  * FROM sys.dm_cdc_errors

SELECT * FROM sys.dm_repl_traninfo




/*  https://msdn.microsoft.com/en-us/library/bb510494.aspx
    Returns one row for each transaction having rows in a change table. This table is used to map between log sequence number (LSN) 
    commit values and the time the transaction committed. Entries may also be logged for which there are no change tables entries. 
    This allows the table to record the completion of LSN processing in periods of low or no change activity.   */

SELECT  * 
FROM    cdc.lsn_time_mapping
WHERE   START_LSN IN (0x00000C24000012E00001, 0x00000C24000012E00001)
GO



/*  https://msdn.microsoft.com/en-us/library/bb500137(v=sql.110).aspx
    Returns the log sequence number (LSN) value from the start_lsn column in the cdc.lsn_time_mapping system table for the specified time. 
    You can use this function to systematically map datetime ranges into the LSN-based range needed by the change data capture enumeration functions 
    cdc.fn_cdc_get_all_changes_<capture_instance> and cdc.fn_cdc_get_net_changes_<capture_instance> to return data changes within that range.   */

DECLARE @t DATETIME = '20190709 12:00:00'
SELECT sys.fn_cdc_map_time_to_lsn('largest less than', @t)
SELECT sys.fn_cdc_map_time_to_lsn('largest less than or equal', @t)
SELECT sys.fn_cdc_map_time_to_lsn('smallest greater than', @t)
SELECT sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', @t)
GO




--  ========================================================================================================================
--  ================               DELETE DATA FROM CDC TABLES -not to be used lightly                      ================
--  ========================================================================================================================


/*  https://msdn.microsoft.com/en-us/library/bb510449.aspx
    Removes rows from the change table in the current database based on the specified low_water_mark value. This stored procedure is 
    provided for users who want to directly manage the change table cleanup process. 
    Caution should be used, however, because the procedure affects all consumers of the data in the change table.   */

EXEC sys.sp_cdc_cleanup_change_table
GO
