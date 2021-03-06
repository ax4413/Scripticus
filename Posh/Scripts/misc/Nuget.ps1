<#
.Synopsis
   Modify the nuspec file to contain the new version number
.DESCRIPTION
   Modify the nuspec file to contain the new version number
.EXAMPLE
   Edit-NuspecFile -NuspecFile C:\Temp\BlahBlah.nuspec -Version 1.1.1.1
#>
function Edit-NuspecFileVersion()
{
	[CmdletBinding(DefaultParameterSetName='DefaultParameterSet', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='medium')]
    Param
    (
        # The file path to the nuspec file
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='DefaultParameterSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateScript({Test-Path $_ -PathType 'leaf' -Filter "*.nuspec"})] 
		[string]
        $NuspecFile,

		# The new version number
        [Parameter(Mandatory=$true,
				   Position=1,
                   ParameterSetName='DefaultParameterSet')]
        [ValidateNotNullOrEmpty()]
        [System.Version]
        $Version
	)

    Begin
    {
		[xml]$myXML = Get-Content $NuspecFile
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Create a PackageSource subfolder and the nuget package in the folder $PackagePath"))
        {		
			$myXML.package.metadata.version = $Version.ToString()
			$myXML.Save($NuspecFile)
			Write-Verbose "Modified the version number of the file '$(split-path $NuspecFile -leaf)' to $($Version.ToString())"
		}
	}
	End
	{
	}

}


<#
.Synopsis
   Creates a nuget package
.DESCRIPTION
   creates the nuspec file and nuget package
.EXAMPLE
   New-NugetPackage -PackagePath "c:\temp" -packageContents "C:\Temp\reports\*.rdl" -powershellScripts "C:\temp\blah.ps1" -NuspecId "BlahBlahId" -NuspecTitle "Blah Blah" -NuspecDescription "Blah Blah Blah" -NuspecVersion "1.0.0.0"
.EXAMPLE
   New-NugetPackage -PackagePath "c:\temp" -packageContents "C:\Temp\reports\*" -powershellScripts "C:\temp\blah.ps1" -NuspecId "BlahBlahId" -NuspecTitle "Blah Blah" -NuspecDescription "Blah Blah Blah" -NuspecVersion "1.0.0.0"
.EXAMPLE
   $params = @{ 'PackagePath'       = "C:\Temp\Bob";
		        'PackageContents'   = "C:\Temp\Reports\*.xlsx";
                'PowershellScripts' = "C:\Temp\blah.ps1";
   		        'NuspecId'          = "BlahBlahId";
		        'NuspecTitle'       = "Blah Blah";
		        'NuspecDescription' = "Blah Blah Blah";
		        'NuspecVersion'     = "1.0.0.0" }

   $NugetPackage = New-NugetPackage @params -verbose
