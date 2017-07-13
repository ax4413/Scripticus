# global error variable
$global:localError = $false

$errorCount = 0
$successCount = 0

function ResoreDatabase([string] $backupFile, [string] $serverName, [string] $username, [string] $password)
{
	#============================================================
	# Restore a Database using PowerShell and SQL Server SMO
	# Restore to the a new database name, specifying new mdf and ldf
	# Stephen Yeadon
	#============================================================
	  
	#load assemblies
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
	#Need SmoExtended for backup
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
	[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
	[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null
	 
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
	
	#we will query the database name from the backup header later
	#$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $serverName
	$server =  new-object Microsoft.SqlServer.Management.SMO.Server($mySrvConn)
	$backupDevice = New-Object("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($backupFile, "File")
	$smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")
	 
	#restore settings
	$smoRestore.NoRecovery = $false;
	$smoRestore.ReplaceDatabase = $true;
	$smoRestore.Action = "Database"
	$smoRestorePercentCompleteNotification = 10;
	$smoRestore.Devices.Add($backupDevice)
	 
	#get database name from backup file
	#$smoRestoreDetails = $smoRestore.ReadFileList($server)
	$smoRestoreDetails = $smoRestore.ReadBackupHeader($server)
	 
	#display database name
	#"Database Name from Backup Header : " +$smoRestoreDetails.Rows[0]["DatabaseName"]
	 
	#give a new database name
	$dbName = $smoRestoreDetails.Rows[0]["DatabaseName"]
	$smoRestore.Database = $dbName
	 
	#specify new data and log files (mdf and ldf)
	$smoRestoreFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
	$smoRestoreLog = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
	 
	#the logical file names should be the logical filename stored in the backup media
	$smoRestoreFile.LogicalFileName = $smoRestoreDetails.Rows[0]["DatabaseName"]
	$smoRestoreFile.PhysicalFileName = $server.Information.MasterDBPath + "\" + $smoRestore.Database + "_Data.mdf"
	$smoRestoreLog.LogicalFileName = $smoRestoreDetails.Rows[0]["DatabaseName"] + "_Log"
	$smoRestoreLog.PhysicalFileName = $server.Information.MasterDBLogPath + "\" + $smoRestore.Database + "_Log.ldf"
	$smoRestore.RelocateFiles.Add($smoRestoreFile)
	$smoRestore.RelocateFiles.Add($smoRestoreLog)
	 
	#restore database
	$smoRestore.SqlRestore($server)
	
	return $dbName
}

function SetDBOwner([string] $targetServer, [string] $dbName, [string] $owner)
{
	## get reference to server and db
	$srv = new-Object Microsoft.SqlServer.Management.Smo.Server($targetServer)
	$db = New-Object Microsoft.SqlServer.Management.Smo.Database
	$db = $srv.Databases.Item($dbName)
	## set new ownership of db
	$db.SetOwner($owner, $TRUE)
}

##############################################################################
##############################################################################

## Server to copy DB to
$targetServer = "OLTPProd01"
$targetBackupLocation = "\\OLTPProd01\d$\Temp"
$targetUsername = "sa"
$targetPassword = "0pt1c5##"

cls

foreach($bak in Get-ChildItem $targetBackupLocation)
{
	$localError = $false
	
	$localizedBak = $targetBackupLocation.Substring($targetServer.Length + 3).Replace("$",":")
	
	# catch exceptions
	trap{
		$global:localError = $true
		Write-Output $db |Out-File "c:\failedBackupRestore.txt" -Append
		# increment error count
		$errorCount++
		# Provide a more verbose error message
		$error[0]|format-list –force
		continue
	}
	
	# Restore target db.bak
	if($global:localError -eq $false){
		Write-Host "${targetServer}\${db} Restoring..."
		## Restore the backed up db
		$dbName = ResoreDatabase -backupFile $localizedBak -serverName $targetServer -username $targetUsername -password $targetPassword
		Write-Host "${targetServer}\${bak} Restored"
		Write-Host "${targetServer}\${bak} Changing owner to $owner"

		## Set the db owner of the newly restored db to be SA
		SetDBOwner -targetServer $targetServer -dbName $db -owner 'sa'
		Write-Host "${targetServer}\${db} Owned by $owner"
		Write-Host "${targetServer}\${db} Transfer complete"
		Write-Host ""
	}
}