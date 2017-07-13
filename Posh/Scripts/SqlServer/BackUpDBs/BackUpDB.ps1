function BackUpDatabase([string]$serverName, [string] $username, [string] $password, [string]$dbToBackup, [string]$backupTo)
{
	#============================================================
	# Backup a Database using PowerShell and SQL Server SMO
	# Script below creates a full backup
	# Stephen Yeadon
	#============================================================
	 
	  
	#load assemblies
	#note need to load SqlServer.SmoExtended to use SMO backup in SQL Server 2008
	#otherwise may get this error
	#Cannot find type [Microsoft.SqlServer.Management.Smo.Backup]: make sure
	#the assembly containing this type is loaded.
	 
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
	#Need SmoExtended for smo.backup
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null
	 
	if($serverName -eq "local")
	{
		#Wrap the server name in brackets if its a local instance
		$braketedServer = "("
		$braketedServer += $serverName 
		$braketedServer += ")"
		$serverName = $braketedServer
	}
	
	# set up a conn string
	$mySrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
	$mySrvConn.ServerInstance=$serverName
	$mySrvConn.LoginSecure = $false
	$mySrvConn.Login = $username
	$mySrvConn.Password = $password 
	 
	#create a new server object
	#$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $serverName
	$server =  new-object Microsoft.SqlServer.Management.SMO.Server($mySrvConn)
	# Assign the back up directory
	$backupDirectory = $backupTo

	 
	$db = $server.Databases[$dbToBackup]
	$dbName = $db.Name
	 
	$timestamp = Get-Date -format yyyyMMddHHmmss
	$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
	 
	#BackupActionType specifies the type of backup.
	#Options are Database, Files, Log
	#This belongs in Microsoft.SqlServer.SmoExtended assembly

	$smoBackup.Action = "Database"
	$smoBackup.BackupSetDescription = "Full Backup of " + $dbName
	$smoBackup.BackupSetName = $dbName + " Backup"
	$smoBackup.Database = $dbName
	$smoBackup.MediaDescription = "Disk"

	$backedUpFile = $backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak"

	$smoBackup.Devices.AddDevice($backedUpFile, "File")
	$smoBackup.SqlBackup($server)
	
	return $backedUpFile
}




