

FUNCTION Restore-Db ($BackupFile, $DbName)
{
$RestP = "K:\MSSQL\MSSQL10.MSSQLSERVER\MSSQL\DATA"
$moveStr = ""
$q = "RESTORE FILELISTONLY FROM DISK = "+ $BackupFile
$b = Invoke-Sqlcmd -Query $q
$ln = $b | select logicalName, PhysicalName
foreach ($lnn in $ln) {$e = $lnn.PhysicalName.LastIndexOf("\")+1;$l =$lnn.PhysicalName.length; $ll = $l-$e; $phys = $lnn.PhysicalName.Substring($e,$ll); $moveStr = $moveStr+"MOVE '"+ $lnn.LogicalName + "' TO '"+$RestP+"\"+$phys+"', "}
$RestStr = "Restore Database "+$DbName+" FROM DISK = "+$BackupFile+" WITH "+$moveStr+ " STATS = 5"
Invoke-Sqlcmd -Query $RestStr -querytimeout 3600
}

$BackupsFiles = "F:\"
$dirs = dir $BackupsFiles  | Where {$_.psIsContainer -eq $true}
$dbs = $dirs | select name, fullname

foreach ($dbx in $dbs) {$BackupFile = gci -path $dbx.fullname -include *.bak -recurse; $DbName = $dbx.name; write-host "Restoring database $DbName from file $BackupFile";$BackupFile = "'"+$BackupFile+"'"; Restore-Db $BackupFile $DbName}