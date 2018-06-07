

; WITH AvailabilityGroup AS (
	SELECT	[Name]						= AG.name,
			[PrimaryReplicaServerName]	= ISNULL(agstates.primary_replica, ''),
			[LocalReplicaRole]			= ISNULL(arstates.role, 3)
	FROM	master.sys.availability_groups AS AG
			LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states AS agstates
					ON AG.group_id = agstates.group_id
			INNER JOIN master.sys.availability_replicas AS AR
					ON AG.group_id = AR.group_id
			INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
					ON	AR.replica_id = arstates.replica_id 
					AND arstates.is_local = 1
)

SELECT	* 
FROM	AvailabilityGroup
ORDER BY Name ASC


; WITH AvailabilityGroupDatabases AS (
	SELECT	[AvailabilityGroupName]		= AG.name,
			[PrimaryReplicaServerName]	= ISNULL(agstates.primary_replica, ''),
			[LocalReplicaRole]			= ISNULL(arstates.role, 3),
			[DatabaseName]				= dbcs.database_name,
			[SynchronizationState]		= ISNULL(dbrs.synchronization_state, 0),
			[IsSuspended]				= ISNULL(dbrs.is_suspended, 0),
			[IsJoined]					= ISNULL(dbcs.is_database_joined, 0)
	FROM	master.sys.availability_groups AS AG
			LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates
					ON AG.group_id = agstates.group_id
			INNER JOIN master.sys.availability_replicas AS AR
					ON AG.group_id = AR.group_id
			INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
					ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
			INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
					ON arstates.replica_id = dbcs.replica_id
			LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
					ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id
)

SELECT	*
FROM	AvailabilityGroupDatabases
ORDER BY AvailabilityGroupName, DatabaseName


SELECT	name, 'ALTER AVAILABILITY GROUP "AVG-DV" REMOVE DATABAS ' + QUOTENAME(name)
FROM	sys.databases 
WHERE	name LIKE '%sy%' 
ORDER BY name

SELECT	name, 'DROP DATABASE ' + QUOTENAME(name) 
FROM	sys.databases 
WHERE	name LIKE '%sy%' 
ORDER BY name

SELECT	name, 'ALTER DATABASE ' + QUOTENAME(name) +'  SET HADR OFF'
FROM	sys.databases 
WHERE	name LIKE '%sy%' 
ORDER BY name

drop database DVVAPZSYAudit
drop database DVVAPZSYAuth
drop database DVVAPZSYDocuments
drop database DVVAPZSYExternal
drop database DVVAPZSYIdentityServer
drop database DVVAPZSYMain
drop database DVVAPZSYNominalLedger
drop database DVVAPZSYODS
drop database DVVAPZSYReporting



USE master
ALTER AVAILABILITY GROUP "AVG-DV" REMOVE DATABASE <Name of database>;

-- Connect to second node
-- NPSQL01.icecloudnp.onmicrosoft.com,1621) and run this:
USE master
ALTER DATABASE <Name of database> SET HADR OFF;