clear

## Set these paramaters to search a direcory
$DirtoSearch = "C:\SQLFiles\Backup"
$FileExtension = ".trn"
$DateToCompare = (Get-date).AddDays(-1)
$OutputFile = "c:\temp\test.txt"


Get-ChildItem $DirtoSearch -recurse | 
Where-Object {$_.Extension -eq $FileExtension -and $_.lastwritetime -ge $DateToCompare} | 
Select-Object Name, lastwritetime , @{Name="GB";Expression={"{0:N2}" -f ($_.Length / 1GB)}} |
Sort-Object Name -descending | 
# Format the table and print to file
#Format-Table -Property * -AutoSize | 
#Out-String -Width 4096 | 
#Out-File $OutputFile
