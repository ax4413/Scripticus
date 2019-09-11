#Clear-Host

$script = Join-Path $PSScriptRoot -ChildPath 'Azure-Key-Vault-Functions.ps1'
. $script
$script = Join-Path $PSScriptRoot -ChildPath 'convertto-yaml.ps1'
. $script

$kv  = 'KVICECLOUDPR'
$key = 'PRBA-IDSClient*'


# Get-KeyVaultSecret -Vault $kv -Key $key -IncludeVersions:$true | ConvertTo-yaml

Get-KeyVaultSecret -Vault $kv -Key $key `
| Select-Object @{Name = 'KeyName'; Expression = {$_.Name} } -ExpandProperty Secret `
| Sort-Object @{Expression = 'KeyName'; Descending = $true}, @{Expression = 'Created'; Descending = $true} `
| Select-Object KeyName, Created, Secret


# Get-AzureKeyVaultSecret -VaultName $kv | ? Name -Like $key | % { Undo-AzureKeyVaultSecretRemoval -VaultName $kv -Name $_.name }


# Remove-AzureKeyVaultSecret -VaultName KVICECLOUDNP -InRemovedState -name ETTELSIT1-IDSCLIENT-client-cred

## Update lots of secrets
# Update-KeyVaultSecret -VaultName $kv -KeyName $key -keysToExclude 'ETAMSIT1*', 'ETTELSIT1*'


## update a single secret optionally pass in a new password
# Update-KeyVaultSecret -VaultName $kv -KeyName $key


#Get-KeyVaultSecret -Vault $kv -Name  "$key*" -IncludeVersions | Format-Table -AutoSize