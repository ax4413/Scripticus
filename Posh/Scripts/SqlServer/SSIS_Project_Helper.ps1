<#
    .Synopsis
    Rename the ispac file. 
    .DESCRIPTION
    Rename the ispac file. Strictly speaking it does not rename the file such as 
    embed a new package name in the manifest which will be used to identify the 
    package once deployed.
    .EXAMPLE
    Edit-Ispac -PathToIspacFile "C:\users\syeadon\Desktop\ScorReportMergeUtility.ispac" -DeployedPackageName "ScorReportMergeUtility_VirginMedia"
    .EXAMPLE
    Edit-Ispac -PathToIspacFile "C:\users\syeadon\Desktop\ScorReportMergeUtility.ispac" `
    -DeployedPackageName "ScorReportMergeUtility_VirginMedia" `
    -PathToSevenZipExe "C:\ProgramFiles\7-Zip\7z.exe"
    .NOTES
    Seven Zip must be installed on the server that you are executing this script on or you can pass the exe in the lib folder and a refernce to it
#>
function Edit-Ispac
{
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
            HelpUri = 'http://www.microsoft.com/',
    ConfirmImpact = 'Medium')]
    Param
    (
        # The path to the ispac file that we want to rename
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 0,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                    Test-Path $_ -PathType 'leaf' -Filter '*.ispac'
                }
        )] 
        [Alias('PathToIspacFile')]
        [string] $ispacFile,

        # The name that we want to rename our ispac file as. 
        # strictly speaking it does not rename the file such as embed a new name in the manifest
        # which will be used when deploying the package
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 1,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('DeployedProjectName')]
        [Alias('ReplacementProjectName')]
        [string] $NewProjectName,

        # You can supply the path the the seven zip exe. if it is not $env:ProgramFiles\7-Zip\7z.exe 
        [Parameter(Mandatory = $false, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 2,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                    (Test-Path $_ -PathType 'leaf') -and 
                    (((Get-ChildItem $_ | Select-Object -ExpandProperty Name) -eq '7z.exe') -or 
                    ((Get-ChildItem $_ | Select-Object -ExpandProperty Name) -eq '7za.exe'))
                }
        )] 
        [Alias('PathToSevenZipExe')]
        [String] $SevenZip
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'

        if($SevenZip -eq $null -or $SevenZip -eq '')
        {
            $SevenZip = "$env:ProgramFiles\7-Zip\7z.exe"
        }

        Set-Alias -Name sz -Value $SevenZip

        # Get the ispac filename without the  .ispac extension
        $fileName = [io.path]::GetFileNameWithoutExtension($PathToIspacFile)
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Edit $fileName.ispac and embed a new package name of $ReplacementPackageName in the manifest"))
        {            
            # Define and create a tempory location hold a working set of files. A copy of the ispac as a zip and a uncaked acrive of the zip
            $tempPath = Join-Path -Path $([io.path]::GetTempPath()) -ChildPath $([io.path]::GetRandomFileName())
            $null = New-Item $tempPath -ItemType directory

            # The path to our temp zip file
            $tempZipFile = Join-Path -Path $tempPath -ChildPath "$fileName.zip"
            # The path to our temp Archive container
            $tempContainer = Join-Path -Path $tempPath -ChildPath 'Archive'


            # ----------------------------------------------------------------------------------------
            # Copy the .ispac file to the temp location, changing its file type to .zip. 
            # This is necessary as we can not unpack a .ispac
            $null = Copy-Item -Path $ispacFile -Destination $tempZipFile
            Write-Debug -Message ".ispac file copied to '$tempZipFile'"


            # ----------------------------------------------------------------------------------------
            # Unpack our temp .zip file to our temp archive using the 7zip utility
            $null = sz e $tempZipFile -o"$tempContainer" -r
            # Check for any errors
            if($LASTEXITCODE -ne 0)
            {
                Write-Error -Message "Unpacking up the archive '$tempZipFile' failed"
            }
            else 
            {
                Write-Debug -Message "Arcive unpacked at '$tempContainer'"
            }


            # ----------------------------------------------------------------------------------------
            # The manifest file contained within our archive.
            # We want to change the name contained within the manifest
            $manifestFilePath = Get-ChildItem -Path $tempContainer -Filter '*.manifest'

            # A hashtable containg the namespace used in the (xml) manifest file. 
            # This is required for us to use XPath on a xml document that uses namespaces
            $namespace = @{
                x = 'www.microsoft.com/SqlServer/SSIS'
            }

            # The XPath used to navigate to a node.attribute that we want to edit
            $xPath = "//x:Project/x:Properties/x:Property[@x:Name = 'Name']"

            # open the xml doc, edit the doc at a given node and save the doc
            $xml = [xml](Get-Content -Path $manifestFilePath.FullName)
            $xml |
            Select-Xml -XPath $xPath -Namespace $namespace |
            ForEach-Object -Process {
                $_.Node.set_InnerText($NewProjectName) 
            }
            $xml.Save($manifestFilePath.FullName)
            Write-Debug -Message "$($manifestFilePath.Name) modified"


            # ----------------------------------------------------------------------------------------
            # zip up our temp archive over the top of our original zip file
            $null = sz a -tzip $tempZipFile  $(Join-Path -Path $tempContainer -ChildPath '\*') -r
            # Check for any errors
            if($LASTEXITCODE -ne 0)
            {
                Write-Error -Message "Zipping up the archive '$tempContainer' failed"
            }
            else 
            {
                Write-Debug -Message "Arcive created at '$tempZipFile'"
            }


            # ----------------------------------------------------------------------------------------
            # Rename our temp zip file and over write the original .ispac file
            $null = Copy-Item -Path $tempZipFile -Destination $ispacFile
            Write-Debug -Message "Achive copied to '$ispacFile' changing the file extension on route"
            Write-Verbose -Message 'Ispac file modified'
        }
    }
    End
    {
    }
}

