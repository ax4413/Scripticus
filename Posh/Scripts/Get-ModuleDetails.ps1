param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

$modules = Get-Module $ModuleName -All

$modules | Format-List

$modules | ForEach-Object { $_.ExportedFunctions }