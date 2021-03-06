<#
.Synopsis
   Ensure that SSRS folders start with a '/'
.DESCRIPTION
   Ensure that SSRS folders start with a '/'
.EXAMPLE
   Normalize-SSRSFolder "GreenDeal"
#>
function Normalize-SSRSFolder 
{
	[CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='low')]
    [OutputType([String])]
	
	Param
	(
		# The folder name/path to be normalised
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("path")] 
    	[string]$Folder
	)

	Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Prefix the folder name with a / if there is not one allready present"))
        {
			if (-not $Folder.StartsWith('/')) {
		        $Folder = '/' + $Folder
		    }
        }
    }
    End
    {
		return $Folder
    } 
}
 


<#
.Synopsis
   Return a folder name based on the imput
.DESCRIPTION
   Long description
.EXAMPLE
   Get-FolderName -ContentType "Report" -ExecutionType  "Unatended" -Organisation "GreenDeal"
.EXAMPLE
   Get-FolderName "DataSource" "Integrated" "GreenDeal"
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   string
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-FolderName 
{
	[CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='low')]
    [OutputType([String])]
    Param
    (
        # The content type (Report or DataSource)
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateSet("Report", "DataSource")]
        [string] $ContentType,


	  	# The execution type (integrated or unatended)
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Parameter Set 1')]
        [ValidateSet("Integrated", "Unatended")]
		[string] $ExecutionType, 
		
		 # The organisation name
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[string] $Organisation
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
			if($ContentType -eq "Report"){
				$Folder = "/" + "Definitions" + "/" + "IceNet" + "/" +  $Organisation
			}
			elseif($ContentType -eq "DataSource"){
				$Folder = "/" + "DataSources" + "/" + "IceNet" + "/" +  $ExecutionType + "/" + $Organisation
			}
			else {
				Write-Error "Get-FolderName() Invalid content type"
			}
        }
    }
    End
    {
		return $Folder
    }
}



<#
.Synopsis
   Create new SSRS folder structure
.DESCRIPTION
   Create new SSRS folder structure
.EXAMPLE
   New-SSRSFolder -Proxy $Proxy -Name $Folder
.EXAMPLE
   New-SSRSFolder -Proxy $Proxy -FolderName $Folder
.EXAMPLE
   New-SSRSFolder -Proxy $Proxy -Path $Folder
#>
function New-SSRSFolder 
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    Param
    (
        # The proxy to the wsdl
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("wsdl")] 
        $Proxy,

        # The new folder name
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyString()]
		[Alias("FolderName")] 
		[Alias("Path")] 
        [string] $Name
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Create a new folder on the SSRS server called $Name"))
        {
		    $Name = Normalize-SSRSFolder -Folder $Name
		    
		    if ($Proxy.GetItemType($Name) -ne 'Folder') {
		        $Parts = $Name -split '/'
		        $Leaf = $Parts[-1]
		        $Parent = $Parts[0..($Parts.Length-2)] -join '/'
		 
		        if ($Parent) {
		            New-SSRSFolder -Proxy $Proxy -Name $Parent
		        } else {
		            $Parent = '/'
		        }
		        
		        $Proxy.CreateFolder($Leaf, $Parent, $null)
                Write-Verbose "Created a new folder on the SSRS server called $Name located at $Parent"
		    }
        }
    }
    End
    {
    }
}



<#
.Synopsis
   Create a new data source
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-SSRSDataSource
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # The proxy to the wsdl
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("wsdl")] 
        $Proxy,
		
		# The data source name
		[Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("DataSource")] 
    	[string] $DataSourceName,
		
		# The connection string to the data
		[Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $ConnectionString,
		
		# The folder where the data source resides
		[Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $DataSourceFolder
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Create a new data source definition $DataSourceName for the folder $DataSourceFolder"))
        {
			$type = $Proxy.GetType().Namespace

		    $DSDdatatype = ($type + '.DataSourceDefinition')
		    $DSD = new-object ($DSDdatatype)

		    if($DSD -eq $null){
		          Write-Error Failed to create data source definition object
		    }

            #Define the credentials
		    $CredentialDataType = ($type + '.CredentialRetrievalEnum')
		    $Cred = new-object ($CredentialDataType)
		    $Cred.value__ = 2    # .Integrated
		      
		    $DSD.CredentialRetrieval =$Cred
		    $DSD.ConnectString       = $ConnectionString
		    $DSD.Enabled             = $true
		    $DSD.EnabledSpecified    = $false
		    $DSD.Extension           = "SQL"
		    $DSD.Prompt              = $null
		    $DSD.WindowsCredentials  = $false
            $DSD.ImpersonateUserSpecified = $false
            
            #New data source definition		      
		    $newDSD = $proxy.CreateDataSource($DataSourceName, $DataSourceFolder, $true, $DSD, $null)
            Write-Verbose "A new data source definition has been created $DataSourceName for the folder $DataSourceFolder"
        }
    }
    End
    {
		return $newDSD
    }
}