<#
    .Synopsis
    Deploy .ispac files
    .DESCRIPTION
    Deploy .ispac files
    .EXAMPLE
    $params = @{'sqlConnectionString'   =  'Data Source=192.168.0.1;Initial Catalog=master;Integrated Security=SSPI';
    'ssisDbName'            = 'SSISDB';
    'ssisDbPassword'        = 'P@55w0rd';
    'ssisFolderName'        = 'The SSISDB folder name';
    'ssisFolderDescription' = 'A description about SSISDB folder and iots purpose';
    'ssisProjectName'       = 'The name you want to deploy the package under';
    'pathToTheSsisProject'  = 'The path to the .ispac file' }

    Deploy-Ispac @params

#>
function Deploy-Ispac
{
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
            HelpUri = 'http://www.microsoft.com/',
    ConfirmImpact = 'Medium')]
    [OutputType([String])]
    Param
    (
        # The connection string to connect to the sql instance
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 0,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $sqlConnectionString,

        # The name of the SSIS DB Name
        [Parameter(Mandatory = $false, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 1,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisDbName = 'SSISDB',

        # The password to connect to the SSIS DB Catalogue
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 2,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisDbPassword,

        # The name of the folder that you want to install the package under
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 3,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisFolderName,

        # The name of the folder that you want to install the package under
        [Parameter(Mandatory = $false, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 4,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisFolderDescription,

        # The name of the pack
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 5,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisProjectName,

        # The path to the ispac SSIS package that you want to deploy
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 6,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                    Test-Path $_ -PathType Leaf -Filter '*.ispac'
                }
        )]
        [string] $pathToTheSsisProject
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'

        # The default value of the description is the folder name, unless the description variable has been supplied
        if($ssisFolderDescription -eq $null -or $ssisFolderDescription -eq '') 
        {
            $ssisFolderDescription = $ssisFolderName
        }

        # load dlls
        $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.IntegrationServices')
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$ssisDbName", "Deploy $ssisProjectName"))
        {
            # new up a sql connection
            $sqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $sqlConnectionString
             

            # connect to Integration Service
            $ssisServer = New-Object -TypeName Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices -ArgumentList $sqlConnection
             
            # check if catalog is already present, if not create one
            if(!$ssisServer.Catalogs[$ssisDbName]) 
            {
                # turn on clr intergration
                #$sqlConnection.Open()
                $command = $sqlConnection.CreateCommand()
                $command.CommandText  = "EXEC sp_configure 'clr enabled', 1;
                RECONFIGURE;"
                $count = $command.ExecuteReader()
                $sqlConnection.Close()
                # create new catalogue
                (New-Object -TypeName Microsoft.SqlServer.Management.IntegrationServices.Catalog -ArgumentList ($ssisServer, $ssisDbName, $ssisDbPassword)).Create()
            }

            # access the ssis catalogue
            $ssisCatalog = $ssisServer.Catalogs[$ssisDbName]
                        
            # check if the folder is already present, if not create one
            if(!$ssisCatalog.Folders.Item($ssisFolderName)) 
            {
                (New-Object -TypeName Microsoft.SqlServer.Management.IntegrationServices.CatalogFolder -ArgumentList ($ssisCatalog, $ssisFolderName, $ssisFolderDescription)).Create()
            }

            # access the ssidb folder
            $ssisFolder = $ssisCatalog.Folders.Item($ssisFolderName)
            
            # Deploy or redeploy teh project
            $null = $ssisFolder.DeployProject($ssisProjectName,[System.IO.File]::ReadAllBytes($pathToTheSsisProject))

            # access the deployed project
            $ssisProject = $ssisFolder.Projects.Item($ssisProjectName)

            Write-Verbose -Message "Project $ssisProjectName deployed"
        }
    }
    End
    {
    }
}

