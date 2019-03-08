/*
  error     : The database principal has granted or denied permissions to catalog objects in the database and cannot be dropped
  resource  : https://blog.dbi-services.com/delete-an-orphan-user-database-under-ssisdb/
            : https://social.msdn.microsoft.com/Forums/sqlserver/en-US/07b40291-6c4d-427e-a5e2-568df482c550/drop-user-fails-with-quotthe-database-principal-has-granted-or-denied-permissions-to-catalog?forum=sqlsecurity
*/
USE SSISDB


-- find orphaned users
SELECT  * 
FROM    sys.database_principals a
        LEFT OUTER JOIN sys.server_principals b ON a.sid = b.sid
WHERE   b.sid IS NULL 
AND     a.type In ('U', 'G') 
AND   a.principal_id > 4




-- look for orphaned rows thene delete them. ALWAYS TAKE A BACKUP FIRST

SELECT  [object_type]             = CASE (ObjPerm.object_type) WHEN 1 THEN 'folder'
                                      WHEN 2 THEN 'project'
                                      WHEN 3 THEN 'environment'
                                      WHEN 4 THEN 'operation' END ,
        [permission_description]  = CASE (ObjPerm.permission_type)  WHEN 1 THEN 'READ'
                                      WHEN 2 THEN 'MODIFY'
                                      WHEN 3 THEN 'EXECUTE'
                                      WHEN 4 THEN 'MANAGE_PERMISSIONS'
                                      WHEN 100 THEN 'CREATE_OBJECTS'
                                      WHEN 101 THEN 'READ_OBJECTS'
                                      WHEN 102 THEN 'MODIFY_OBJECTS'
                                      WHEN 103 THEN 'EXECUTE_OBJECTS'
                                      WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS' END,
        [database_user_name]      = Princ.Name 
FROM    [internal].[object_permissions] ObjPerm 
        JOIN sys.server_principals Princ 
              ON ObjPerm.sid = Princ.sid
WHERE   Princ.Name = 'ICECLOUDNP\BTVANTeam4SSI'
ORDER BY [object_type] DESC, [database_user_name], [permission_description]



/*Folder Permissions*/
SELECT  fo.*,p.name
FROM    internal.folder_permissions fo
        INNER JOIN sys.database_principals p on fo.[sid] = p.[sid]
WHERE   p.name = 'ICECLOUDNP\BTVANTeam5SSI'

/*Project Permissions*/
SELECT  pr.*,p.name
FROM    internal.project_permissions pr
        INNER JOIN sys.database_principals p on pr.[sid] = p.[sid]
WHERE   p.name = 'ICECLOUDNP\BTVANTeam5SSI'

/*Environment Permissions*/
SELECT  en.*,p.name
FROM    internal.environment_permissions en
        INNER JOIN sys.database_principals p on en.[sid] = p.[sid]
WHERE   p.name = 'ICECLOUDNP\BTVANTeam5SSI'

/*Operation Permissions*/
SELECT  op.*,p.name
FROM    internal.operation_permissions op
        INNER JOIN sys.database_principals p on op.[sid] = p.[sid]
WHERE   p.name = 'ICECLOUDNP\BTVANTeam5SSI'


/*
DROP USER [ICECLOUDNP\BTVANTeam4SSI]
DROP USER [ICECLOUDNP\BTVANTeam5SSI]
*/



-- this way works very well
-- https://docs.microsoft.com/en-us/sql/integration-services/system-stored-procedures/catalog-revoke-permission-ssisdb-database?view=sql-server-2017
SELECT [object_type]
      ,[object_id]
      ,[principal_id]
      ,[permission_type]
      ,[is_deny]
      ,[grantor_id]
   , 'EXEC catalog.revoke_permission @object_type=' + CAST([object_type] AS VARCHAR) 
         + ', @object_id=' + CAST([object_id] AS VARCHAR) 
         + ', @principal_id=' + CAST(principal_id AS VARCHAR) 
         + ', @permission_type=' + CAST(permission_type AS VARCHAR)
  FROM [SSISDB].[catalog].[explicit_object_permissions]
  WHERE principal_id = USER_ID('ICECLOUDNP\BTVANTeam4SSI')

