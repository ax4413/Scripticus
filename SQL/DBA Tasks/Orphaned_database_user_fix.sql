-- ===  http://www.sqlservercentral.com/blogs/brian_kelley/2013/04/22/troubleshooting-sql-server-error-15517/

-- drop table #t
create table #T(DbName varchar(128), DboLogon varchar(128), SysDbLogon varchar(128))

EXEC sp_MSForEachDB 
'insert into #t
SELECT ''?'' AS ''DBName'', sp.name AS ''dbo_login'', o.name AS ''sysdb_login''
FROM [?].sys.database_principals dp
  LEFT JOIN master.sys.server_principals sp
    ON dp.sid = sp.sid
  LEFT JOIN master.sys.databases d 
    ON DB_ID(''?'') = d.database_id
  LEFT JOIN master.sys.server_principals o 
    ON d.owner_sid = o.sid
WHERE dp.name = ''dbo'';';

select * from #t order by 1

select 'ALTER AUTHORIZATION ON DATABASE::' + dbname + ' TO ' + 'sa' +  ';' from #t t where dbologon is null order by 1
