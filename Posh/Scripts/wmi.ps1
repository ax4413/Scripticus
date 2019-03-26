##  list all wmi classes 
Get-WmiObject -List | Sort-Object name

Select-XML  $env:windir\System32\WindowsPowerShell\v1.0\types.ps1xml -Xpath /Types/Type/Name |
ForEach-Object { $_.Node.innerXML } | 
Where-Object { $_ -like '*#root*' } |
ForEach-Object { $_.Split('\')[-1] } | 
Sort-Object




# get ad account SID for 
Get-WmiObject -Query "select SID from Win32_UserAccount where name='SVC-TSMSSQL'"

Get-WmiObject -Query "select * from Win32_UserAccount where name LIKE 'SVC-%MSSQL'"

Get-WmiObject -Class Win32_UserAccount | ? name -Like '*yeadon*'


# WQL Language
# https://docs.microsoft.com/en-us/windows/desktop/wmisdk/wql-sql-for-wmi

# GetWmiObject help
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject?view=powershell-5.1