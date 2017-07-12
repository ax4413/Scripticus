/*************************************************************************************
This procedure should be created in the Master database. This procedure takes no
parameters. It will remap orphaned users in the current database to EXISTING logins
of the same name. This is usefull in the case a new database is created by restoring
a backup to a new database, or by attaching the datafiles to a new server.
*************************************************************************************/


IF OBJECT_ID('dbo.sp_fixusers') IS NOT NULL
BEGIN
DROP PROCEDURE dbo.sp_fixusers
IF OBJECT_ID('dbo.sp_fixusers') IS NOT NULL
PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_fixusers >>>'
ELSE
PRINT '<<< DROPPED PROCEDURE dbo.sp_fixusers >>>'
END

GO

CREATE PROCEDURE dbo.sp_fixusers

AS

BEGIN

DECLARE @username varchar(100)

DECLARE fixusers CURSOR
FOR

SELECT UserName = name FROM sysusers
WHERE issqluser = 1 and (sid is not null and sid <> 0x0)
and suser_sname(sid) is null
ORDER BY name

OPEN fixusers

FETCH NEXT FROM fixusers
INTO @username

WHILE @@FETCH_STATUS = 0
BEGIN
EXEC sp_change_users_login 'update_one', @username, @username
print 'sp_change_users_login update_one ' + @username + @username
FETCH NEXT FROM fixusers
INTO @username
END


CLOSE fixusers
DEALLOCATE fixusers
END
go
IF OBJECT_ID('dbo.sp_fixusers') IS NOT NULL
PRINT '<<< CREATED PROCEDURE dbo.sp_fixusers >>>'
ELSE
PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_fixusers >>>'
go