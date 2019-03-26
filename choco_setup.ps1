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


### terminals ########################
choco install terminus
#choco install cmder


### utilities #########################
choco install baregrep
choco install baretail
choco install ditto
choco install echoargs


### dev tools ##########################
choco install git
choco install vscode
choco install visualstudio2017community
choco install linqpad5
choco install NugetPackageExplorer



# choco install graphviz
# choco install plantuml

