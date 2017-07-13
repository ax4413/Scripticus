

# set params

$TeamCityBuildNumber = "3.11.784.114"

$dir = '\\664723-steam1\c$\Icenet.PowerShell.Modules'


write-host "Applying version number '$TeamCityBuildNumber' to all manifest files..."
Get-ChildItem -Path $dir -Filter '*.psd1' -Recurse | 
ForEach-Object{
    $file = $_.FullName
    (Get-Content $file).replace("ModuleVersion = '0.0.0.0'", "ModuleVersion = '$TeamCityBuildNumber'") | 
    Set-Content $file
}