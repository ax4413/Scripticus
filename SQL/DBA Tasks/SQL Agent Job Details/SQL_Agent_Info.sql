
-- ================================================================================================
-- Identify a job from the name provideded in sp_who2
sp_who2

SELECT	*
FROM	( SELECT  JobStepName = 'SQLAgent - TSQL JobStep (Job 0x' + 
		  	   				             CONVERT(char(32),CAST(j.job_id AS binary(16)),2) + 
		  	   				             ' : Step ' + 
		  	   				             CAST(js.step_id AS VARCHAR(3)) + ')'
		  	      , j.job_id
		  	      , j.name 
		    FROM	  msdb.dbo.sysjobs AS j 
		  		      INNER JOIN msdb.dbo.sysjobsteps AS js 
		  		 		          ON j.job_id = js.job_id ) x
WHERE	  x.JobStepName LIKE '%?%'


-- get details of its past activity
EXEC msdb.dbo.sp_help_jobactivity ;


-- Additional details
SELECT	* 
FROM	  msdb.dbo.sysjobs
WHERE   job_id = '?'
                                                
SELECT	* 
FROM	  msdb.dbo.sysjobsteps 
WHERE   job_id = '?'

SELECT  * 
FROM    msdb.dbo.sysjobhistory
WHERE   job_id = '?'


-- stop the job
EXEC msdb.dbo.sp_stop_job @job_id = '?'

-- disable the job
EXEC msdb.dbo.sp_update_job  @job_id = '?', @enabled = 0 ;  
GO  


-- ================================================================================================
-- ================================================================================================
-- ================================================================================================


-- SQL Agent jobs on this server
SELECT  JobID                 = sj.job_id
      , JobName               = sj.name 
      , JobOwner              = dp.name
      , JobCategory           = sc.name
      , JobDescription        = sj.description
      , IsEnabled             = CASE sj.enabled WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END
      , JobCreatedOn          = sj.date_created
      , JobLastModifiedOn     = sj.date_modified
      , OriginatingServerName = serv.name
      , JobStartStepNo        = sjs.step_id
      , JobStartStepName      = sjs.step_name
      , IsScheduled           = CASE WHEN ss.schedule_uid IS NULL THEN 'No'
                                     ELSE 'Yes' END
      , JobScheduleID         = ss.schedule_uid
      , JobScheduleName       = ss.name
      , JobDeletionCriterion  = CASE sj.delete_level
                                  WHEN 0 THEN 'Never'
                                  WHEN 1 THEN 'On Success'
                                  WHEN 2 THEN 'On Failure'
                                  WHEN 3 THEN 'On Completion'
                                END
FROM    msdb.dbo.sysjobs AS sj
        LEFT JOIN msdb.sys.servers AS serv
                ON sj.originating_server_id = serv.server_id
        LEFT JOIN msdb.dbo.syscategories AS sc
                ON sj.category_id = sc.category_id
        LEFT JOIN msdb.dbo.sysjobsteps AS sjs
                ON sj.job_id = sjs.job_id
                AND sj.start_step_id = sjs.step_id
        LEFT JOIN msdb.sys.database_principals AS dp
                ON sj.owner_sid = dp.sid
        LEFT JOIN msdb.dbo.sysjobschedules AS sch
                ON sj.job_id = sch.job_id
        LEFT JOIN msdb.dbo.sysschedules AS ss
                ON sch.schedule_id = ss.schedule_id
ORDER BY JobName






---------------------------------------------------------------------------------------------
-- SQL Agent Job History --------------------------------------------------------------------

SELECT  [sJOB].[job_id] AS [JobID]
      , [sJOB].[name]   AS [JobName]
      , CASE 
          WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
          ELSE CAST(
                  CAST([sJOBH].[run_date] AS CHAR(8))
                  + ' ' 
                  + STUFF(
                      STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
                          , 3, 0, ':')
                      , 6, 0, ':')
                  AS DATETIME)
        END AS [LastRunDateTime]
      , CASE [sJOBH].[run_status]
          WHEN 0 THEN 'Failed'
          WHEN 1 THEN 'Succeeded'
          WHEN 2 THEN 'Retry'
          WHEN 3 THEN 'Canceled'
          WHEN 4 THEN 'Running' -- In Progress
        END AS [LastRunStatus]
      , STUFF(
              STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                  , 3, 0, ':')
              , 6, 0, ':') 
          AS [LastRunDuration (HH:MM:SS)]
      , [sJOBH].[message] AS [LastRunStatusMessage]
      , CASE [sJOBSCH].[NextRunDate]
          WHEN 0 THEN NULL
          ELSE CAST(
                  CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
                  + ' ' 
                  + STUFF(
                      STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
                          , 3, 0, ':')
                      , 6, 0, ':')
                  AS DATETIME)
        END AS [NextRunDateTime]
