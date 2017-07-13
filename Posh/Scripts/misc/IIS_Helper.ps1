import-module WebAdministration


<#
    .Synopsis
        Reset the appPool with your new credentials
    .DESCRIPTION
        Reset the appPool with your new credentials
    .EXAMPLE
        Update-AppPoolCredentials - AppPool "foo" -Identity 3 -credential $credential
#>
function Update-AppPoolCredentials(){

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, position=0)]
        [ValidateNotNullOrEmpty()]
        [Management.Automation.PSCredential] $Credential,

        # The app pool we want to modify
        [Parameter(Mandatory=$true, Position=1 )]
        [ValidateNotNullOrEmpty()]
        [string] $AppPool,

        # The website to edit should be absolut i.e. contain IIS
        [Parameter(Mandatory=$true, Position=2 )]
        [ValidateNotNull()]
        [ValidateRange(0,4)]
        [int] $Identity        
    )

    Write-Host " "
    Write-Verbose @"
Updating AppPool...

Current AppPool settings
Name:   $AppPool
User:   $(Get-ItemProperty -Path "IIS:\AppPools\$AppPool" -Name ProcessModel.UserName.Value)
"@
    Write-Host " "

    Set-ItemProperty -Path "IIS:\AppPools\$AppPool" -Name ProcessModel.IdentityType -Value $Identity
    Set-ItemProperty -Path "IIS:\AppPools\$AppPool" -Name ProcessModel.UserName     -Value $Credential.UserName
    Set-ItemProperty -Path "IIS:\AppPools\$AppPool" -Name ProcessModel.password     -Value (Decrypt-secureString $Credential.Password)
    
    Write-Host @"

AppPool Updated
====================================================

"@ -ForegroundColor Green
}


<#
    .Synopsis
        Configure website and application app pool
    .DESCRIPTION
        Set the website app pool and all applications which reside under given $WebSite to execute using the given app pool
    .EXAMPLE
        Set-WebsiteAndApplicationAppPools -Website 'IIS:\Sites\Default Web Site' -AppPool 'foo'
