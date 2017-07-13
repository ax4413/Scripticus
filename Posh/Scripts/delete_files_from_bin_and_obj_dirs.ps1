param(
    [string]   $Location    = 'D:\VAP\014\SY\Identity Server', 
    [string[]] $deletFilter = ("bin","obj","bld","Backup","_UpgradeReport_Files","Debug","Release,ipch","*.mdf","*.ldf","*.suo","Packages","bower_components","node_modules","lib",".vs","artifacts"),
    [bool]     $TestMode    = $false,
    [switch]   $verbose     = $true
)

if(!$Location) { $Location = Get-Location }


Get-ChildItem $Location -include $deletFilter -Recurse -Force  | ForEach-Object { $files = @() } { $files += Get-ChildItem $_ -Recurse -File -force }

# remove duplicates
$files = $files | Sort-Object -Property $_.Fullname -Unique

$size = ($files | Measure-Object -property length -sum).Sum

$FolderSize = "{0:N2}" -f ($size / 1MB) + ' MB'

if($TestMode) { 
    Write-Host "`r`n`r`n=================== TEST MODE - NO FILES WILL BE DELETED ===================`r`n" 
} else { 
    Write-Host "`r`n`r`n===================== LIVE MODE - FILES WILL BE DELETED ====================`r`n" 
}
Write-Host "Deleting "    -NoNewline
Write-Host $FolderSize    -NoNewline -ForegroundColor Red
Write-Host " from under " -NoNewline
Write-Host $location      -NoNewline -ForegroundColor Green
Write-Host " ...`r`n"


$folder = ''

$files | % {
    $file = $_.FullName
    if($verbose)   { 
        if($folder -ne ($_.DirectoryName)){
            $folder = $_.DirectoryName
            Write-Host " - $folder"  
        }
        Write-Host "   - $file" -ForegroundColor Gray       
    }

    if(!$TestMode) { Remove-Item $file -Force }
}
Write-Host "`r`n============================================================================`r`n"