FROM    [msdb].[dbo].[sysjobs] AS [sJOB]
        LEFT JOIN ( SELECT [job_id]
                          , MIN([next_run_date]) AS [NextRunDate]
                          , MIN([next_run_time]) AS [NextRunTime]
                    FROM    [msdb].[dbo].[sysjobschedules]
                    GROUP BY [job_id]  ) AS [sJOBSCH]
              ON [sJOB].[job_id] = [sJOBSCH].[job_id]
        LEFT JOIN ( SELECT [job_id]
                        , [run_date]
                        , [run_time]
                        , [run_status]
                        , [run_duration]
                        , [message]
                        , ROW_NUMBER() OVER ( PARTITION BY [job_id]  ORDER BY [run_date] DESC, [run_time] DESC ) AS RowNumber
                    FROM  [msdb].[dbo].[sysjobhistory]
                    WHERE [step_id] = 0  ) AS [sJOBH]
            ON  [sJOB].[job_id] = [sJOBH].[job_id]
		        AND [sJOBH].[RowNumber] = 1
ORDER BY [JobName]




SELECT	[JobHistoryId],
		    [JobName],
		    [Step],
		    [StepName],
		    [RunDateTime],
		    [RunDuration]	=	RIGHT('00'+ RTRIM(CAST(RunDurationHours AS VARCHAR(2))), 2) + ':' + 
							          RIGHT('00'+ RTRIM(CAST(RunDurationMinutes AS VARCHAR(2))), 2) + ':' + 
							          RIGHT('00'+ RTRIM(CAST(RunDurationSeconds AS VARCHAR(2))), 2)
		    [RunStatus]
FROM (
		  SELECT	[JobHistoryId]			  =	h.Instance_Id,
				      [JobName]				      =	j.name,
				      [Step]					      =	s.step_id,
				      [StepName]				    =	s.step_name,
				      [RunDateTime]			    =	msdb.dbo.agent_datetime(run_date, run_time),
				      [RunDurationHours]		=	CAST(SUBSTRING(RIGHT('000000'+ RTRIM(run_duration), 6), 1, 2) AS INT),
				      [RunDurationMinutes]	=	CAST(SUBSTRING(RIGHT('000000'+ RTRIM(run_duration), 6), 3, 2) AS INT),
				      [RunDurationSeconds]	=	CAST(SUBSTRING(RIGHT('000000'+ RTRIM(run_duration), 6), 5, 2) AS INT),
				      [RunStatus]				    =	CASE run_status
												                WHEN 0 THEN 'Failed'
												                WHEN 1 THEN 'Succeeded'
												                WHEN 2 THEN 'Retry'
												                WHEN 3 THEN 'Canceled'
											                END
		  FROM	  msdb.dbo.sysjobs j 
				      INNER JOIN  msdb.dbo.sysjobsteps s 
				      	      ON  j.job_id = s.job_id
				      INNER JOIN  msdb.dbo.sysjobhistory h 
				      	      ON  s.job_id = h.job_id 
				      		    AND s.step_id = h.step_id 
				      		    AND h.step_id <> 0
		WHERE	    j.enabled = 1   --Only Enabled Jobs
) Q
ORDER BY Q.JobName, Q.RunDateTime DESC




SELECT  [job_name]  = j.name
      , h.step_id
      , h.step_name
      , h.message
      , h.run_date
      , h.run_time
FROM    msdb.dbo.sysjobs j 
        INNER JOIN msdb.dbo.sysjobhistory h 
                ON j.job_id = h.job_id 
WHERE   j.name like '%IceNet3 - ODS Incremental Load%'
ORDER BY j.name, run_date, run_time desc








---------------------------------------------------------------------------------------------
-- SQL Agent Job Schedules ------------------------------------------------------------------

