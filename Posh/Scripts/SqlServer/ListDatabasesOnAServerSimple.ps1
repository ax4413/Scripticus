<#
list all dbs on a given server and a subset of their info
#>

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

$srvname="192.168.20.81"
$mySrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
$mySrvConn.ServerInstance=$srvname
$mySrvConn.LoginSecure = $false
$mySrvConn.Login = "sa"
$mySrvConn.Password = "0pt1c5##"

Write-Host $mySrvConn.ConnectionString

$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $mySrvConn
$dbs=$s.Databases


$dbs | SELECT Name, Collation, CompatibilityLevel, AutoShrink, RecoveryModel, Size, SpaceAvailable