# Downloads every Nuget licience associated with your project
# exec from the pacakage manager in VS
# Thanks Phil Hack http://haacked.com/archive/2015/03/28/download-nuget-package-licenses/


@( Get-Project -All |
   ? { $_.ProjectName } |
   % { Get-Package -ProjectName $_.ProjectName } ) |
   Sort -Unique |
   % { $pkg = $_ ; Try { (New-Object System.Net.WebClient).DownloadFile($pkg.LicenseUrl, 'c:\dev\licenses\' + $pkg.Id + ".txt") } Catch [system.exception] { Write-Host "Could not download license for $pkg.Id" } }
