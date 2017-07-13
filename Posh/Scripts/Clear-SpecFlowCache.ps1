
function Clear-SpecFlowCache(){
    Write-Host "`r`n== Cache files in the %TEMP% dir ======================"
    ls $env:TEMP -Filter 'specflow*.cache'
    Write-Host "=======================================================`r`n"

    Remove-Item $env:TEMP\specflow*.cache

    Write-Host "== Cache files left in the %TEMP% dir ================="
    ls $env:TEMP -Filter '*.cache'
    Write-Host "=======================================================`r`n"
}