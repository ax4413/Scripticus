Import-Module icenet.base.database       -Force
Import-Module icenet.deploy.database.sql -Force

# =================================================================================================================================
# Configure the below variables

$createMain              = $true                    # Do we want to create the Main Db  
$createDocs              = $false                   # Do we want to create the Docs Db
$createExternal          = $false                   # Do we want to create the External Db
$createReports           = $false                   # Do we want to create the DReporting Db
                                   
$createAudit             = $false                   # Do we want to create the Audit Db     
$createASP_Dbs           = $fasle                   # Do we want to create Auth, Membership and ASP State database  

$generateCreationScripts = $false                   # Do we want to generate any creation scripts
$AddBaseDataToMain       = $false                    # Set to false to NOT apply base data to Main
$AddBaseDataToDocs       = $true                    # Set to false to NOT apply base data to Main

$instance                = "172.22.38.252"          # the dev instance

$Version                 = "3.13"                   # Your database will be stamped with this revision number.

$clientName              = "DVVAPSY"                # Client name will be part of your database name
$environment             = "DEV"                    # Must be DEV, STG, QA, TRN or PRD. Will be part of teh database name
$developerInitials       = ''                       # if this is left null or empty the dev initials will not be appended to the db name

$mapServiceAccounts      = $false                   # if set, service accounts will be created and mapped to databases
               
$dbOwner                 = "BuildMaster"
$userName                = 'BuildMaster'            # Omit these if you want to use win auth. Yo will need to fix the $params var also
$password                = 'system'                 # Omit these if you want to use win auth. Yo will need to fix the $params var also

                                                    # Comment in/out appropraitly and change you path to suit
#$PathToBranch            = "D:\Code\Icenet 3\Branches\$version"
$PathToBranch            = 'D:\Code\3.0\Branches'

 # i am assuming a standard relative path of \src\Icenet.database.main after the $PathToBranch. 
 # if this is not the case then this script is likley to error when concatenating paths

$domain                  = 'ICENET'



# =================================================================================================================================
# These variables are unlikly to require modification unless you want to do something outside of the norm                         

                                                    # Database name convention 
                                                    # FooMainDEV,    FooDocumentsDEV,    FooExternalDEV,    FooReportingDEV,    FooAuditDEV
                                                    # FooMainDEV_SY, FooDocumentsDEV_SY, FooExternalDEV_SY, FooReportingDEV_SY, FooAuditDEV_SY
$mainDatabase            = 'VirginM2MainDEV' #$clientName + "Main"      #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$documentDatabase        = $clientName + "Documents" #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$externalDatabase        = $clientName + "External"  #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$reportingDatabase       = $clientName + "Reporting" #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$auditDatabase           = $clientName + "Audit"     #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$authDatabase            = $clientName + "Auth"      #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$membershipDatabase      = $clientName + "Membership"#+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
$sessionStateDatabase    = $clientName + "AspState"  #+ $environment + $( if([string]::IsNullOrWhiteSpace($developerInitials)){ '' } else { "_$developerInitials" } )
                                                 
$OutputDir               = 'c:\temp\CreatingScripts'

$clientType              = "mml"                    # Nonsence but necessary
$fileServer              = "blah"                   # Nonsence but necessary                       
                                                    
$verbose                 = $false                   # Allows us to set verbose mode globaly
$errorAction             = 'Stop'                   # Allows us to set te error action globaly

$ErrorActionPreference   = 'stop'
                                                    
$waitDurationMiliseconds = 3000                     # The amount of time you will wait before teh script starts
$titlePadValue           = 70                       # amount of padding 




if(-not (Test-Path $PathToBranch)){ throw "In valid path '$PathToBranch'" }

