select 'drop database [' + name +'];' + CHAR(13) + CHAR(10) + 'GO' 
from sys.databases 
where name like '%SY%' 
and source_database_id is not null

select 'drop database [' + name +'];' + CHAR(13) + CHAR(10) + 'GO' 
from sys.databases 
where name like '%SY%' 
and source_database_id is null

select 'ALTER AVAILABILITY GROUP [AVG-DV] REMOVE DATABASE [' + NAME+ '];  ' + CHAR(13) + CHAR(10) + 
       'GO' + CHAR(13) + CHAR(10) +
       'drop database [' + name +'];' + CHAR(13) + CHAR(10) + 
       'GO' 
from sys.databases 
where name like '%SY%'
