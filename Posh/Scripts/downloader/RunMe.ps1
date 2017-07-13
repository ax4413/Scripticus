
$poshDir              = [System.IO.Path]::GetDirectoryName($profile)
$scriptsDir           = Join-Path $poshDir "Scripts"
$download_script      = Join-Path $scriptsDir "Get-Download.ps1"
$temp_download_script = Join-Path $PSScriptRoot "Get-Download.ps1"

Write-Host "`r`nSetting up the Get-Download func"

# copy the download script to your profile dir
if(-not (Test-Path $scriptsDir)){
    $null = New-Item $scriptsDir -ItemType directory -Force
    Write-Host "  - Created script dir $scriptsDir"
}
if(-not (Test-Path $download_script)){
    $null = Copy-Item -Path $temp_download_script -Destination $download_script -Force
    Write-Host "  - Copied Get-Download.ps1 to $download_script"
}

# create profile if necessary and apend Get-Download func initialization
if(-not (Test-Path $profile)){
    $null = New-Item $profile -ItemType file -Force
    Write-Host "  - Created you a profile $profile"
}

Add-Content $profile -Value @"
`n
# location of posh scripts
`$PoshScriptsDir = join-path '$env:USERPROFILE' '.\Documents\WindowsPowerShell\Scripts'

# load all scripts in teh scripts dir
Get-ChildItem "`${PoshScriptsDir}\*.ps1" | % {.`$_} 
"@

Write-Host "The Get-Download function is now available and can be invoked with dl." -ForegroundColor Green
Write-Host "Please resart this shell to use." -ForegroundColor Green
Write-Host "For usage details Get-Help Get-Download -ShowWindow" -ForegroundColor Green