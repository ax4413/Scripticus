[CmdletBinding(
                PositionalBinding=$false,
                ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()] 
    [string]$RootPath,
    [switch]$NoCheckout,
    [switch]$NoWeb,
    [switch]$NoBuild,
    [switch]$NoRepoint
)

Import-Module WebAdministration

$modules = "IISUtils.psm1", "IOUtils.psm1", "VSUtils.psm1", "BuildUtils.psm1"
$modules | % { Join-Path $PSScriptRoot $_ | Import-Module }

$info = @{ "ForegroundColor" = "Yellow" }

$checkout = -not $NoCheckout
$createWeb = -not $NoWeb
$build = -not $NoBuild
$repoint = -not $NoRepoint

$dummyRoot   = Join-Path $RootPath "DummyRoot"

$lhsName = "GreenDealLhs"
$lhsAddress = "lhs.green.local"

$rhsName = "GreenDealRhs"
$rhsAddress = "rhs.green.local"


## Create folder hierarchy
Invoke-EnsureFolderExists -Path $RootPath
Invoke-EnsureFolderExists -Path $dummyRoot

if($checkout)
{
    Write-Host @info "Checking out to $RootPath"
    svn checkout https://svn-nostrum/svn/Icenet-GDFC/trunk $RootPath
    if($LASTEXITCODE -ne 0){
        $error = New-Object System.Management.Automation.ErrorRecord -ArgumentList (New-Object System.Exception), "Error Checking out RHS to $RootPath"
        $PSCmdlet.ThrowTerminatingError($error)
    }
    Write-Host @info "Done!"
}

if($createWeb){
    ## Set up websites

    Write-Host @info "Setting up $lhsName AppPool"
    if (!(Get-AppPoolPath $lhsName | Test-Path)){ New-WebAppPool $lhsName}

    ## Set up LHS App Pool
    $lhsAppPool =  $lhsName | Get-AppPoolPath | Get-Item
    $lhsAppPool.managedRuntimeVersion = "v4.0"

    $lhsAppPool | Set-Item

    Write-Host @info "Setting up $rhsName AppPool"
    if (!(Get-AppPoolPath $rhsName | Test-Path)){ New-WebAppPool $rhsName}

    ## set up RHS App Pool
    $rhsAppPool = $rhsName | Get-AppPoolPath | Get-Item
    $rhsAppPool.managedRuntimeVersion = "v4.0"
    $rhsAppPool.enable32BitAppOnWin64 = "true"
    ## Not sure if this should be classic mode yet...

    $rhsAppPool | Set-Item

    # LHS Website & Applications
    if(!(Get-SitePath $lhsName | Test-Path)) {
        Write-Host @info "Creating $lhsName LHS Website and Child applications"
        New-Website -Name $lhsName -HostHeader $lhsAddress -PhysicalPath $dummyRoot -ApplicationPool $lhsName

        New-WebApplication -Name "GreenDealAppServerV1.2"      -Site $lhsName -ApplicationPool $lhsName -PhysicalPath "$RootPath\src\Portal\AppServer\Nostrum.GreenDeal.AppServer"
        New-WebApplication -Name "GreenDealWebApiV1.1"         -Site $lhsName -ApplicationPool $lhsName -PhysicalPath "$RootPath\src\Portal\WebApi\Nostrum.GreenDeal.WebApi.V1.1"
        New-WebApplication -Name "Nostrum.GreenDeal.WebPortal" -Site $lhsName -ApplicationPool $lhsName -PhysicalPath "$RootPath\src\Portal\Portal\Nostrum.GreenDeal.WebPortal"

        Set-ItemProperty "IIS:\Sites\$lhsName\GreenDealAppServerV1.2" -name EnabledProtocols -Value "http,net.tcp"
    }

    # RHS Website & Applications
    if(!(Get-SitePath $rhsName | Test-Path)) {
        Write-Host @info "Creating $rhsName RHS Website and Child applications"
        New-Website -Name $rhsName -HostHeader $rhsAddress -PhysicalPath $dummyRoot -ApplicationPool $rhsName

        New-WebApplication -Name "IceNgApp"            -Site $rhsName -ApplicationPool $rhsName -PhysicalPath $RootPath\src\Icenet.App.Services\IceNgApp
        New-WebApplication -Name "Icenet.ServiceLayer" -Site $rhsName -ApplicationPool $rhsName -PhysicalPath $RootPath\src\Icenet.ServiceLayer\Icenet.ServiceLayer
        New-WebApplication -Name "IceNgWeb"            -Site $rhsName -ApplicationPool $rhsName -PhysicalPath $RootPath\src\Icenet.Web\IceNgWeb

        Set-ItemProperty "IIS:\Sites\$rhsName\Icenet.ServiceLayer" -name EnabledProtocols -Value "http,net.tcp"
    }
}

