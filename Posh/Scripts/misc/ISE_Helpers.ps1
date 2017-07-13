
#Function psedit {
#  param(
#    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$filenames)
#
#  foreach ($filename in $filenames) {
#    dir $filename | where {!$_.PSIsContainer} | %{
#        $psISE.CurrentPowerShellTab.Files.Add($_.FullName) > $null
#    }
#  }
#}


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

Set-Alias -Name 'reload' -Value 'Restart-PowerShell'

$parentProcessId = (Get-WmiObject Win32_Process -Filter "ProcessId=$PID").ParentProcessId
$parentProcessName = (Get-WmiObject Win32_Process -Filter "ProcessId=$parentProcessId").ProcessName

if ($host.Name -eq 'ConsoleHost') {
    if (-not($parentProcessName -eq 'powershell.exe')) {
        Invoke-PowerShell
    }
}