-- JOB SCHEDULES 
select  job_name             = j.name	
      , job_enabled          = j.enabled
      , schedule_name        = s.name
      ,	schedule_enabled     = s.enabled	
      , freq_type            = case s.freq_type when 1   then 'One time only'
                                                when 4   then 'Daily'
                                                when 8   then 'Weekly'
                                                when 16  then 'Monthly'
                                                when 32  then 'Monthly, relative to freq_interval'
                                                when 64  then 'Runs when the SQL Server Agent service starts'
                                                when 128 then 'Runs when the computer is idle' end
      , freq_subday_type     = case s.freq_subday_type when 1 then 'At the specified time'
                                                       when 2 then 'Seconds'
                                                       when 4 then 'Minutes'
                                                       when 8 then 'Hours' end 
      , freq_interval        = case s.freq_type when 1   then 'n/a'
                                                when 4   then 'Every ' + cast(s.freq_interval as varchar(5)) + ' days'
                                                when 8   then case s.freq_interval when 1  then 'Sunday'
                                                                                   when 2  then 'Monday'
                                                                                   when 4  then 'Tuesday'
                                                                                   when 8  then 'Wednesday'
                                                                                   when 16 then 'Thursday'
                                                                                   when 32 then 'Friday'
                                                                                   when 64 then 'Saturday' end 									 
                                                when 16  then 'On the ' + cast(s.freq_interval as varchar(5)) + ' of the month'
                                                when 32  then case s.freq_interval when 1  then 'Sunday'
                                                                                   when 2  then 'Monday'
                                                                                   when 3  then 'Tuesday'
                                                                                   when 4  then 'Wednesday'
                                                                                   when 5  then 'Thursday'
                                                                                   when 6  then 'Friday'
                                                                                   when 7  then 'Saturday' 
                                                                                   when 8  then 'Day'
                                                                                   when 9  then 'Weekday'
                                                                                   when 10 then 'Weekend day' end
                                                when 64  then 'n/a'
                                                when 128 then 'n/a' end
      , freq_subday_interval = case s.freq_subday_type when 1 then 'At the specified time'
                                                       when 2 then 'Every ' +cast(s.freq_subday_interval as varchar(5)) + ' Seconds'
                                                       when 4 then 'Every ' +cast(s.freq_subday_interval as varchar(5)) + ' Minutes'
                                                       when 8 then 'Every ' +cast(s.freq_subday_interval as varchar(5)) + ' Hours' end	  
      , active_start_date    = cast(cast(s.active_start_date as varchar(10)) as date)
      , active_start_time    = SUBSTRING(RIGHT('000000'+CAST(s.active_start_time AS VARCHAR(6)),6), 1, 2) + ':' +
                               SUBSTRING(RIGHT('000000'+CAST(s.active_start_time AS VARCHAR(6)),6), 3, 2) + ':' +
                               SUBSTRING(RIGHT('000000'+CAST(s.active_start_time AS VARCHAR(6)),6), 5, 2) 

      , active_end_date      = cast(cast(s.active_end_date as varchar(10)) as date)
      , active_end_time      = SUBSTRING(RIGHT('000000'+CAST(s.active_end_time AS VARCHAR(6)),6), 1, 2) + ':' +
                               SUBSTRING(RIGHT('000000'+CAST(s.active_end_time AS VARCHAR(6)),6), 3, 2) + ':' +
                               SUBSTRING(RIGHT('000000'+CAST(s.active_end_time AS VARCHAR(6)),6), 5, 2) 
      , s.date_created
      , s.date_modified
      , s.freq_recurrence_factor
      , s.schedule_id
      , s.schedule_uid
      , s.originating_server_id
      , s.owner_sid
from	msdb.dbo.sysschedules S
        INNER JOIN msdb.dbo.sysjobschedules js on js.schedule_id = s.schedule_id
        INNER JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id
order by 3






---------------------------------------------------------------------------------------------
-- SQL To disable / stop jobs ---------------------------------------------------------------
SELECT  j.name
      , j.enabled
      , s.enabled
      , [stop job sql]         = 'sp_stop_job @job_id = ''' + cast(j.job_id as varchar(100)) +''''
      , [disable job sql]      = case j.enabled when 1 then 'EXEC msdb.dbo.sp_update_job @job_id = ''' + cast(j.job_id as varchar(100))+ ''', @enabled = 0' else '' end
      , [disable schedule sql] = case s.enabled when 1 then 'EXEC msdb.dbo.sp_update_schedule @schedule_id = ''' + cast(s.schedule_id as varchar(100))+ ''', @enabled = 0' else '' end
FROM	msdb.dbo.sysschedules s
        INNER JOIN msdb.dbo.sysjobschedules js on js.schedule_id = s.schedule_id
        INNER JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id
WHERE	j.name NOT LIKE 'asp%' AND 
        j.name NOT LIKE 'cdw%' AND 
        j.name NOT LIKE 'backup%' AND 
        j.name NOT LIKE 'cdc.%' AND 
        j.name NOT LIKE 'ssis%' AND   
        j.name NOT IN ('CommandLog Cleanup'
                     , 'DatabaseIntegrityCheck - SYSTEM_DATABASES'
                     , 'DatabaseIntegrityCheck - USER_DATABASES'
                     , 'IceNet2 - Nominal Ledger Execute All'
                     , 'IndexOptimize - USER_DATABASES'
                     , 'Output File Cleanup' ) 
      
      