# =================================================================================================================================
Write-Host ""                                                                                                
Write-Host "".PadRight($titlePadValue, '=') -ForegroundColor Green
Write-Host ""                                                                                                
write-host "The following databases will be created at $Version"                                             
write-host ""                                                                                                
write-host " - $reportingDatabase"    -ForegroundColor $(if($createReports  -eq $true) {'Green'} else {'Magenta'})
write-host " - $documentDatabase"     -ForegroundColor $(if($createDocs     -eq $true) {'Green'} else {'Magenta'})   
write-host " - $externalDatabase"     -ForegroundColor $(if($createExternal -eq $true) {'Green'} else {'Magenta'})   
write-host " - $auditDatabase"        -ForegroundColor $(if($createAudit    -eq $true) {'Green'} else {'Magenta'}) 
write-host " - $mainDatabase"         -ForegroundColor $(if($createMain     -eq $true) {'Green'} else {'Magenta'})                                         
write-host " - $authDatabase"         -ForegroundColor $(if($createASP_Dbs  -eq $true) {'Green'} else {'Magenta'})   
write-host " - $membershipDatabase"   -ForegroundColor $(if($createASP_Dbs  -eq $true) {'Green'} else {'Magenta'})   
write-host " - $sessionStateDatabase" -ForegroundColor $(if($createASP_Dbs  -eq $true) {'Green'} else {'Magenta'})   
Write-Host ""
Write-Host "With the following options"
Write-Host ""
Write-Host " - Base data will $(if($AddBaseDataToMain -eq $false){'NOT '})be applied to Main."                 -ForegroundColor $(if($AddBaseDataToMain -eq $true) {'Green'} else {'Magenta'})
Write-Host " - Base data will $(if($AddBaseDataToDocs -eq $false){'NOT '})be applied to Docs."                 -ForegroundColor $(if($AddBaseDataToDocs -eq $true) {'Green'} else {'Magenta'})
Write-Host " - Database creation scripts will $(if($generateCreationScripts -eq $false){'NOT '})be generated." -ForegroundColor $(if($generateCreationScripts -eq $true) {'Green'} else {'Magenta'})
Write-Host " - Mapping of Service Accounts is $(if($mapServiceAccounts -eq $false){'NOT '})enabled."           -ForegroundColor $(if($mapServiceAccounts -eq $true) {'Green'} else {'Magenta'})
Write-Host ""                                                                                                
Write-Host "Creation will start in $($waitDurationMiliseconds/1000) seconds"                                 
Write-Host ""
Write-Host "".PadRight($titlePadValue, '=') -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds $waitDurationMiliseconds
# =================================================================================================================================



# =================================================================================================================================
Write-Host ""
if($mapServiceAccounts -eq $true) {
    write-host "Creating Logons on the dev sql instance  ".PadRight($titlePadValue, '=') -ForegroundColor Green 
    Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType All -ErrorAction $errorAction |
    New-SqlEnvironmentLogins -Instance $instance -SqlLogonName $userName -SqlPassword $password -ErrorAction $errorAction
}else {
    write-host "These logons need creating on the dev sql instance  ".PadRight($titlePadValue, '=') -ForegroundColor Green 
    Write-Host "They would also need configuring against each individual db." -ForegroundColor Green
    Write-Host "(Not necessary in dev)" -ForegroundColor Green
    $hash = Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType All -ErrorAction $errorAction
    $hash.Keys | sort
}



# =================================================================================================================================
if($createReports -eq $true){
    Write-Host ""
    Write-Host "Creating a new Reporting Db  ".PadRight($titlePadValue, '=') -ForegroundColor Green
    try{
        $params = @{'Instance'     = $instance;
                    'SqlLogonName' = $userName
                    'SqlPassword'  = $password;
                    'Verbose'      = $verbose;
                    'ErrorAction'  = $errorAction; }
                   
        Remove-Database @params -DatabaseName $reportingDatabase -Force | Out-Null

        $reportingDbcreationScript = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Reporting\Generic\DbChangesReporting.sql")

        New-ReportingDatabase @params -DatabaseName $reportingDatabase -SchemaCreationScript $reportingDbcreationScript -SchemaCreationScriptVersion $Version

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType Reporting -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $reportingDatabase -ErrorAction $errorAction
        }

        # only create scripts if you want them
        if($generateCreationScripts -eq $true){
            New-SchemaCreationScript @params -DatabaseName $reportingDatabase -DatabaseType Reporting -OutputDir "$OutputDir\Reporting"
        }
    } 
    catch {    
        Write-Host $($Error | Format-List -Force | Out-String) -ForegroundColor Red -BackgroundColor Black
    }
}




