/*
Get current Default backup location */
DECLARE @BackupDirectory VARCHAR(100) 
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', 
  @key='SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQLServer', 
  @value_name='BackupDirectory', 
  @BackupDirectory=@BackupDirectory OUTPUT 
SELECT @BackupDirectory

/*
Alter the Default backup location */
EXEC  master.. xp_regwrite 
  @rootkey = 'HKEY_LOCAL_MACHINE' , 
  @key = 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQLServer' , 
  @value_name = 'BackupDirectory' , 
  @type = 'REG_SZ' , 
  @value = 'C:\SQL_Files\Backup'