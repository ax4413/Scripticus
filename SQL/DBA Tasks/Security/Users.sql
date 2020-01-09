dbcc useroptions

-- List all groups which the domain account belongs to
EXEC xp_logininfo 'ICECLOUDNP\syeadon', 'all'

select USER_NAME(), 
       CURRENT_USER,
       SUSER_SID(),
       SUSER_ID(), 
       SUSER_NAME(), 
       SUSER_SNAME()

select * from sys.sql_logins
select * from sys.server_principals 
select * from sys.database_principals


SELECT  pr.principal_id, pr.name, pr.type_desc, pe.state_desc, pe.permission_name, pr.default_database_name, pr.default_language_name
FROM    sys.server_principals AS pr   
        INNER JOIN sys.server_permissions AS pe   
                ON pe.grantee_principal_id = pr.principal_id
