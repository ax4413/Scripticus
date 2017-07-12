/*
Script to set up link servers. please edit the ip and sa and password
*/
EXEC master.dbo.sp_addlinkedserver @server = N'OLTPPROD01'
, @provider=N'SQLNCLI', @srvproduct='', @datasrc=N'192.168.192.3'
 
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'OLTPPROD01'
,@useself=N'False',@locallogin=NULL,@rmtuser=N'sa',@rmtpassword='0pt1c5##'

GO

EXEC master.dbo.sp_addlinkedserver @server = N'DDCOLL'
, @provider=N'SQLNCLI', @srvproduct='', @datasrc=N'192.168.192.3'
 
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DDCOLL'
,@useself=N'False',@locallogin=NULL,@rmtuser=N'sa',@rmtpassword='0pt1c5##'

GO

EXEC master.dbo.sp_addlinkedserver @server = N'EGOS'
, @provider=N'SQLNCLI', @srvproduct='', @datasrc=N'192.168.192.3'
 
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'EGOS'
,@useself=N'False',@locallogin=NULL,@rmtuser=N'sa',@rmtpassword='0pt1c5##'

GO
--select * from sys.servers