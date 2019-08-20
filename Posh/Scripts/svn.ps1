

function Invoke-SvnRevert($dir){
  Get-ChildItem -Path $dir -Filter '.svn' -Recurse -Directory -Force | 
  Get-Item -Force | 
  Where-Object FullName -NotMatch ".*Icenet.Common\\IceNgCommon\\ManagementConsoleAssets" |
  Select-Object @{Name='Repo'; ex={$_.Parent.FullName}} |
  Select-Object -ExpandProperty Repo |
  ForEach-Object { 
      Push-Location $_
      write-host "Reverting $(pwd)" -ForegroundColor Yellow
      Invoke-Expression "svn revert --depth=infinity ." 
      if($LASTEXITCODE -eq 0) { 
        Write-Host "Done`r`n" -ForegroundColor Green 
      } else { 
        Write-Host "There seems to have been a problem`r`n" -ForegroundColor Red 
      }
      Pop-Location
  }
}


<#
.Synopsis
   Get-SvnLogs
.EXAMPLE
   Get-SvnLogs -url 'https://svn-nostrum/svn/Icenet.Service.Audit/Branches/15' | ? msg -match '.*\s\D foo'
.EXAMPLE
   Get-SvnLogs -url 'https://svn-nostrum/svn/Icenet.Service.Audit/Branches/15' | ? author -like '*yeadon*'
#>
function Get-SvnLogs($url){
  ([xml](Invoke-Expression "svn log $url --xml --verbose")).SelectNodes('//logentry')
}
