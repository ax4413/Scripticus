 

Get-Module | 
ForEach-Object { 
    if(($_.Name).ToUpper().StartsWith('ICENET.')) { 
        Remove-Module ($_.Name) 
        Write-Host "$($_.Name) Removed"
    } 
}