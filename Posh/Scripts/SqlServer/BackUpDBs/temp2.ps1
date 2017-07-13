	#load assemblies
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
	#Need SmoExtended for backup
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
	[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
	[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null
	
## Server to copy DB to
$targetServer = "OLTPProd01"
$targetBackupLocation = "\\OLTPProd01\c$\TempConfigBackup\Temp"
$targetUsername = "sa"
$targetPassword = "0pt1c5##"	

$srv = new-object Microsoft.SqlServer.Management.Smo.Server($targetServer)
$res = new-object Microsoft.SqlServer.Management.Smo.Restore
$backup = new-object Microsoft.SqlServer.Management.Smo.Backup

foreach($bak in Get-ChildItem $targetBackupLocation)
{
	$backup.Devices.AddDevice($bak, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
	$backup.Database = "AdventureWorks2008R22008R2"
	$backup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
	$backup.Initialize = $TRUE
	$backup.SqlBackup($srv)

	$res.Devices.AddDevice($bak, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
	$dt = $res.ReadFileList($srv)

	foreach($r in $dt.Rows)
	{
	   foreach ($c in $dt.Columns)
	   {
	      Write-Host $c "=" $r[$c]
	   }
	}
}