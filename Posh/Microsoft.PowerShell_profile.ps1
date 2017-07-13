# Makes our command prompt look pretty
function Prompt() {
  write-host $(get-location) -ForegroundColor Green
  "PS>"
}

function touch($path){
  new-item -path $path -type File
}

function Clear-SpecFlowCache(){
  Remove-Item $env:TEMP\specflow*.cache
}

function Invoke-PowerShell {
  powershell -nologo
  Invoke-PowerShell
}

function Restart-PowerShell {
    if ($host.Name -eq 'ConsoleHost') {
        exit
    }
    Write-Warning 'Only usable while in the PowerShell console host'
}




# load scripts from teh script dir
$PoshScriptsDir = join-path $env:USERPROFILE '.\Documents\WindowsPowerShell\Scripts'
# load all scripts ## Get-ChildItem "${PoshScriptsDir}\*.ps1" | % {.$_} 
# load some scripts
$scripts = @('downloader/Get-Download.ps1', 'Clear-SpecFlowCache')
$scripts | % { . $(Join-Path $PoshScriptsDir $_) } 





# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}




# alias functions
Set-Alias -Name 'reload' -Value 'Restart-PowerShell'




# LEAVE THIS AT THE END OF TEH PROFILE #
##    IT IS USED BY THE RELOAD CALL   ##
$parentProcessId = (Get-WmiObject Win32_Process -Filter "ProcessId=$PID").ParentProcessId
$parentProcessName = (Get-WmiObject Win32_Process -Filter "ProcessId=$parentProcessId").ProcessName

if ($host.Name -eq 'ConsoleHost') {
    if (-not($parentProcessName -eq 'powershell.exe')) {
        Invoke-PowerShell
    }
}