<#
.Synopsis
   Create a new security policy
.DESCRIPTION
   Create a new security policy
.EXAMPLE
   New-SecurityPolicy -Proxy $Proxy -RoleName "Content Manager" -UserName "syeadon"
.OUTPUTS
   A SecurityPolicy object
#>
function New-SecurityPolicy
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # The proxy to the wsdl
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("wsdl")] 
        $Proxy,
		
		# The role name
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateSet("Content Manager", "Browser")]
    	[string] $RoleName,
		
		# The User name 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $UserName
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Create a new security policy with the following role $RoleName"))
        {
			$type = $Proxy.GetType().Namespace
		    
            #Define a data type obj of type "Policy"
		    $datatype = ($type + '.Policy')
		        
		    #Define a new policy
		    $NewPolicy = New-Object ($datatype);
		    $NewPolicy.GroupUserName = $UserName;

		    #Define a data type obj of type "Role"
		    $datatype = ($type + '.Role')

		    #Define a new "Content Manager" role
		    $NewRole = New-Object ($datatype);
		    $NewRole.Name = $RoleName
		    
		    #Add this role to the new policy
		    $NewPolicy.Roles += $NewRole

            Write-Verbose "Security policy created. Group User Name = $UserName, Role Name = $RoleName"

		    return $NewPolicy
        }
    }
    End
    {
    }
}
 


<#
.Synopsis
   Deploy all the reports found $LocalReportPath to the $Organisation on the SSRS server
.DESCRIPTION
   Deploy all the reports found $LocalReportPath to the $Organisation on the SSRS server
.EXAMPLE
   Deploy-RDLs 	-Proxy $Proxy `
				-Organisation $Organisation `
				-DataSorceConnectionString $UnatendedDataSourceConnectionString `
				-LocalReportPath $LocalUnatendedReportPath `
				-DataSourceADUser $UnatendedDataSourceADUser `
				-ReportsADUser $UnatendedReportsADUser `
				-ExecutionType "Unatended" 
.EXAMPLE
   Deploy-RDLs	-Proxy $Proxy `
				-Organisation $Organisation `
				-DataSorceConnectionString $IntegratedDataSourceConnectionString `
				-LocalReportPath $LocalIntegratedReportPath `
				-DataSourceADUser $IntegratedDataSourceADUser `
				-ReportsADUser $IntegratedReportsADUser `
				-ExecutionType "Integrated"
