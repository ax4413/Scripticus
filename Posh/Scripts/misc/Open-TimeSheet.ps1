$file = Get-ChildItem C:\Users\syeadon\Documents\TimeSheets | 
Sort-Object -Property LastWriteTime -Descending | 
Select-Object -First 1 -ExpandProperty FullName

write-host "Opening $file ..."

Start-Process $file