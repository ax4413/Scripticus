cls
function RestoreDataBase {
    param([string] $newDBName, [string] $backupFilePath, [bool] $isNetworkPath = $true)

    try
    {
        # Load assemblies
        [System.Reflection.Assembly]::LoadWithPartialName
		("Microsoft.SqlServer.SMO") | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName
		("Microsoft.SqlServer.SmoExtended") | Out-Null
        [Reflection.Assembly]::LoadWithPartialName
		("Microsoft.SqlServer.ConnectionInfo") | Out-Null
        [Reflection.Assembly]::LoadWithPartialName
		("Microsoft.SqlServer.SmoEnum") | Out-Null

        # Create sql server object
        $server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") "(local)"

        # Copy database locally if backup file is on a network share
        if($isNetworkPath)
        {
            $fileName = [IO.Path]::GetFileName($backupFilePath)
            $localPath = Join-Path -Path $server.DefaultFile -ChildPath $fileName
            Copy-Item $backupFilePath $localPath
            $backupFilePath = $localPath
        }

        # Create restore object and specify its settings
        $smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")
        $smoRestore.Database = $newDBName
        $smoRestore.NoRecovery = $false;
        $smoRestore.ReplaceDatabase = $true;
        $smoRestore.Action = "Database"

        # Create location to restore from
        $backupDevice = New-Object ("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($backupFilePath, "File")
        $smoRestore.Devices.Add($backupDevice)

        # Give empty string a nice name
        $empty = ""

        # Specify new data file (mdf)
        $smoRestoreDataFile = New-Object ("Microsoft.SqlServer.Management.Smo.RelocateFile")
        $defaultData = $server.DefaultFile
        if (($defaultData -eq $null) -or ($defaultData -eq $empty))
        {
            $defaultData = $server.MasterDBPath
        }
        $smoRestoreDataFile.PhysicalFileName = Join-Path -Path $defaultData -ChildPath ($newDBName + "_Data.mdf")

        # Specify new log file (ldf)
        $smoRestoreLogFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
        $defaultLog = $server.DefaultLog
        if (($defaultLog -eq $null) -or ($defaultLog -eq $empty))
        {
            $defaultLog = $server.MasterDBLogPath
        }
        $smoRestoreLogFile.PhysicalFileName = Join-Path -Path $defaultLog -ChildPath ($newDBName + "_Log.ldf")

        # Get the file list from backup file
        $dbFileList = $smoRestore.ReadFileList($server)

        # The logical file names should be the logical filename stored in the backup media
        $smoRestoreDataFile.LogicalFileName = 
		$dbFileList.Select("Type = 'D'")[0].LogicalName
        $smoRestoreLogFile.LogicalFileName = 
		$dbFileList.Select("Type = 'L'")[0].LogicalName

        # Add the new data and log files to relocate to
        $smoRestore.RelocateFiles.Add($smoRestoreDataFile)
        $smoRestore.RelocateFiles.Add($smoRestoreLogFile)

        # Restore the database
        $smoRestore.SqlRestore($server)

        "Database restore completed successfully"
    }
    catch [Exception]
    {
        "Database restore failed:`n`n " + $_.Exception
    }
    finally
    {
        # Clean up copied backup file after restore completes successfully
        if($isNetworkPath)
        {
            Remove-Item $backupFilePath
        }
    }
}

## Calling Code
#RestoreDataBase "AbmCms" "X:\Temp1\abmCMS_20110601104732.bak" $false