# =================================================================================================================================
if($createDocs -eq $true){
    Write-Host ""
    Write-Host "Creating a new Documents Db  ".PadRight($titlePadValue, '=') -ForegroundColor Green
    try{
        $baseDataScriptDir        = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Documents\DatabaseCreation\BaseData")
        $changesScriptPath        = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Documents\DBChangesDocs.sql")
        $documentDbcreationScript = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Documents\DatabaseCreation\CreateSchema.sql")

        $params = @{ 'Instance'     = $instance;
                     'SqlLogonName' = $userName
                     'SqlPassword'  = $password;
                     'Verbose'      = $verbose;
                     'ErrorAction'  = $errorAction; }


        Remove-Database @params -DatabaseName $documentDatabase -Force | Out-Null

        if($AddBaseDataToDocs-eq $true){
            $params.Add('PathToBaseDataScripts',$baseDataScriptDir)
        }       

        New-DocumentDatabase @params -DatabaseName $documentDatabase -SchemaCreationScript $documentDbcreationScript -SchemaCreationScriptVersion $Version

        # the following functions do not need this variable
        $params.Remove('PathToBaseDataScripts')

        # db changes main can not be run if we have not added base data. As it undoutably contains 
        # at least a refernce to base data
        if($AddBaseDataToDocs-eq $true){
            Invoke-ApplyDatabaseChangeScripts @params -DatabaseName $documentDatabase -TrunkDBChangeScript $changesScriptPath -DesiredDatabaseVersion $Version
        }

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType Documents -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $documentDatabase -ErrorAction $errorAction
        }

        # only create scripts if you want them
        if($generateCreationScripts -eq $true){
            New-SchemaCreationScript @params -DatabaseName $documentDatabase -DatabaseType Documents -OutputDir $OutputDir
        }
    } 
    catch {    
        Write-Host $($Error | Format-List -Force | Out-String) -ForegroundColor Red -BackgroundColor Black
    }
}




# =================================================================================================================================
if($createExternal -eq $true){
    Write-Host ""
    Write-Host "Creating a new External Db  ".PadRight($titlePadValue, '=') -ForegroundColor Green
    try{
        $params = @{'Instance'     = $instance;
                    'SqlLogonName' = $userName
                    'SqlPassword'  = $password;
                    'Verbose'      = $verbose;
                    'ErrorAction'  = $errorAction; }

        Remove-Database @params -DatabaseName $externalDatabase -Force | Out-Null
    
        $externalDbCreationScript = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.External\DatabaseCreation\CreateSchema.sql")

        New-ExternalDatabase @params -DatabaseName $externalDatabase -SchemaCreationScript $externalDbCreationScript -SchemaCreationScriptVersion $Version

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType External -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $externalDatabase -ErrorAction $errorAction
        }

        # only create scripts if you want them
        if($generateCreationScripts -eq $true){
            New-SchemaCreationScript @params -DatabaseName $externalDatabase -DatabaseType Documents -OutputDir "$OutputDir\External"
        }
    } 
    catch {    
        Write-Host $($Error | Format-List -Force | Out-String) -ForegroundColor Red -BackgroundColor Black
    }
}




# =================================================================================================================================
if($createAudit -eq $true){
    Write-Host ""
    Write-Host "Creating a new Audit Db  ".PadRight($titlePadValue, '=') -ForegroundColor Green
    Write-Host "You will need to create the database objects using dbup!!!"  -ForegroundColor Green            
    try{
        $params = @{'Instance'     = $instance;
                    'SqlLogonName' = $userName
                    'SqlPassword'  = $password;
                    'Verbose'      = $verbose;
                    'ErrorAction'  = $errorAction; }
                   
        Remove-Database @params -DatabaseName $auditDatabase -Force | Out-Null

        New-AuditDatabase @params -DatabaseName $auditDatabase | Out-Null

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType Audit -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $auditDatabase -ErrorAction $errorAction
        }

        # only create scripts if you want them
        if($generateCreationScripts -eq $true){
            New-SchemaCreationScript @params $instance -DatabaseType Documents -OutputDir "$OutputDir\Audit"
        }
    } 
    catch {    
        Write-Host $($Error | Format-List -Force | Out-String) -ForegroundColor Red -BackgroundColor Black
    }
}