if($build)
{
    # Because jQuery 1.7.2 doesn't appear in the V3 one. Whyyyyyyy?????
    Write-Host "Ensuring a V2 nuget feed is available" -ForegroundColor Yellow
    Invoke-EnsureNugetV2Feed

    Invoke-Build -SolutionFolder "$RootPath\src" -SolutionName 'Icenet - All Projects'
}

if($repoint)
{
    $lhsSettings = @{
        "ProjectRootPath" = "$RootPath\src\Portal";
        "CurrentHost" = "localhost";
        "NewHost" = $lhsAddress
    }

    Write-Host "Repointing LHS Projects to within $lhsAddress"
    Invoke-RepointProject @lhsSettings -ProjectSubPath 'AppServer\Nostrum.GreenDeal.AppServer' -ProjectName 'Nostrum.GreenDeal.AppServer'   -UrlSubPath 'GreenDealAppServerV1.2'
    Invoke-RepointProject @lhsSettings -ProjectSubPath 'WebApi\Nostrum.GreenDeal.WebApi.V1.1'  -ProjectName 'Nostrum.GreenDeal.WebApi.V1.1' -UrlSubPath 'GreenDealWebApiV1.1'
    Invoke-RepointProject @lhsSettings -ProjectSubPath 'Portal\Nostrum.GreenDeal.WebPortal'    -ProjectName 'Nostrum.GreenDeal.WebPortal'   -UrlSubPath 'Nostrum.GreenDeal.WebPortal'

    $rhsSettings = @{
        "ProjectRootPath" = "$RootPath\src";
        "CurrentHost" = "localhost";
        "NewHost" = $rhsAddress
    }

    Write-Host "Repointing RHS Projects to within $rhsAddress"
    Invoke-RepointProject @rhsSettings -ProjectSubPath 'Icenet.App.Services\IceNgApp'            -ProjectName 'IceNgApp'            -UrlSubPath 'IceNgApp'
    Invoke-RepointProject @rhsSettings -ProjectSubPath 'Icenet.ServiceLayer\Icenet.ServiceLayer' -ProjectName 'Icenet.ServiceLayer' -UrlSubPath 'Icenet.ServiceLayer'
    Invoke-RepointProject @rhsSettings -ProjectSubPath 'Icenet.Web\IceNgWeb'                     -ProjectName 'IceNgWeb'            -UrlSubPath 'IceNgWeb'
                                                                                                 
    # Not sure if these should be done, but they're included in Icenet - All Projects.
    # feels like it's probably a good idea, but I don't think they should be added to the websites above. 
    # If they're ever needed, VS will set them up as new applications within the repointed site???
    Invoke-RepointProject @rhsSettings -ProjectSubPath 'Icenet.Web.Services\ConsumerWeb'         -ProjectName 'ConsumerWeb'         -UrlSubPath 'ConsumerWeb'
    Invoke-RepointProject @rhsSettings -ProjectSubPath 'Icenet.Web\IceNgDeploy'                  -ProjectName 'IceNgDeploy'         -UrlSubPath 'IceNgDeploy'
    Invoke-RepointProject @rhsSettings -ProjectSubPath 'Icenet.Test.Services\IceNgTestServices'  -ProjectName 'IceNgTestServices'   -UrlSubPath 'IceNgTestServices'
}