$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if(-not($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
  Write-Host "Error: This script needs to run as Admin." -ForegroundColor red -BackgroundColor Black
  exit
}

if($host.name -match 'ISE'){
  Write-Host "Error: This script cant be run from inside Powershell  ISE." -ForegroundColor red -BackgroundColor Black
  exit
}



if(-not(get-command choco -ErrorAction SilentlyContinue)){
  write-host "Installing chocolatey..." -ForegroundColor Green
  Set-ExecutionPolicy Bypass -Scope Process -Force; 
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco install baregrep
choco install baretail
#choco install cmder
choco install ditto
choco install echoargs
choco install graphviz
choco install linqpad5
choco install NugetPackageExplorer
choco install plantuml
choco install terminus
