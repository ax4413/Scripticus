Clear-Host

$script = Join-Path $PSScriptRoot -ChildPath 'Azure-Key-Vault-Functions.ps1'
. $script

$kv  = 'KVICECLOUDNP'
$key = 'ITVFQA1'

Get-KeyVaultSecret -keyVault $kv -KeyName  "$key*" -IncludeVersions | Format-Table -AutoSize


# Get-AzureKeyVaultSecret -VaultName $kv | ? Name -Like $key | % { Undo-AzureKeyVaultSecretRemoval -VaultName $kv -Name $_.name }


# Remove-AzureKeyVaultSecret -VaultName KVICECLOUDNP -InRemovedState -name ETTELSIT1-IDSCLIENT-client-cred


# Update-KeyVaultSecrets -VaultName $kv -KeyName $key -keysToExclude 'ETAMSIT1*', 'ETTELSIT1*'


