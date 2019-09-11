# Set the location where we should look for our script files
$PoshScriptsDir = join-path $env:USERPROFILE '.\Documents\WindowsPowerShell\Scripts'




# Usefull console functions    #################################################
# Makes our command prompt look pretty
function Prompt() {
  write-host $(get-location) -ForegroundColor Green
  "PS>"
}

# kind of alias new-item
function touch($path){
  new-item -path $path -type File
}




# load scripts    ##############################################################
# load all scripts ## Get-ChildItem "${PoshScriptsDir}\*.ps1" | % {.$_} 
$scripts = @('downloader/Get-Download.ps1'
           , 'Clear-SpecFlowCache.ps1'
           , 'Web-Functions.ps1'
           , 'Restart-Powershell.ps1'
		   , 'File-Access.ps1')
$scripts | % { . $(Join-Path $PoshScriptsDir $_) } 




# load the Chocolatey profile    ###############################################
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}




# THIS NEEDS TO STAY AT THEN END OF TEH PROFILE, IT IS USED BY THE RELOAD FUNC #
$parentProcessId = (Get-WmiObject Win32_Process -Filter "ProcessId=$PID").ParentProcessId
$parentProcessName = (Get-WmiObject Win32_Process -Filter "ProcessId=$parentProcessId").ProcessName

if ($host.Name -eq 'ConsoleHost') {
    if (-not($parentProcessName -eq 'powershell.exe')) {
        Invoke-PowerShell
    }
}