#####################################################################################
## This script performs three action
## 1) Backs up a database
## 2) Restores a database
## 3) Sets the owner of the new database
#####################################################################################

cls

## Load functions
. "C:\Users\stephen\Documents\WindowsPowerShell\Scripts\BackUpDBs\BackUpDB.ps1"
. "C:\Users\stephen\Documents\WindowsPowerShell\Scripts\BackUpDBs\RestoreDB.ps1"

# A list of db's
$dbList = "C:\DBList.txt"

## Server where DB resides
$sourceServer = "SQL-2005-B"
$sourceBackupLocation = "\\sql-2005-b\x$\Temp"
$sourceUsername = "sa"
$sourcePassword = "system4490"
## Server to copy DB to
$targetServer = "OLTPProd01"
$targetBackupLocation = "\\OLTPProd01\x$\Temp"
$targetUsername = "sa"
$targetPassword = "0pt1c5##"

# global error variable
$global:localError = $false

$errorCount = 0
$successCount = 0



# For each db in the dblist
foreach ($db in get-content $dbList)
{
	$localError = $false

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
	
		
	# Back up the db
	if($global:localError -eq $false){
		# Create a new directory if necessary
		if((Test-path $sourceBackupLocation) -eq $false){
			New-Item $sourceBackupLocation -type directory
		}
		Write-Host "${sourceServer}\${db} Backing up DB"
		## Back up a db
		$backedUpFile = BackUpDatabase -serverName $sourceServer -username $sourceUsername -password $sourcePassword -dbToBackup $db -backupTo $sourceBackupLocation
		Write-Host "${sourceServer}\${db} backed up to $backedUpFile"
	}
	
	
	# Copy db.bak to taget server
	if($global:localError -eq $false){
		# create the directory if neccessary
		if((Test-path $targetBackupLocation) -eq $false){
			New-Item $targetBackupLocation -type directory
		}
		# Copy .bak file to the target server
		Copy-Item $backedUpFile $targetBackupLocation
		$file = Get-ChildItem $backedUpFile
		$restoreFile = $targetBackupLocation
		$restoreFile +="\"
		$restoreFile += $file.Name
		Write-Host "${backedUpFile} copied to ${restoreFile}"
	}
	
	
#	# Restore target db.bak
#	if($global:localError -eq $false){
#		Write-Host "${targetServer}\${db} Restoring..."
#		## Restore the backed up db
#		ResoreDatabase -backupFile $restoreFile -serverName $targetServer -username $targetUsername -password $targetPassword
#		Write-Host "${targetServer}\${db} Restored"
#		Write-Host "${targetServer}\${db} Changing owner to $owner"
#	}
#	
#
#	# Change db owner
#	if($global:localError -eq $false){
#		## Set the db owner of the newly restored db to be SA
#		SetDBOwner -targetServer $targetServer -dbName $db -owner 'sa'
#		Write-Host "${targetServer}\${db} Owned by $owner"
#		Write-Host "${targetServer}\${db} Transfer complete"
#		Write-Host ""
#	}

	# Increment 
	if($global:localError -eq $false){
		$successCount++
	}
	
}


Write-Host ""
Write-Host ""
Write-Host "/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\"
Write-Host "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/"	
Write-Host "/\									/\"
Write-Host "\/     	Operation Complete                        \/"
Write-Host "/\     	$successCount db's successfully transfered.           /\"
Write-Host "\/		$errorCount db's failed		    	            \/"
Write-Host "/\									/\"
Write-Host "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/"
Write-Host "/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\"


## force Errors
# $error[0]|format-list –force