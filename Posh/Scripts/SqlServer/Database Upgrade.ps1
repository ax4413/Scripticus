Import-Module icenet.base.database       -Force
Import-Module icenet.deploy.database.sql -Force


$createDocs              = $true                   # Do we want to create the Docs Db
$createExternal          = $true                   # Do we want to create the External Db
$createMain              = $true                   # Do we want to create the Main Db                                     
$generateCreationScripts = $false                  # Do we want to generate any creation scripts

$instance                = "172.22.38.252"
$clientName              = "zzz"
$environment             = "DEV"
$Version                 = "3.13"                       
#$PathToBranch            = "D:\Code\Icenet 3\Branches\$version"
$PathToBranch            = 'D:\Code\Icenet 3\Trunk'

$dbOwner                 = "syeadon"
$userName                = 'syeadon'               # Omit these if you want to use win auth. Yo will need to fix the $params var also
$password                = 'diamonds'                   # Omit these if you want to use win auth. Yo will need to fix the $params var also
                         
$mainDatabase            = $clientName + "Main"      + $environment
$documentDatabase        = $clientName + "Documents" + $environment
$externalDatabase        = $clientName + "External"  + $environment
                                                 
$OutputDir               = 'c:\temp\CreatingScripts'

$clientType              = "mml"                   # Nonsence but necessary
$fileServer              = "blah"                  # Nonsence but necessary                       
                                                   
$verbose                 = $false                  # Allows us to set verbose mode globaly
$errorAction             = 'Stop'                  # Allows us to set te error action globaly

$waitDurationMiliseconds = 3000                    # The amount of time you will wait before teh script starts
$titlePadValue           = 70                      # amount of padding 




if(-not (Test-Path $PathToBranch)){ throw "In valid path '$PathToBranch'" }





$params = @{'Instance'     = $instance;
                    'DatabaseName' = $mainDatabase;
            'SqlLogonName' = $userName
            'SqlPassword'  = $password;
            'Verbose'      = $verbose;
            'ErrorAction'  = $errorAction; }

   
$baseDataScriptDir     = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Main\DatabaseCreation\Vanilla\BaseData")
$changesScriptPath     = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Main\DBChangesMain.sql")
$additionalScripts     = "DbChangesSSRS.sql"
$creationScriptPath    = (Join-Path $PathToBranch -ChildPath "src\Icenet.Database.Main\DatabaseCreation\Vanilla\CreateSchema.sql")
    
        
# the following functions do not need this variable
$params.Remove('databaseName')
        
  
Invoke-ApplyDatabaseChangeScripts @params -DatabaseName $mainDatabase -TrunkDBChangeScript $changesScriptPath -AdditionalScriptNames $additionalScripts
