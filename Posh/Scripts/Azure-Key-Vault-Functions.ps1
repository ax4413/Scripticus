function Get-KeyVaultSecret
{
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $Vault, 
        [Parameter(Mandatory=$true, Position=1)]        
        $Key, 
        [Parameter(Mandatory=$true, Position=2)]        
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


Function New-Password {
  Param(
      [Parameter(Mandatory=$False)][Int] $Length = 16,
      [Parameter(Mandatory=$False)][Int] $MinimumNumberOfNumbers = 3,
      [Parameter(Mandatory=$False)][Int] $MaximumNumberOfNumbers,
      [Parameter(Mandatory=$False)][Int] $MinimumNumberOfSpecialCharacters = 3,
      [Parameter(Mandatory=$False)][Int] $MaximumNumberOfSpecialCharacters,
      [Parameter(Mandatory=$False)][switch] $NoSpecialCharacters
  )

  if(-not $MaximumNumberOfNumbers -and $MaximumNumberOfNumbers -lt 1){ 
      $MaximumNumberOfNumbers = $MinimumNumberOfNumbers * 2 
  }

  if(-not $MaximumNumberOfSpecialCharacters -and $MaximumNumberOfSpecialCharacters -lt 1){ 
      $MaximumNumberOfSpecialCharacters = $minimumNumberOfSpecialCharacters * 2 
  }

  $numbers      = @([char[]](48..57))
  $uppercase    = @([char[]](65..90))
  $lowercase    = @([char[]](97..122))
  $illegalChars = @([char[]]([int][char]'^',[int][char]'|',[int][char]'$', [int][char]',', [int][char]'"', [int][char]'`', [int][char]'''', [int][char]'='))
  $specialChars = @([char[]](33..126)) | ? {  $illegalChars -notcontains $_  -and $numbers -notcontains $_ -and $uppercase -notcontains $_ -and $lowercase -notcontains $_ }
  
  $specialCharCount = 0
  $numberCount      = 0
  $uppercaseCount   = 0
  $lowercaseCount   = 0

  $chars = @()
  foreach($i in 1..$Length){
      $random = Get-Random
      $index  = 0
      $char   = ''
      $type   = ''
      if($random % 9 -eq 0 -and $specialCharCount -le $MaximumNumberOfSpecialCharacters){
          $type  = 'SP'
          $index = (Get-Random -Minimum 0 -Maximum ($specialChars.Length - 1))
          $char  = $specialChars[$index]          
          $specialCharCount ++          
      }
      elseif($random % 6 -eq 0 -and $numberCount -le $MaximumNumberOfNumbers){
          $type  = 'NB'
          $index = (Get-Random -Minimum 0 -Maximum ($numbers.Length - 1))
          $char  = $numbers[$index]
          $numberCount ++
      }
      elseif($random % 2 -eq 0) {
          $type  = 'UP'
          $index = (Get-Random -Minimum 0 -Maximum ($uppercase.Length - 1))
          $char  = $uppercase[$index]
          $uppercaseCount ++
      }
      else {
        $type  = 'LW'
          $index = (Get-Random -Minimum 0 -Maximum ($lowercase.Length - 1))
          $char  = $lowercase[$index]
          $lowercaseCount ++
      }

      $chars += $char
      Write-Debug "$type - '$i' = '$index' = '$char'"
  }

  while($specialCharCount -lt $MinimumNumberOfSpecialCharacters){
      $replacementIndex = (Get-Random -Minimum 0 -Maximum ($specialChars.Length - 1))
      $replacementChar  = $specialChars[$replacementIndex]
      
      $index = (Get-Random -Minimum 0 -Maximum ($chars.Length - 1))
      $oldChar = $chars[$index]
    
      if($specialChars -contains $oldChar) { continue }
      
      Write-Debug "Replacing item '$index, $oldChar' with '$replacementChar'"

      $chars[$index] = $replacementChar
      $specialCharCount ++
  }
  
  while($numberCount -lt $MinimumNumberOfNumbers){
      $replacementIndex = (Get-Random -Minimum 0 -Maximum ($numbers.Length - 1))
      $replacementChar  = $numbers[$replacementIndex]
      
      $index = (Get-Random -Minimum 0 -Maximum ($chars.Length - 1))
      $oldChar = $chars[$index]

      if($numbers -contains $oldChar) { continue }

      Write-Debug "Replacing item '$index, $oldChar' with '$replacementChar'"

      $chars[$index] = $replacementChar
      $numberCount ++
  }

  if($NoSpecialCharacters){
        Write-Debug "No special chars allowed"
        $i = 0
        $validChars = $lowercase + $numbers + $uppercase
        while($i -le $chars.Length-1){
            if($validChars -notcontains $chars[$i]){
                $j = Get-Random -Minimum 0 -Maximum ($validChars.Length-1)
                Write-Debug "Replacing item '$i, $($chars[$i])' with '$($validChars[$j])'"
                $chars[$i] = $validChars[$j] 
            }
            $i++
        }
  }

  return $chars -join ''
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

        Write-Host "Processing $($keys.Count)..."

        $keys | 
        Sort-Object Name |
        ForEach-Object {
            $tenant = $_.Name -replace 'APPUSER', '' -replace 'IWEBUSER', '' -replace 'PUBWEBUSER', '' -replace 'PVTWEBUSER' , '' -replace 'SRVCSUSER','' -replace 'SSIUSER','' -replace 'SSRUSER',''
            if(!$lastKey.StartsWith($tenant)) { write-host " "}
            
            $password = New-Password -Length 30 -MinimumNumberOfNumbers 9 -NoSpecialCharacters 
            $secret = $password | ConvertTo-SecureString -AsPlainText -Force
            write-host ("Setting {0,-23} => {1}" -f $_.Name, $password) -ForegroundColor Yellow

            if(!$TestMode){
                $null = Set-AzureKeyVaultSecret -VaultName $kv -Name $_.Name  -SecretValue $secret
            }

            $lastKey = $_.Name
        }

        Write-Host "`r`nDone" -ForegroundColor Green
    }
 
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
            $password = New-Password -Length 30 -MinimumNumberOfNumbers 9 -NoSpecialCharacters 
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
  }
}
Write-Host ' '