
-- this code can be used to see when the AVG has failed over

DECLARE @FileName NVARCHAR(4000)
SELECT	@FileName = target_data.value('(EventFileTarget/File/@name)[1]', 'nvarchar(4000)')
FROM (	SELECT CAST(target_data AS XML) target_data
		FROM sys.dm_xe_sessions s
		INNER JOIN sys.dm_xe_session_targets t
				ON s.address = t.event_session_address
		WHERE s.name = N'AlwaysOn_health' ) ft;

--SELECT @FileName /*

; WITH event_data AS (
	SELECT	*, CAST(event_data AS XML) XEData
	FROM	sys.fn_xe_file_target_read_file(@FileName, NULL, NULL, NULL)
	WHERE	object_name = 'availability_replica_state_change'
)
--SELECT * FROM event_data /*

, data AS (
	SELECT  XEData.value('(event/@timestamp)[1]', 'datetime2(3)') AS event_timestamp
		  , XEData.value('(event/data/text)[1]', 'VARCHAR(255)')  AS previous_state
		  , XEData.value('(event/data/text)[2]', 'VARCHAR(255)')  AS current_state
		  , ar.replica_server_name
	FROM	event_data
			INNER JOIN sys.availability_replicas ar
					ON ar.replica_id = XEData.value('(event/data/value)[5]', 'VARCHAR(255)')
)
--SELECT * FROM data /*

SELECT	DATEADD(HOUR, DATEDIFF(HOUR, GETUTCDATE(), GETDATE()), event_timestamp) AS event_timestamp_local
	  , event_timestamp AS event_timestamp_utc
      , previous_state
      , current_state
      , replica_server_name
FROM	data
ORDER BY event_timestamp DESC;

-- */ --*/ --*/