#>
function New-NugetPackage
{
    [CmdletBinding(DefaultParameterSetName='DefaultParameterSet', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='medium')]
    [OutputType([String])]
    Param
    (
        # The file path to the nuspec file
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='DefaultParameterSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateScript({Test-Path $_ -PathType 'leaf' -Filter "*.nuspec"})] 
		[string]
        $NuspecFile,
		
		
		# The creation destination for the nuget package.
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='DefaultParameterSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("NugetPackageDirectory")] 
		$PackagePath,


        # The file path to the files to be added to the packages content folder
        [Parameter(Mandatory=$true,
                   Position=2,
                   ParameterSetName='DefaultParameterSet')]
        [AllowEmptyCollection()]
        #[ValidateScript({(Get-ChildItem -Path $_).Count -ge 1})] # I cant validate an array of paths here
		[string[]]
        $PackageContents,


        # The file path to the powershell files to be added to the package tools folder
        [Parameter(Mandatory=$false,
                   Position=3,
                   ParameterSetName='DefaultParameterSet')]
        [AllowNull()]
        #[ValidateScript({Test-Path $_ -PathType 'leaf'})] # I cant validate an array of paths here
		[string[]]
		[Alias("PackagePowershellScripts")] 
        $PowershellScripts,	
        
        # The file path to any files to be added to the lib folder
        [Parameter(Mandatory=$false,
                   Position=4,
                   ParameterSetName='DefaultParameterSet')]
        [AllowNull()]
        #[ValidateScript({Test-Path $_ -PathType 'leaf'})] # I cant validate an array of paths here
		[string[]]
		[Alias("LibraryFiles")] 
        $libFiles		
    )

    Begin
    {
        $PowershellScripts | ForEach-Object { Test-Path $_ -PathType 'leaf' } | Out-Null
        
        $i = 0
        $PackageContents | ForEach-Object { $i += (Get-ChildItem -Path $_).Count }
        if($i -eq 0){
            Write-Error "The `$PackageContents variable must point to valid files for inclusion in the contents folder of teh nuget package"
        }
        
		# This is the original nuspec file 
		$OriginalNuspecFile = $NuspecFile
		
		$PackageSource = "PackageSource\"
		$Tools = "Tools\"
		$Content ="Content\"
        $lib = "lib\"
		
		# Sub folder of package path
		$PackageSourcePackagePath = Join-Path $PackagePath -ChildPath $PackageSource
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Create a PackageSource subfolder and the nuget package in the folder $PackagePath"))
        {
            if(Test-Path $PackageSourcePackagePath) {
                Remove-Item $PackageSourcePackagePath -Recurse -Force | Out-Null
                Write-Verbose "Deleted file '$PackageSourcePackagePath'"
            }
            
            # Create the package source directory structure
            New-Item -Path $PackageSourcePackagePath -ItemType directory -Force | Out-Null
			Write-Verbose "Created file structure .\$PackageSource"
			
            # Create the package source content directory structure
            $Package_Files = Join-Path $PackageSourcePackagePath -ChildPath $Content
            New-Item -Path $Package_Files -ItemType directory -Force | Out-Null
			Write-Verbose "Created file structure .\$PackageSource$Content"
			
			# Create the package source tools directory structure
			$Package_Tools = Join-Path $PackageSourcePackagePath -ChildPath $Tools
            New-Item -Path $Package_Tools -ItemType directory -Force | Out-Null
			Write-Verbose "Created file structure .\$PackageSource$Tools"

            # Create the package lib directory structure
			$Package_Lib = Join-Path $PackageSourcePackagePath -ChildPath $lib
            New-Item -Path $Package_Lib -ItemType directory -Force | Out-Null
			Write-Verbose "Created file structure .\$PackageSource$lib"
            
			# Copy the original nuspec file to the package source folder
			Copy-Item $OriginalNuspecFile -Destination $PackageSourcePackagePath |Out-Null
			Write-Verbose "Copied to .\$PackageSource the following file(s) '$OriginalNuspecFile'"
			# The variable nuspec file now points at the one in teh sub folder
			$NewNuspecFile = Get-ChildItem $PackageSourcePackagePath -Filter "*.nuspec" 
			
            # Copy the powershell scripts to the package
            if($PowershellScripts -ne $null){
                $PowershellScripts | 
					ForEach-Object { 
						Copy-Item -Path $_ -Destination $Package_Tools 
						Write-Verbose "Copied to .\$PackageSource$Tools the following file(s) '$_'"
					} | Out-Null
            }

            # Copy all files to be included in the package to the package
            if($PackageContents -ne $null){
                $PackageContents | 
					ForEach-Object { 
						Copy-Item -Path $_ -Destination $Package_Files 
						Write-Verbose "Copied to .\$PackageSource$Content the following file(s) '$_'"
					} | out-null
			}
			
            # copy to lib
            if($libFiles -ne $null){
                $libFiles | 
                    ForEach-Object {
                        Copy-Item -Path $_ -Destination $Package_Lib
                        Write-Verbose "Copied to .\$PackageSource$lib the following file(s) '$_'"
                    } | Out-Null
            }

            # Create the nuget package
            nuget pack $NewNuspecFile.FullName -OutPutDirectory $PackagePath | Out-Null
			
			$NugetPackage = Get-ChildItem $PackagePath -Filter "*.nupkg" | Select-Object -ExpandProperty FullName
			Write-Verbose "Created nuget package '$NugetPackage'"
			
			return $NugetPackage
        }
    }
    End
    {
    }
}