# =================================================================================================================================
if($createMain -eq $true){
    Write-Host ""
    Write-Host "Creating a new Main Db  ".PadRight($titlePadValue, '=') -ForegroundColor Green
    try{
        $params = @{'Instance'     = $instance;
                    'SqlLogonName' = $userName
                    'SqlPassword'  = $password;
                    'Verbose'      = $verbose;
                    'ErrorAction'  = $errorAction; }


        Remove-Database @params -DatabaseName $mainDatabase -Force | Out-Null
    
        $baseDataScriptDir     = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Main\DatabaseCreation\Vanilla\BaseData")
        $changesScriptPath     = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Main\DBChangesMain.sql")
        $additionalScripts     = "DbChangesSSRS.sql"
        $creationScriptPath    = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Main\DatabaseCreation\Vanilla\CreateSchema.sql")
    
        if($AddBaseDataToMain-eq $true){
            $params.Add('PathToBaseDataScripts',$baseDataScriptDir)
        }

        New-MainDatabase @params -DatabaseName $mainDatabase -DbOwner $dbOwner `
                -DocumentDatabaseName $documentDatabase -ExternalDatabaseName $externalDatabase -AuditDatabaseName $auditDatabase `
                -SchemaCreationScript $creationScriptPath -SchemaCreationScriptVersion $Version
        
        # the following functions do not need this variable
        $params.Remove('PathToBaseDataScripts')

        # set sys params
        Update-SystemParamaters @params -ClientName $clientName `
                -ClientType $clientType -FileServer $fileServer -DatabaseName $mainDatabase
                
        
        ## set up synonym sys params helpfull in dev
        New-SynonymSystemParameter @params -MainDatabaseName $mainDatabase -DocumentsDatabaseName $documentDatabase
        New-SynonymSystemParameter @params -MainDatabaseName $mainDatabase -ExternalDatabasename $externalDatabase
    
        # db changes main can not be run if we have not added base data. As it undoutably contains 
        # at least a refernce to base data
        if($AddBaseDataToMain-eq $true){
            Invoke-ApplyDatabaseChangeScripts @params -DatabaseName $mainDatabase -TrunkDBChangeScript $changesScriptPath -AdditionalScriptNames $additionalScripts -DesiredDatabaseVersion $Version
        }

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType Main -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $mainDatabase -ErrorAction $errorAction
        }

        # only create scripts if you want them
        if($generateCreationScripts -eq $true){
            New-SchemaCreationScript @params $instance -Database $mainDatabase -DatabaseType Main -OutputDir $OutputDir
        }
    } 
    catch {    
        Write-Host $($Error | Format-List -Force | Out-String) -ForegroundColor Red -BackgroundColor Black
    }
}



# =================================================================================================================================
if($createASP_Dbs -eq $true){
    Write-Host ""
    Write-Host "Creating a new Auth, ASP & Membership Databases  ".PadRight($titlePadValue, '=') -ForegroundColor Green
    try{
        $params = @{'Instance'     = $instance;
                    'SqlLogonName' = $userName
                    'SqlPassword'  = $password;
                    'Verbose'      = $verbose;
                    'ErrorAction'  = $errorAction; }
        

        $exe = Get-AspNetRegSqlUtility -ThirtyTwoBit


        Remove-Database @params -DatabaseName $authDatabase -Force | Out-Null
        New-AuthDatabase @params -DatabaseName $authDatabase -SchemaCreationScript (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Auth\DbChangesAuth.sql") | Out-Null

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType Auth -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $auditDatabase -ErrorAction $errorAction
        }
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        Remove-Database @params -DatabaseName $membershipDatabase -Force | Out-Null
        New-MembershipDatabase @params -DatabaseName $membershipDatabase -PathToAspNetRegSqlUtility $exe | Out-Null

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType Membership -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $membershipDatabase -ErrorAction $errorAction
        }
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        Remove-Database @params -DatabaseName $sessionStateDatabase -Force | Out-Null
        New-AspStateDatabase @params -DatabaseName $sessionStateDatabase -PathToAspNetRegSqlUtility $exe  | Out-Null

        if($mapServiceAccounts -eq $true) {
            Get-WinAuthServiceLogonNames -DomainName $domain -Environment $environment -ClientName $clientName -DatabaseType ASPState -ErrorAction $errorAction |
            Invoke-SetDatabaseUserAndRole -Instance $instance -DatabaseName $sessionStateDatabase -ErrorAction $errorAction
        }
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    } 
    catch {    
        Write-Host $($Error | Format-List -Force | Out-String) -ForegroundColor Red -BackgroundColor Black
    }
}



# =================================================================================================================================
Write-Host ""
Write-Host "".PadRight($titlePadValue, '=') -ForegroundColor Green
Write-Host "Database Creation Complete" -ForegroundColor Green
Write-Host "".PadRight($titlePadValue, '=') -ForegroundColor Green