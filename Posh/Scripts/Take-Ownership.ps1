
# ##############################################################################################
# Take ownership and grant permissions recursivly
# special thanks goes to the work carried out here:
# https://gallery.technet.microsoft.com/scriptcenter/Take-Ownership-and-Grant-4228de8f
# ##############################################################################################


function Take-FullControl { 
    param( $item, [String]$domain, [String]$user, [switch]$takeOwnership ) 

    $error.clear() 

    $itemPath = $item.FullName
    write-host "`r`nProcessing '$itemPath'..." -Fore Yellow 

    if($takeOwnership){
        Write-Verbose "Calling takeown.exe..."
        $LASTEXITCODE = 0
        # execute the cmd but capture the output
        $message = (takeown.exe /A /F $itemPath ) | Out-String

        Write-Host ($message.Trim()) -ForegroundColor Gray

        if($LASTEXITCODE -ne 0){
            Write-Error "takeown.exe /A /F $itemPath failed"
        }
    }

    $CurrentACL = Get-Acl $itemPath    
    
    if( ( $item -is [System.IO.DirectoryInfo]) -like $true ) { 
        $AdminACLPermission = "$domain\$user","FullControl","ContainerInherit,ObjectInherit","None","Allow"
    } elseif( ( $item -is [System.IO.FileInfo]) -like $true ) {
        $AdminACLPermission = "$domain\$user","FullControl","Allow"
    } else { 
        Write-Error "Invalid type supplied $item"
    } 
    
  
    $SystemAccessRule = new-object System.Security.AccessControl.FileSystemAccessRule $AdminACLPermission 
    $CurrentACL.AddAccessRule($SystemAccessRule)  
    
    Write-Verbose "Calling Set-Acl -Path $itemPath -AclObject $CurrentACL ..." 
    Set-Acl -Path $itemPath -AclObject $CurrentACL 
    Write-Host "SUCCESS: Permisions set to Fullcontrol" -ForegroundColor Gray

    if($error -ne $null) { 
        Write-Error "Take ownership /access operation failed for $itemPath" -foregroundcolor Red 
    } else { 
        $Acl        = get-acl $itemPath
        $UserAccess = New-Object System.Security.Principal.NTAccount("$domain", "$User") 

        $ACL.SetOwner($UserAccess) 
        Write-Verbose "Set-Acl -Path $itemPath -AclObject $Acl "
        Set-Acl -Path $itemPath -AclObject $Acl 
        Write-host "SUCCESS: New Owner set" -foregroundcolor Gray 
    } 

    $error.clear() 
} 


function Recursivley-TakeFullControl { 
    param( [string]$Path, [String]$domain, [String]$user, [switch]$takeOwnership ) 

    write-host " "
    Write-Host $("".Padright(60, '=')) -ForegroundColor Green
    Write-Host "Setting access rights recursively" -ForegroundColor Green
    Write-Host $("".PadLeft(60, '=')) -ForegroundColor Green

    Write-Host "Path To Process = $Path" -ForegroundColor Gray
    Write-Host "User name       = $domain\$User" -ForegroundColor Gray
    Write-Host "Take Ownership  = $takeOwnership" -ForegroundColor Gray
    

    if(Test-Path $Path){
        if((Get-ChildItem $Path).count -gt 0){    
            Get-ChildItem $Path -Recurse | 
                ForEach-Object { Take-FullControl -item $_ -domain $domain -user $User -takeOwnership:$takeOwnership }
        } else {
            Write-Error "The folder $Path contains no children"
        }
    } else {
        Write-Error "The path $Path does not exist"
    }
}


function Fix-FileSystem
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
        $path,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateSet("Administrators", "Everyone")]
        $mode
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            if($mode -eq "Administrators"){
                $domain = "BUILTIN"
                $User   = "Everyone"
            } 
            
            if($mode -eq "Everyone"){
                $domain = ""
                $User   = "Everyone"
            }

	        $logs     =  Join-Path "D:\Logs" "file_system_permissions_$(get-date -format 'yyyyMMddHHmmss')_.log" 

	        Start-Transcript -Path $logs 
	        Recursivley-TakeFullControl -Path $path -domain $domain -user $User -takeOwnership
	        Stop-Transcript
	        write-host "`r`nA full transcript can be found here $logs"
        }
    }
    End
    {
    }
}


# ##############################################################################################

# $RootPath = "F:\VAN\SYTrunk\Rescheduling Service\Service"  
# Fix-FileSystem -path $RootPath -mode Administrators