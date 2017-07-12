
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