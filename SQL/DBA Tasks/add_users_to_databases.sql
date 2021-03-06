use master

declare @wildcard_db_name varchar(128)  = 'dvvansy%'
declare @service_account  varchar(128)  = 'ICECLOUDNP\SVC-DVWORK07'
declare @sql_template     varchar(2000) = '
use [#db_name#]
if not exists (select * from sys.sysusers where name = ''#user_name#'') begin
  create user [#user_name#] for login [#login_name#]
end'

declare @db_name varchar(128)  /* individual db */
declare @sql_cmd varchar(2000)

declare csr cursor for
select  name 
from    sys.databases 
where   name like @wildcard_db_name
and     source_database_id is null

open csr

fetch next from csr into @db_name

while @@FETCH_STATUS = 0 begin
  select @sql_cmd = replace(  replace( replace( @sql_template, '#db_name#', @db_name), '#login_name#', @service_account), '#user_name#', @service_account)
  raiserror(@sql_cmd,0,0) with nowait
  exec (@sql_cmd)
  fetch next from csr into @db_name
end

close csr
deallocate csr


  