#>
function Set-WebsiteAndApplicationAppPools(){
    [CmdletBinding()]
    Param
    (
        # The website to edit should be absolut i.e. contain IIS
        [Parameter(Mandatory=$true, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [string] $WebSite,

        # The app pool we want everything to run under
        [Parameter(Mandatory=$true, Position=1 )]
        [ValidateNotNullOrEmpty()]
        [string] $AppPool
    )

    Write-Host " "
    Write-Verbose "The following web applications are being configured to use $AppPool for their app pool:"
    Write-Host " "

    $results = @()
    $count   = (Get-ChildItem $WebSite |Where-Object NodeType -eq application | Measure-Object).Count + 1
    $i       = 1

    # set the website to run under your chosen app pool
    Set-ItemProperty $WebSite ApplicationPool $AppPool
    $results += $WebSite
    Write-Progress -Activity "Configuring app pools" -Status "Processing $i / $Count - $WebSite" -PercentComplete ($i / $Count * 100)
    

    # set each of your applications to run under your chosen app pool
    Get-ChildItem $WebSite |
        Where-Object NodeType -eq application |
        Foreach {
            $i ++ 
            Set-ItemProperty -path $("$WebSite\$($_.Name)") -name "ApplicationPool" -value $AppPool 
            Write-Progress -Activity "Configuring app pools" -Status "Processing $i / $Count - $WebSite\$($_.Name)" -PercentComplete ($i / $Count * 100)
            $results += "$WebSite\$($_.Name)"
        }

    $results

    Write-Host @" 

$AppPool is now the default app pool for $i web applications
====================================================

"@ -ForegroundColor Green
}


<#
    .Synopsis
        Set the virtual directories to a given branch
    .DESCRIPTION
        Reset the appPool with your new credentials
    .EXAMPLE
        Update-VirtualDirectoryPaths -WebSite 'IIS:\Sites\Default Web Site' -$PathToIcenet 'D:\Code\Icenet 3' -RelativePathToBranch 'Trunk'
    .EXAMPLE
        Update-VirtualDirectoryPaths -WebSite 'IIS:\Sites\Default Web Site' -$PathToIcenet 'D:\Code\Icenet 3' -RelativePathToBranch 'Btanch\3.7'
#>
function Update-VirtualDirectoryPaths(){

    [CmdletBinding()]
    Param
    (
        # The website we want to modify. should be absolut i.e. contain IIS
        [Parameter(Mandatory=$true, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [string] $WebSite,

        # An absolute path to the icenet folder. i.e. 'D:\Code\IceNet\Icenet 3'
        [Parameter(Mandatory=$true, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ -PathType Container } )]
        [string] $PathToIcenet,

        # The relative path to the branch. i.e. 'Trunk' or 'Branch\3.7'
        [Parameter(Mandatory=$true, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [string] $RelativePathToBranch
    )

    $PathToBranch = Join-Path -Path $PathToIcenet -ChildPath "$RelativePathToBranch\src"

    if(-not(Test-Path -Path $PathToBranch -PathType Container)){
        throw "The path '$PathToBranch' does not exist check the supplied paramaters"
    }
    
    Write-Host " "
    Write-Verbose "Updating the virtual directories of all applications under $website..."
    Write-Host " "

    $hash = @{}

    $vdCount = (Get-ChildItem $WebSite | Where-Object NodeType -eq application | Measure-Object).Count
    $i = 0

    Get-ChildItem $WebSite |
    Where-Object NodeType -eq application |
    ForEach-Object { 
        $virtualDir = Get-ItemProperty -Path "$WebSite\$($_.Name)" -Name physicalPath

        if ($virtualDir.Contains($PathToIcenet)){
            
            $virtualDirArray = $virtualDir -split "\\src\\"
            $tmpVirtualDir   = Join-Path $PathToBranch -childPath $virtualDirArray[1]

            $webApp = $_.Name

            if(-not (Test-Path $tmpVirtualDir)) {    
                 $hash.Add($webApp, "    Bad path $tmpVirtualDir")
            }else{
                if($tmpVirtualDir -ne $virtualDir){
                    Set-ItemProperty "$WebSite\$webApp" -Name physicalPath -Value $tmpVirtualDir
                    $hash.Add($webApp, "    $virtualDir`r`n => $tmpVirtualDir")
                } else {
                    $hash.Add($webApp, "    No action necessary")
                }        
            }
        }
        $i++
        Write-Progress -Activity "Updating virtual directories" -Status "Processing $i / $vdCount - $virtualDir" -PercentComplete ($i / $vdCount * 100)
    }

    $hash | Format-Table -Wrap

        Write-Host @" 

The virtual directories of $WebSite have been repointed
====================================================

"@ -ForegroundColor Green
}


<#
    .SYNOPSIS
        Validates credentials for local or domain user.
         
    .PARAMETER  Username
        The user's username.
     
    .PARAMETER  Password
        The user's password.
             
    .PARAMETER  Credential
        A PSCredential object created by Get-Credential. This can be pipelined to Test-UserCredential.
 
    .PARAMETER  Domain
        If this flag is set the user credentials should be a domain user account.
             
    .PARAMETER  UseKerberos
        By default NTLM is used. Specify this switch to attempt kerberos authentication. 
             
        This is only used with the 'Domain' parameter.
             
        You may need to specify domain\user.
     
    .EXAMPLE
        PS C:\> Test-Credential -Username andy -password (Read-Host -AsSecureString)
     
    .EXAMPLE
        PS C:\> Test-Credential -Username 'mydomain\andy' -password (Read-Host -AsSecureString) -domain -UseKerberos
 
    .EXAMPLE
        PS C:\> Test-Credential -Username 'andy' -password (Read-Host -AsSecureString) -domain
             
    .EXAMPLE
        PS C:\> Get-Credential | Test-Credential
     
    .INPUTS
        None.
     
    .OUTPUTS
        System.Boolean.
 
    .LINK
        http://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.principalcontext.aspx
        http://andyarismendi.blogspot.co.uk/2011/08/powershell-test-usercredential.html
     
    .NOTES
        Revision History
            2011-08-21: Andy Arismendi - Created.
            2011-08-22: Andy Arismendi - Add pipelining support for Get-Credential.
            2011-08-22: Andy Arismendi - Add support for NTLM/kerberos switch.    
            2016-09-01  stephen yeadon - Decrypt the credentials secure string
#>
function Test-Credential {
    [CmdletBinding(DefaultParameterSetName = "set1")]
    [OutputType("set1", [System.Boolean])]
    [OutputType("PSCredential", [System.Boolean])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="set1", position=0)]
        [ValidateNotNullOrEmpty()]
        [String] $Username,
 
        [Parameter(Mandatory=$true, ParameterSetName="set1", position=1)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
         
        [Parameter(Mandatory=$true, ParameterSetName="PSCredential", ValueFromPipeline=$true, position=0)]
        [ValidateNotNullOrEmpty()]
        [Management.Automation.PSCredential] $Credential,
         
        [Parameter(position=2)]
        [Switch] $Domain,
         
        [Parameter(position=3)]
        [Switch] $UseKerberos
    )
     
    Begin {
        try { 
            $assemType = 'System.DirectoryServices.AccountManagement'
            $assem = [reflection.assembly]::LoadWithPartialName($assemType) }
        catch { throw 'Failed to load assembly "System.DirectoryServices.AccountManagement". The error was: "{0}".' -f $_ }
         
        $system = Get-WmiObject -Class Win32_ComputerSystem
         
        if (0, 2 -contains $system.DomainRole -and $Domain) {
            throw 'This computer is not a member of a domain.'
        }
    }
     
    Process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'PSCredential' {
                    if ($Domain) {
                        $Username = $Credential.UserName.TrimStart('\')
                    } else {
                        $Username = $Credential.UserName
                    }
                    $PasswordText = Decrypt-SecureString $Credential.Password
                }
                'set1' {
                    # Decrypt secure string.
                    $PasswordText = Decrypt-SecureString $Password
                }
            }
                     
            if ($Domain) {
                $pc = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext 'Domain', $system.Domain
            } else {
                $pc = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext 'Machine', $env:COMPUTERNAME
            }
             
            if ($Domain -and $UseKerberos) {
                return $pc.ValidateCredentials($Username, $PasswordText)
            } else {
                return $pc.ValidateCredentials($Username, $PasswordText, [DirectoryServices.AccountManagement.ContextOptions]::Negotiate)
            }
        } catch {
            throw 'Failed to test user credentials. The error was: "{0}".' -f $_
        } finally {
            Remove-Variable -Name Username -ErrorAction SilentlyContinue
            Remove-Variable -Name Password -ErrorAction SilentlyContinue
        }
    }
}


function Decrypt-SecureString([System.Security.SecureString] $secureString){
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
}

# #################################################################


$WebSite               = 'IIS:\Sites\Default Web Site'
                       
$AppPool               = "IceNetAppPool_V4Integrated"
                       
$PathToIcenet          = 'D:\Code\Icenet 3'
                       
$RelativeBranchPath    = 'Branches\3.12'            <# Trunk | Branches\3.7 #>
                                            
$Identity              = 3                  <# 0 = LocalSystem | 1 = LocalService | 2 = NetworkService | 3 = SpecificUser | 4 = ApplicationPoolIdentity #>

$VerbosePreference     = 'Continue'                   
$ErrorActionPreference = 'Stop'


$credential = Get-Credential -message 'please provide the user you want the app pool to run under' -UserName 'icenet\syeadon'

Clear-Host
Write-Host "===================================================="
Write-Host "    Configuring IIS"
Write-Host "===================================================="
Write-Host ""

if(-not (Test-Credential $credential)){
    Write-Error "The credentails for $($credential.UserName) are incorect or the user does not exist"
}

Update-AppPoolCredentials -AppPool $AppPool -Identity $Identity -Credential $credential

Set-WebsiteAndApplicationAppPools -WebSite $WebSite -AppPool $AppPool

Update-VirtualDirectoryPaths -WebSite $WebSite -PathToIcenet $PathToIcenet -RelativePathToBranch $RelativeBranchPath

# start the app pool
(Get-ItemProperty -Path "IIS:\AppPools\$AppPool").Start()

# test the webpage
$response = Invoke-WebRequest 'http://localhost/icengdeploy/SmartClient.svc/' 

# launch the IIS ui
inetmgr.exe


#is the response empty, null or not a 200
if(!$response -or $response -eq $null -or $response.StatusCode -ne 200){
    # look for errors in the event log
    Get-EventLog -LogName System -EntryType Error -Newest 10 -After (Get-Date).AddMinutes(-15)
}
else{
    Write-Host @"
====================================================    
    yeah.... it all looks good. thx 
====================================================
"@ -ForegroundColor Green
}