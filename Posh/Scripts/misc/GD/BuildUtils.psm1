<#
.Synopsis
   Builds $SolutionPath using msbuild
.DESCRIPTION
   Restores packages and builds $SolutionFolder using msbuild. Verbosity level is quite by default.
   SolutionName defaults to the folder name if not specified. Eg /path/to/project/project.sln
.EXAMPLE
   Invoke-Build -SolutionFolder path/to/solution -Verbosity detailed
.EXAMPLE
   Invoke-Build -SolutionFolder path/to/solution -SolutionName mysolution -Verbosity detailed
#>
function Invoke-Build
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
      #  [ValidateScript({Test-Path $_ -PathType Container})]
        [string] $SolutionFolder,
        [string] $SolutionName,
        [ValidateSet("q", "quiet", "m", "minimal", "n", "normal", "d", "detailed", "diag", "diagnostic", ignoreCase=$true)]
        [string] $Verbosity = "q"
    )

    Begin
    {
    }
    Process
    {
        if(!$SolutionName){
            $SolutionName = (Get-Item $SolutionFolder).Name
        }
        $SolutionPath = Join-Path $SolutionFolder "$SolutionName.sln"

        if(-not (Test-Path $SolutionPath -PathType Leaf)){
            throw "$SolutionPath not found"
        }
        
        Write-Host "Restoring packages for $SolutionPath" -ForegroundColor Yellow
        Restore-Packages $SolutionPath

        Invoke-EnsureCodeAnalysisIgnoresVersion '11.0'

        Write-Host "Building $SolutionPath" -ForegroundColor Yellow

        Invoke-CommandLine -Expression "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe /nologo -v:$Verbosity /m '$SolutionPath'" -Operation "Building $SolutionPath"        
    }
    End
    {
    }
}

function Restore-Packages
{
    Param
    (
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$SolutionPath
    )
        
    Invoke-CommandLine -Expression "D:\nuget\nuget.exe restore '$SolutionPath'" -Operation "nuget restore"
    
}

function Invoke-CommandLine {
    param(
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $Expression,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string] $Operation
    )
    $Expression | Invoke-Expression
    if($LASTEXITCODE -ne 0){
        throw "$Operation exited with code $LASTEXITCODE"
    }
}

function Invoke-EnsureNugetV2Feed
{
    param
    (
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$path = "$env:APPDATA\NuGet\NuGet.Config"
    )

    [xml]$v2 = @"
<configuration>
    <packageSources>
        <add key="v2.nuget.org" value="https://www.nuget.org/api/v2/" />
    </packageSources>
</configuration>
"@

    $config = [xml](Get-Content $path)
    if($config.SelectSingleNode("//packageSources/add[@value='https://www.nuget.org/api/v2/']") -eq $null){
        Write-Host "V2 feed not found in $path, adding" -ForegroundColor Yellow
        # Splice in the package source, getting progressively more restrictive in what we add
        if($config.configuration -eq $null) {
            $config.configuration.AppendChild($config.ImportNode($v2.configuration, $true))
        }
        if($config.configuration.packageSources -eq $null){
            $config.configuration.AppendChild($config.ImportNode($v2.configuration.packageSources, $true))
        }
        else{
            $config.configuration.packageSources.AppendChild($config.ImportNode($v2.configuration.packageSources.add, $true))
        }
        
    }
    $config.Save($path)
}

function Invoke-EnsureCodeAnalysisIgnoresVersion
{
    param
    (
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("10.0", "11.0", ignoreCase=$true)]
        [string]$Version
    )

    $path = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio $Version\Team Tools\Static Analysis Tools\FxCop\FxCopCmd.exe.config"
    if(Test-Path $path){
        $config = [xml](Get-Content $path)
        $config.PreserveWhitespace = $true

        $node = $config.SelectSingleNode('//appSettings/add[@key="AssemblyReferenceResolveMode"]')
        if($node -and $node.value -ne 'StrongNameIgnoringVersion'){
            Write-Host "Updating FXCop config to work with assembly redirects for old versions" -ForegroundColor Yellow
            $node.value = 'StrongNameIgnoringVersion'
            $config.Save($path)
        }
    }    
}

Export-ModuleMember Invoke-Build
Export-ModuleMember Invoke-EnsureNugetV2Feed