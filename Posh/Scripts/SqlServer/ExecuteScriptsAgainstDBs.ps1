
# list to hold server and dbs to be targeted
$list = Import-Csv C:\Temp\Server.csv
# script to be executed
$script = "C:\Temp\Rodenstock_Dupplicate_FSCC_Test.sql"
# user credentials
$username = "sa"
$password = "system"
$server = ""
$db =""

# Create Arrays to hold
$Results = @()
$Success =@()
$Errors =@()

# Clear the screen
clear
Write-Host "Execute Sql against a list of DBs"
Write-Host""

#loop list of dbs
foreach($obj in $list)
{
	# populate variables
	$result = $null
	$server = $obj.ServerName
	$db = $obj.DBName
	
	# only attempt to execute sql cmd where the servere and db is not string.empty
	if($server -ne "" -and $db -ne "")
	{	
	# generate sql cmd string
		$cmdstring = "sqlcmd -S ${server} -d ${db} -U ${username} -P ${password} -i ${script}"
		
		#execute sql cmd
		$result = cmd /c $cmdstring
		
		# format the array of objects held in the result variable into a single string
		$formatedResult = ""
		foreach($item in $result.SyncRoot)
		{
			$formatedResult += $item.Trim() + " "
		}
		
		# append the formated result string to the array of results
		$Results += $formatedResult
	}
}


# seperate the errors from the successes
foreach($r in $Results)
{
	if ($r.Contains("Success")) {$success += $r}
	else{$errors += $r}
}


# write successes to screen
Write-Host "Success"
foreach($r in $Success)
{
	Write-Host $r
	Write-Host ""
}

# write errors to screen
Write-Host ""
Write-Host ""
Write-Host "Errors"
foreach($r in $Errors)
{
	Write-Host $r
	Write-Host ""
}