#>
function Deploy-RDLs
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='High')]
    [OutputType([String])]
    Param
    (
        # The proxy to the wsdl
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("wsdl")] 
        $Proxy,
		
		# The path to the reports that we want to deploy
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("ReportCollection")]
		[System.IO.FileInfo[]] $Reports,
		
		# The path to the local reports for deployment
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $Organisation,
		
		# The data source connection string
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $DataSorceConnectionString,
		
		# The AD user you wish the data source to execute as
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=4,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $DataSourceADUser,
		
		# The AD user you want the reports to execurte as
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=5,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    	[string] $ReportsADUser,
		
		# The context in which these reports will be run
		[Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=6,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateSet("Unatended", "Integrated")]
		[string] $ExecutionType,
		
		# Indicates whether we want to just deploy the collection of reports or 
		# delete reports from the server that are missing from the collection
		[Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=7,
                   ParameterSetName='Parameter Set 1')]
		[switch] $RemoveMissingReportsFromTheReportServer
    )

    Begin
    {
		$ServerName = $proxy.Url.ToString().Replace("http:", "").Split('/', [System.StringSplitOptions]::RemoveEmptyEntries)[0].Trim()
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Copy the $ExecutionType rdls to the SSRS machine $ServerName"))
        {
			#Array to hold warning and errors
			$warnings =@()
				
			$type = $Proxy.GetType().Namespace
			
			# DATA SOURCE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		    
            #Define the data source folder name
		    $DataSourceFolder = Get-FolderName -Organisation $Organisation -ExecutionType $ExecutionType -ContentType "DataSource"

		    #Create the data source folder structure
		    New-SSRSFolder -Proxy $Proxy -Name $DataSourceFolder | Out-Null
		    
		    #Define the data source name
		    $DataSourceName = $Organisation

		    #Create a new data source
		    $SharedDataSource = New-SSRSDataSource -Proxy $Proxy -DataSourceName $DataSourceName -DataSourceFolder $DataSourceFolder -ConnectionString $DataSorceConnectionString
			Write-Verbose "Data Source Created $DataSourceName"
			
		    #Declare a array to hold security policies for the data sources
		    $SecurityPolicies = @();

		    #Add this new "Browser" policy to the collection of new policies
		    $SecurityPolicies += New-SecurityPolicy -Proxy $Proxy -RoleName "Content Manager" -UserName $DataSourceADUser

		    #Get access to the data source
		    $dsName = $DataSourceFolder +"/" + $DataSourceName

		    #Apply security policies to this data source
		    $proxy.SetPolicies($dsName, $SecurityPolicies) | Out-Null

			Write-Verbose "Data Source $DataSourceName has had its security policy applied"
			
			
            
			# REPORTS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			
            #Define a report folder name
		    $ReportsFolder = Get-FolderName -Organisation $Organisation -ExecutionType $ExecutionType  -ContentType "Report"

		    #Create the new Reports folder structure
		    New-SSRSFolder -Proxy $Proxy -Name $ReportsFolder | Out-Null

		    #Declare a array to hold security policies for reports
		    $SecurityPolicies = @();

		    #Add this new "Browser" policy to the collection of new policies
		    $SecurityPolicies += New-SecurityPolicy -Proxy $Proxy -RoleName "Content Manager" -UserName $ReportsADUser

			# Need the name of the rdls for upload to see which one if any of the allready presnt rdls need removing
			$ReportNamesForUpload = ($Reports | ForEach-Object { $_.Name.Replace(".rdl","") } )
			
		    #Iterate the rdls to deploy and manage their security requirments
		    foreach($item in $Reports) {
		        #Load the rdl into memory
		        $stream = Get-Content $item.FullName -Encoding byte
		        #Push the rdl up to our organisations report folder
		        $proxy.CreateCatalogItem("Report", $item.BaseName, $ReportsFolder, $true, $stream, $null, [ref]$warnings) | Out-Null

				Write-Verbose "Report $($item.BaseName) has been copied to $ReportsFolder"

		        #Declare the deployed report items full path
		        $ReportItem = $ReportsFolder + "/" + $item.BaseName

		        #Apply security policies to this report
		        $proxy.SetPolicies($ReportItem, $SecurityPolicies) | Out-Null
				
				Write-Verbose "Report $($item.BaseName) has had its security $($SecurityPolicies[0].Roles[0].Name) set"
			}
					
			#Re point the reports to the shared datasources
			$ReportItems = $Proxy.ListChildren($ReportsFolder, $false)
			
			$ReportsForDeletion = @()
			
			foreach($ReportItem in $ReportItems) {
				if(-not $ReportNamesForUpload.Contains($ReportItem.Name)) {
					$ReportsForDeletion += $ReportItem.Path
				}	
				
				$reportPath = $ReportItem.path
				$dataSources = $Proxy.GetItemDataSources($reportPath)
				
				foreach($dataSource in $dataSources) {
		            $myDataSource = New-Object ("$type.DataSource")
		            $myDataSource.Name = $SharedDataSource.Name
					
					$ref = New-Object ("$type.DataSourceReference")
					$ref.Reference = $SharedDataSource.Path
		            $myDataSource.Item = $ref

		            $dataSource.item = $myDataSource.Item

		            $Proxy.SetItemDataSources($reportPath, $dataSources)

		            Write-Verbose "Report $($ReportItem.Name) has had the data source $($dataSource.Name) re pointed to the shared data source $($SharedDataSource.Name)"
				}
			}
			
			
			# Remove any rdls from the server that are not present in teh collection of rdls for upload
			if($RemoveMissingReportsFromTheReportServer.IsPresent) {
				$ReportsForDeletion | ForEach-Object { 
					$Proxy.DeleteItem($_)
					Write-Verbose "Deleted report $_"
				}
			}
			
        }
    }
    End
    {
    }
}