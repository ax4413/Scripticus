<#
.Synopsis
   Find out what is holding on to a file
.EXAMPLE
   Get-Handle -fileName 'notepad.exe' `
     | Select-Object -ExpandProperty PID `
     | Invoke-Taskkill
#>
function Get-Handle {
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [ValidateNotNullOrEmpty()] 
    $Resource
  )

  handle $Resource `
    | Select-String -Pattern "([^\s-]*)\s*pid:\s*(\d*)\s*type:\s*.*?:\s*(.*)" -AllMatches `
    | ForEach-Object{ $_.Matches | % { [PSCustomObject]@{ 'Process'= $_.Groups[1];
                                                          'PID'    = $_.Groups[2];
                                                          'File'   = $_.Groups[3]; } } }
}

<#
.Synopsis
   kill a given process
.EXAMPLE
   Invoke-Taskkill -pid 1234
.EXAMPLE
   Get-Handle -Resource 'notepad.exe' `
     | Select-Object -ExpandProperty PID `
     | Invoke-Taskkill
#>
function Invoke-KillTask{
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
    [ValidateNotNullOrEmpty()] 
    [Alias('pid')]
    $ProcessId
  )
  Taskkill /pid $ProcessId /f
}

<#
.Synopsis
   kill a given process
.EXAMPLE
   u -pid Grapple
#>
function Unlock-Resource {
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [ValidateNotNullOrEmpty()] 
    $Resource
  )
  
  Get-Handle -fileName $Resource `
     | Select-Object -ExpandProperty PID `
     | Invoke-Taskkill
}  