<#
    .Synopsis
    Configure teh deployed ispac file
    .DESCRIPTION
    Configure teh deployed ispac file
    .EXAMPLE
    Configure-DeployedProject -sqlConnectionString 'Data Source=localhost\nostrumsql;Initial Catalog=master;Integrated Security=SSPI' `
    -ssisDbName 'SSISDB' `
    -ssisFolderName 'BlahBlahBlah' `
    -ssisProjectName 'SomeProjectName' `
    -ssisEnvironmentName 'SomeEnvName' `
    -ssisEnvironmentDescription 'SomeEnvDesc' `
    -ssisParamaters 'An array of paramaters that match up to the paramaters in the project' 
#>
function Configure-DeployedProject
{
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
            HelpUri = 'http://www.microsoft.com/',
    ConfirmImpact = 'Medium')]
    Param
    (
        # The connection string to connect to the sql instance
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 0,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $sqlConnectionString,

        # The name of the SSIS DB Name
        [Parameter(Mandatory = $false, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 1,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisDbName = 'SSISDB',

        # The name of the folder that you want to install the package under
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 2,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisFolderName,

        # The name of the project
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 3,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisProjectName,

        # The name of the environment you want to create
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 4,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisEnvironmentName,

        # A description of the environment you want to create
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 5,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $ssisEnvironmentDescription,

        # An array of custome PsObjects that define the paramaters for creation
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 6,
        ParameterSetName = 'Parameter Set 1')]
        $ssisParamaters
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'

        # load dlls
        $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.IntegrationServices')
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$ssisDbName", "Configure the deployed project $ssisProjectName"))
        {    
            # ---------------------------------------------------------------------------------------
            # Get access to the required objects-
            # ---------------------------------------------------------------------------------------

            # new up a sql connection
            $sqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $sqlConnectionString
            #Connect to Integration Service Catalog and load project
            $ssisServer = New-Object -TypeName Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices -ArgumentList $sqlConnection
            # access the SSIS DB catalogue
            $ssisCatalog = $ssisServer.Catalogs[$ssisDbName]
            # access the apropriate folder under the SSIS DB
            $ssisFolder = $ssisCatalog.Folders.Item($ssisFolderName)
            # access the appropriate project undenr the SSISDB/Folder/*
            $ssisProject = $ssisFolder.Projects.Item($ssisProjectName)
            Write-Debug -Message "We now have access to: $ssisServer"
            Write-Debug -Message "                       $ssisCatalog"
            Write-Debug -Message "                       $ssisFolder"
            Write-Debug -Message "                       $ssisProject"

            # ---------------------------------------------------------------------------------------
            # The below code creates an environment for a catalog, dropping it first if required    -
            # ---------------------------------------------------------------------------------------

            if($ssisFolder.Environments.Contains($ssisEnvironmentName)) 
            {
                $environment = $ssisFolder.Environments.Item($ssisEnvironmentName)
                #$environment.Drop()
                Write-Debug -Message 'Environment accessed'
            }
            else 
            {
                $environment = New-Object -TypeName 'Microsoft.SqlServer.Management.IntegrationServices.EnvironmentInfo' -ArgumentList ($ssisFolder, $ssisEnvironmentName, $ssisEnvironmentDescription)
                $environment.Create()
                Write-Debug -Message 'Environment created'
            }

            # drop variables if they exist
            foreach($param in $ssisParamaters) 
            {
                if($environment.Variables -eq $null)
                {
                    break 
                }
                # are we dealing with connection manages
                if($param.PSObject.Properties.Match('ConnectionManagerType').Count)
                {
                    Configure-EnvironmentConnectionManager -Environment $environment -Paramater $param
                } else 
                {
                    Configure-EnvironmentParamater -Environment $environment -Paramater $param
                }
            }

            # add an environment reference to project if there is not one allready
            if(-not $ssisProject.References.Contains($ssisEnvironmentName, $ssisFolder.Name)) 
            {
                $ssisProject.References.Add($ssisEnvironmentName, $ssisFolder.Name)
            }
            $ssisProject.Alter()

            Write-Debug -Message 'Environmental paramaters configured and referenced'
 
 
            # ---------------------------------------------------------------------------------------
            # The below code will create reference to environment variables for project parameters  -
            # once we fire 'alter', changes will reflect in the project.                            -
            # We can run this modified package anytime.-
            # Considering they are package level parameters.-
            # ---------------------------------------------------------------------------------------

            # access the project paramaters 
            $projectParamaters = $ssisParamaters | Where-Object -Property ParamaterType -EQ -Value 'Project'

            foreach($param in $projectParamaters) 
            {
                if($ssisProject.Parameters -eq $null)
                {
                    break 
                }

                if($param.PSObject.Properties.Match('ConnectionManagerType').Count)
                {
                    if($param.PSObject.Properties.Match('ConnectionString').Count)
                    {
                        if($ssisProject.Parameters.Contains("CM.$($param.ConnectionString)"))
                        {
                            $ssisProject.Parameters["CM.$($param.ConnectionString)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.ConnectionString)
                            Write-Debug -Message "Project paramater 'CM.$($param.ConnectionString)' configured"
                        }
                    }

                    if($param.PSObject.Properties.Match('ServerName').Count)
                    {
                        if($ssisProject.Parameters.Contains("CM.$($param.ServerName)"))
                        {
                            $ssisProject.Parameters["CM.$($param.ServerName)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.ServerName)
                            Write-Debug -Message "Project paramater 'CM.$($param.ServerName)' configured"
                        }
                    }

                    if($param.PSObject.Properties.Match('InitialCatalog').Count)
                    {
                        if($ssisProject.Parameters.Contains("CM.$($param.InitialCatalog)"))
                        {
                            $ssisProject.Parameters["CM.$($param.InitialCatalog)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.InitialCatalogValue)
                            Write-Debug -Message "Project paramater 'CM.$($param.InitialCatalog)' configured"
                        }
                    }

                    if($param.PSObject.Properties.Match('UserName').Count)
                    {
                        if($ssisProject.Parameters.Contains("CM.$($param.UserName)"))
                        {
                            $ssisProject.Parameters["CM.$($param.UserName)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.UserNameValue)
                            Write-Debug -Message "Project paramater 'CM.$($param.UserName)' configured"
                        }
                    }

                    if($param.PSObject.Properties.Match('Password').Count)
                    {
                        if($ssisProject.Parameters.Contains("CM.$($param.Password)"))
                        {
                            $ssisProject.Parameters["CM.$($param.Password)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.PasswordValue)
                            Write-Debug -Message "Project paramater 'CM.$($param.Password)' configured"
                        }
                    }
                }
                else 
                {
                    if($ssisProject.Parameters.Contains($param.Name))
                    {
                        $ssisProject.Parameters[$param.Name].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.Name)
                        Write-Debug -Message "Project paramater '$($param.Name)' configured"
                    }
                }
            }

            $ssisProject.Alter()

 
            # ---------------------------------------------------------------------------------------
            # The below code will create reference to environment variables for package parameters  -
            # once we fire 'alter', changes will reflect in the package.                            -
            # We can run this modified package anytime.-
            # Considering they are package level parameters.-
            # ---------------------------------------------------------------------------------------

            # Get a distinct list of packages which require paramater configuration
            $ssisPackageNames = $ssisParamaters |
            Where-Object -Property ParamaterType -EQ -Value 'Package' | 
            Select-Object -Unique -Property PackageName

            # iterate the packages
            foreach($packageName in $ssisPackageNames) 
            {
                # access this package
                $ssisPackage = $ssisProject.Packages.Item($packageName.PackageName)
                # get a list of paramater configurations for this package
                $packageParamaters = $ssisParamaters | Where-Object -Property PackageName -EQ -Value $packageName.packageName

                # iterate the paramater configs
                foreach($param in $packageParamaters) 
                {
                    if($ssisPackage.Parameters -eq $null)
                    {
                        break 
                    }

                    if($param.PSObject.Properties.Match('ConnectionManagerType').Count)
                    {
                        if($param.PSObject.Properties.Match('ConnectionString').Count)
                        {
                            if($ssisPackage.Parameters.Contains("CM.$($param.ConnectionString)"))
                            {
                                $ssisPackage.Parameters["CM.$($param.ConnectionString)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.ConnectionString)
                                Write-Debug -Message "Package paramater 'CM.$($param.ConnectionString)' configured"
                            }
                        }

                        if($param.PSObject.Properties.Match('ServerName').Count)
                        {
                            if($ssisPackage.Parameters.Contains("CM.$($param.ServerName)"))
                            {
                                $ssisPackage.Parameters["CM.$($param.ServerName)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.ServerName)
                                Write-Debug -Message "Package paramater 'CM.$($param.ServerName)' configured"
                            }
                        }

                        if($param.PSObject.Properties.Match('InitialCatalog').Count)
                        {
                            if($ssisPackage.Parameters.Contains("CM.$($param.InitialCatalog)"))
                            {
                                $ssisPackage.Parameters["CM.$($param.InitialCatalog)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.InitialCatalogValue)
                                Write-Debug -Message "Package paramater 'CM.$($param.Initial;Catalog)' configured"
                            }
                        }

                        if($param.PSObject.Properties.Match('UserName').Count)
                        {
                            if($ssisPackage.Parameters.Contains("CM.$($param.UserName)"))
                            {
                                $ssisPackage.Parameters["CM.$($param.UserName)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.UserNameValue)
                                Write-Debug -Message "Package paramater 'CM.$($param.UserName)' configured"
                            }
                        }

                        if($param.PSObject.Properties.Match('Password').Count)
                        {
                            if($ssisPackage.Parameters.Contains("CM.$($param.Password)"))
                            {
                                $ssisPackage.Parameters["CM.$($param.Password)"].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.PasswordValue)
                                Write-Debug -Message "Package paramater 'CM.$($param.Password)' configured"
                            }
                        }
                    }
                    else 
                    {
                        if($ssisPackage.Parameters.Contains($param.Name))
                        {
                            $ssisPackage.Parameters[$param.Name].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,$param.Name)
                            Write-Debug -Message "Package paramater '$($param.Name)' configured"
                        } 
                    }
                }

                $ssisPackage.Alter()
            }

            Write-Verbose -Message "Project $ssisProjectName configured"
 

            ##We can execute above changed package anytime using referencing this environment like below
            #$environmentReference = $ssisProject.References.Item("Environment_from_powershell", $ssisFolder.Name)
            #$environmentReference.Refresh()
            #Write-Host $environmentReference.ReferenceId
            #$ssisPackage.Execute($false, $environmentReference)
            #Write-Host "Package Execution ID: " $executionId
        }
    }
    End
    {
    }
}



<#
    .Synopsis
    Configure a ssis enviroment with a custom Ps Object paramater 
    .DESCRIPTION
    Configure a ssis enviroment with a custom Ps Object paramater 
    .EXAMPLE
    $ssisServer  = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices 'SomeConnectionString'
    $ssisCatalog = $ssisServer.Catalogs['SomeCatalogueName']
    $ssisFolder  = $ssisCatalog.Folders.Item('SomeFolderName')
    $environment = $ssisFolder.Environments.Item('SomeEnvironmentName')
   
    $param = New-Paramater -Name 'RecoveryAgenciesToExclude' 
    -Type ([System.TypeCode]::String) `
    -Value '1,2,3' `
    -project
  
    Configure-EnvironmentParamater -Environment $environment -Paramater $param
#>
function Configure-EnvironmentParamater
{
    [CmdletBinding(DefaultParameterSetName = 'ParameterSet1', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
            HelpUri = 'http://www.microsoft.com/',
    ConfirmImpact = 'Medium')]
    Param
    (
        # The connection string to connect to the sql instance
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
        Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $environment,

        # 
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 1,
        ParameterSetName = 'ParameterSet1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Paramater,

        # 
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 1,
        ParameterSetName = 'ParameterSet2')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ParamaterName,

        # 
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 2,
        ParameterSetName = 'ParameterSet2')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ParamaterType,

        # 
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 3,
        ParameterSetName = 'ParameterSet2')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ParamaterValue
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'

        if($pscmdlet.ParameterSetName  -eq 'ParameterSet1')
        {
            $ParamaterName  = $Paramater.Name
            $ParamaterType  = $Paramater.Type
            $ParamaterValue = $Paramater.Value
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess('Configure a environment paramater'))
        {
            # we are dealing with typical variables
            if($environment.Variables.Contains($ParamaterName))
            {
                $v = $environment.Variables.Item($ParamaterName)
                $null = $environment.Variables.Remove($v)
                $environment.Alter()
            }
            $environment.Variables.Add($ParamaterName, $ParamaterType, $ParamaterValue, $false, '')
            $environment.Alter()

            Write-Debug -Message "Environmental paramater configured '$ParamaterName'"
        }
    }
    end
    {
    }
}

<#
    .Synopsis
    Configure a ssis enviroment with a custom Ps Object paramater 
    .DESCRIPTION
    Configure a ssis enviroment with a custom Ps Object paramater 
    .EXAMPLE
    $ssisServer  = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices 'SomeConnectionString'
    $ssisCatalog = $ssisServer.Catalogs['SomeCatalogueName']
    $ssisFolder  = $ssisCatalog.Folders.Item('SomeFolderName')
    $environment = $ssisFolder.Environments.Item('SomeEnvironmentName')
   
    $param = New-DataSource -Name 'IceNetMainDS' 
    -Type "ConnectionString" `
    -Value "SomeConnectionStringToAResource" `
    -Project
  
    Configure-EnvironmentParamater -Environment $environment -Paramater $param
#>
function Configure-EnvironmentConnectionManager
{
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
            HelpUri = 'http://www.microsoft.com/',
    ConfirmImpact = 'Medium')]
    Param
    (
        # The connection string to connect to the sql instance
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 0,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $environment,

        # The name of the SSIS DB Name
        [Parameter(Mandatory = $true, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                ValueFromRemainingArguments = $false, 
                Position = 1,
        ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Paramater
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'

        if(-not $Paramater.PSObject.Properties.Match('ConnectionManagerType').Count)
        {
            Write-Error -Message 'A non ps custom connection manager obj has been passed to Configure-EnvironmentConnectionManager'
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess('Configure a environment connection manager'))
        {
            if($Paramater.PSObject.Properties.Match('ConnectionString').Count)
            {
                Configure-EnvironmentParamater -Environment $environment `
                -ParamaterName $Paramater.ConnectionString `
                -ParamaterType $Paramater.Type `
                -ParamaterValue $Paramater.ConnectionStringValue
                Write-Debug -Message "Environmental connection manager configured '$($Paramater.ServerName)'"
            }

            if($Paramater.PSObject.Properties.Match('ServerName').Count)
            {
                Configure-EnvironmentParamater -Environment $environment `
                -ParamaterName $Paramater.ServerName `
                -ParamaterType $Paramater.Type `
                -ParamaterValue $Paramater.ServerNameValue
                Write-Debug -Message "Environmental connection manager configured '$($Paramater.ServerName)'"
            }

            if($Paramater.PSObject.Properties.Match('InitialCatalog').Count)
            {
                Configure-EnvironmentParamater -Environment $environment `
                -ParamaterName $Paramater.InitialCatalog `
                -ParamaterType $Paramater.Type `
                -ParamaterValue $Paramater.InitialCatalogValue
                Write-Debug -Message "Environmental connection manager configured '$($Paramater.InitialCatalog)'"
            }

            if($Paramater.PSObject.Properties.Match('UserName').Count)
            {
                Configure-EnvironmentParamater -Environment $environment `
                -ParamaterName $Paramater.UserName `
                -ParamaterType $Paramater.Type `
                -ParamaterValue $Paramater.UserNameValue
                Write-Debug -Message "Environmental connection manager configured '$($Paramater.UserName)'"
            }

            if($Paramater.PSObject.Properties.Match('Password').Count)
            {
                Configure-EnvironmentParamater -Environment $environment `
                -ParamaterName $Paramater.Password `
                -ParamaterType $Paramater.Type `
                -ParamaterValue $Paramater.PasswordValue
                Write-Debug -Message "Environmental connection manager configured '$($Paramater.Password)'"
            }
        }
    }
    end
    {
    }
}

<#
    .Synopsis
    Create a SSIS paramater
    .DESCRIPTION
    Create a SSIS paramater
    .EXAMPLE
    New-Paramater -Name 'foo' -Value 'bar' -Type ([System.TypeCode]::String) -Project
    .EXAMPLE
    New-Paramater -Name 'foo' -Value 'bar' -Type ([System.TypeCode]::String) -Package -packageName "FooBar.dtsx"
#>
function New-Paramater
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultSet', 
            SupportsShouldProcess = $true, 
    ConfirmImpact = 'Medium')]
    Param
    (
        # The name of the paramater
        [Parameter(Mandatory = $true, 
        Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        # The .net type of the paramater
        [Parameter(Mandatory = $true, 
        Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.TypeCode] $Type,

        # The value of teh paramater
        [Parameter(Mandatory = $true, 
        Position = 2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Value,

        # Is this a project paramater
        [Parameter(Mandatory = $true, 
                Position = 3,
        ParameterSetName = 'ProjectSet')]
        [switch] $Project,

        # Is this a package paramater
        [Parameter(Mandatory = $true, 
                Position = 3,
        ParameterSetName = 'PackageSet')]
        [switch] $Package,

        # If a package paramater the name of the pacakage 
        [Parameter(Mandatory = $true, 
                Position = 4,
        ParameterSetName = 'PackageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                    ($_.Split('.')[($_.Split('.')).Length-1]) -eq 'dtsx' 
                }
        )]
        [string] $packageName = ''
    )

    Begin
    {
        if($pscmdlet.ParameterSetName -eq 'PackageSet') 
        {
            $ParamaterType = 'Package'
        }
        else 
        {
            $ParamaterType = 'Project'
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess('Create a new SSIS paramater'))
        {
            $obj = New-Object -TypeName PSObject `
            -Property ( @{
                    'Name'        = $Name
                    'Type'        = $Type
                    'Value'       = $Value
                    'ParamaterType' = $ParamaterType
            } ) 

            if($ParamaterType -eq 'Package') 
            {
                $obj | Add-Member -MemberType NoteProperty -Name 'PackageName' -Value $packageName
            }

            return $obj
        }
    }
    End
    {
    }
}

<#
    .Synopsis
    Create a SSIS data source paramater
    .DESCRIPTION
    Create a SSIS data source paramater
    .EXAMPLE
    New-DataSource -Name 'IceNetMainDS' 
    -Value 'Data Source=localhost;User ID=UserName;Initial Catalog=IceNetMain_SY;Provider=SQLNCLI11.1;Persist Security Info=True;Auto Translate=False;' 
    -Project
    .EXAMPLE
    New-DataSource -Name 'IceNetMainDS' 
    -Value 'Data Source=localhost;User ID=UserName;Initial Catalog=IceNetMain_SY;Provider=SQLNCLI11.1;Persist Security Info=True;Auto Translate=False;' 
    -Package 
    -PackageName "FooBar.dtsx"
#>
function New-DataSource 
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultSet', 
            SupportsShouldProcess = $true, 
    ConfirmImpact = 'Medium')]
    [OutputType([String])]
    Param
    (
        # The name of the paramater
        [Parameter(Mandatory = $true, 
        Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        # The .net type of the paramater
        [Parameter(Mandatory = $true, 
        Position = 1)]
        [ValidateSet('FlatFile','ConnectionString')]
        [string] $Type,

        # The value of teh paramater
        [Parameter(Mandatory = $true, 
        Position = 2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        # Is this a project paramater
        [Parameter(Mandatory = $true, 
                Position = 3,
        ParameterSetName = 'ProjectSet')]
        [switch] $Project,

        # Is this a package paramater
        [Parameter(Mandatory = $true, 
                Position = 3,
        ParameterSetName = 'PackageSet')]
        [switch] $Package,

        # If a package paramater the name of the pacakage 
        [Parameter(Mandatory = $true, 
                Position = 4,
        ParameterSetName = 'PackageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                    ($_.Split('.')[($_.Split('.')).Length-1]) -eq 'dtsx' 
                }
        )]
        [string] $packageName = ''
    )

    Begin
    {
        if($pscmdlet.ParameterSetName -eq 'PackageSet') 
        {
            $ParamaterType = 'Package'
        }
        else 
        {
            $ParamaterType = 'Project'
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess('Create a new SSIS paramater'))
        {
            $obj = New-Object -TypeName PSObject `
            -Property ( @{
                    'Name'                = $Name
                    'Type'                = [System.TypeCode]::String
                    'Value'               = $Value
                    'ConnectionManagerType' = $Type
                    'ParamaterType'       = $ParamaterType
            } ) 

            if($ParamaterType -eq 'Package') 
            {
                $obj | Add-Member -MemberType NoteProperty -Name 'PackageName' -Value $packageName
            }

            if($Type -eq 'ConnectionString') 
            {
                $config = @{}
                $Value.Split(';') | 
                ForEach-Object -Process {
                    $a = $_.Split('=') 
                    $config += @{
                    }
                }

                $obj | Add-Member -MemberType NoteProperty -Name 'ConnectionString' -Value "$Name.ConnectionString"
                $obj | Add-Member -MemberType NoteProperty -Name 'ConnectionStringValue' -Value "$Value"

                if($config.Contains('Data Source'))
                {
                    $obj | Add-Member -MemberType NoteProperty -Name 'ServerName' -Value "$Name.ServerName"
                    $obj | Add-Member -MemberType NoteProperty -Name 'ServerNameValue' -Value ($config.get_Item('Data Source'))
                }

                if($config.Contains('Initial Catalog'))
                {
                    $obj | Add-Member -MemberType NoteProperty -Name 'InitialCatalog' -Value "$Name.InitialCatalog"
                    $obj | Add-Member -MemberType NoteProperty -Name 'InitialCatalogValue' -Value ($config.get_Item('Initial Catalog'))
                }

                if($config.Contains('User ID'))
                {
                    $obj | Add-Member -MemberType NoteProperty -Name 'UserName' -Value "$Name.UserName"
                    $obj | Add-Member -MemberType NoteProperty -Name 'UserNameValue' -Value ($config.get_Item('User ID'))
                }

                if($config.Contains('Password'))
                {
                    $obj | Add-Member -MemberType NoteProperty -Name 'Password' -Value "$Name.Password"
                    $obj | Add-Member -MemberType NoteProperty -Name 'PasswordValue' -Value ($config.get_Item('Password'))
                }
            }

            return $obj
        }
    }
    End
    {
    }
}
