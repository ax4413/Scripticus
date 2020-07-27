function Get-KeyVaultSecret
{
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $Vault, 
        [Parameter(Mandatory=$true, Position=1)]        
        $Key, 
        [Parameter(Mandatory=$false, Position=2)]        
        [switch]$IncludeVersions
    )

    $items = Get-AzureKeyVaultSecret -VaultName $Vault | 
             Where-Object Name -Like $Key | 
             Sort-Object Name 
    
    $result = @()

    foreach($item in $items){
        $history = Get-AzureKeyVaultSecret -VaultName $Vault -Name $item.Name -IncludeVersions:$IncludeVersions | Sort -Descending Created

        $obj = New-Object -TypeName PSObject |
               Add-Member –MemberType NoteProperty –Name Name    –Value $item.Name -PassThru |
               Add-Member –MemberType NoteProperty –Name Enabled –Value $item.Enabled -PassThru |
               Add-Member –MemberType NoteProperty –Name Created –Value $item.Created -PassThru |
               Add-Member –MemberType NoteProperty –Name Secret  –Value @() -PassThru

        foreach($item in $history){
            $secret = (Get-AzureKeyVaultSecret -VaultName $Vault -Name $item.Name -Version $item.Version).SecretValueText
            $hash   = ConvertTo-Base64Sha256($secret)

            $obj.Secret += New-Object -TypeName PSObject |
                           Add-Member –MemberType NoteProperty –Name Secret  –Value $secret -PassThru |
                           Add-Member –MemberType NoteProperty –Name Hash    –Value $hash -PassThru |
                           Add-Member –MemberType NoteProperty –Name Created –Value $item.Created -PassThru
        }
                
        $result +=$obj
    }
    return $result
}


function ConvertTo-Base64Sha256($value){
    $enc   = [system.Text.Encoding]::UTF8
    $bytes = $enc.GetBytes($value);    
    $sha   = [System.Security.Cryptography.SHA256]::Create()
    $hash  = $sha.ComputeHash($bytes)

    $sha.Dispose()

    return [System.Convert]::ToBase64String($hash);
}


function New-Secret {
	[CmdletBinding()]
	param (
		[int] $length = 10,
		[int] $numberOfNonAlphanumericCharacters = 0
	)

	begin {
		$null = [Reflection.Assembly]::LoadWithPartialName("System.Web")
	}

	process {
		Write-Verbose "Generating secret of length $length with minimum of $numberOfNonAlphanumericCharacters special characters"
		return [system.web.security.membership]::GeneratePassword($length, $numberOfNonAlphanumericCharacters)
	}
}

function New-Password($Length) {
	$str = ''
	while ($str.Length -lt $Length) {
		$str += (New-Secret -length 100 -numberOfNonAlphanumericCharacters 0) -replace '[^a-zA-Z0-9]', ''
	}
	return $str.SubString(0, $Length)
}


function Update-KeyVaultSecrets
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $VaultName,

        # key name accepts wild cards
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $KeyName,

        # key name accepts wild cards
        [Parameter(Position=2, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        $keysToExclude = @(),

        [switch]$TestMode
    )
    Process
    {
        $keys = Get-AzureKeyVaultSecret -VaultName $VaultName | Where-Object Name -Like $KeyName

        if($keysToExclude -and $keysToExclude.count -gt 0 ){ 
            $keys = $keys | Where-Object Name -NotMatch ($keysToExclude -join '|')
        }

        $lastKey = ''

        Write-Host "Updating secrets for $KeyName - $($keys.Count) keys found..."

        $sortedKeys = $keys | Sort-Object Name

        foreach($k in $sortedKeys) {
            $tenant = Get-TenantNameFromKey -KeyName $k.Name
            if(!$lastKey.StartsWith($tenant)) {
                # purely formating if we are dealing with many tenants 
                write-host " "
            }
            
            $password = New-Password -Length 30
            $secret = $password | ConvertTo-SecureString -AsPlainText -Force
            write-host ("Setting {0,-23} => {1}" -f $k.Name, $password) -ForegroundColor Yellow

            if(!$TestMode){
                $null = Set-AzureKeyVaultSecret -VaultName $kv -Name $k.Name  -SecretValue $secret
            }

            $lastKey = $k.Name
        }

        Write-Host "`r`nDone" -ForegroundColor Green
    }
 
}

function Get-TenantNameFromKey($KeyName){
    $tenant = $KeyName
    $tenant = $tenant -replace 'APPUSER', '' 
    $tenant = $tenant -replace 'IWEBUSER', ''
    $tenant = $tenant -replace 'PUBWEBUSER', ''
    $tenant = $tenant -replace 'PVTWEBUSER' , ''
    $tenant = $tenant -replace 'SRVCSUSER',''
    $tenant = $tenant -replace 'SSIUSER',''
    $tenant = $tenant -replace 'SSRUSER',''
    $tenant = ($tenant -split '-')[0]
    return $tenant
}

function Update-KeyVaultSecret
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $VaultName,

        # key name accepts wild cards
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $KeyName,

        [Parameter(Position=2, Mandatory=$false)]
        $NewPassword,

        [switch]$TestMode
    )
    Process
    {
        $keys = @(Get-AzureKeyVaultSecret -VaultName $VaultName | Where-Object Name -Like $KeyName)

        if($keys.Count -gt 1){ Write-Error "Too many keys found for $KeyName" }

        $key = $keys[0]        
            
        write-host "Updating Key: $($key.Name)..." -ForegroundColor Yellow

        if($NewPassword){
            $password = $NewPassword
        } else {
            $password = New-Password -Length 30
        }
        
        $secret = $password | ConvertTo-SecureString -AsPlainText -Force
        
        write-host "New Password: $password" -ForegroundColor Yellow

        if(!$TestMode){
            $null = Set-AzureKeyVaultSecret -VaultName $kv -Name $key.Name  -SecretValue $secret
        }        

        Write-Host "Key Updated" -ForegroundColor Green
    }
 
}

function Reset-Credentials(){
    $credential = $null
}


Write-Host "Initializing $($MyInvocation.MyCommand.Name)..."

Import-Module AzureRM.profile | Out-Null

if(!$credential){ 
  Write-Host 'Connecting...'
  $credential = Get-Credential -UserName 'syeadon@icecloudnp.onmicrosoft.com' -Message "Please provide the password for '$userName'"
  $x = Connect-AzureRmAccount -Credential $credential
  if($x){ 
    Write-Host 'Connected' -ForegroundColor Green 
  } else {
    Write-Host 'Failed to connect' -ForegroundColor Red
    Reset-Credentials
    Exit
  }
}
Write-Host ' '