
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

# alias functions
Set-Alias -Name 'reload' -Value 'Restart-PowerShell'


# THIS MUST EXIST AT THE END OF TEH PROFILE FOR TEHSE FUNCTIONS TO WORK #
# $parentProcessId = (Get-WmiObject Win32_Process -Filter "ProcessId=$PID").ParentProcessId
# $parentProcessName = (Get-WmiObject Win32_Process -Filter "ProcessId=$parentProcessId").ProcessName

# if ($host.Name -eq 'ConsoleHost') {
#     if (-not($parentProcessName -eq 'powershell.exe')) {
#         Invoke-PowerShell
#     }
# }