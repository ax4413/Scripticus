use btvansweet16main


DECLARE @shadow_table_name varchar(128)
DECLARE @parent_table_name varchar(128)

drop table #results
create table #Results ([parent_table_name] varchar(128), [colun_name] varchar(128), [type_name] varchar(128), [precision] int , [scale] int, [max_length] int)


DECLARE _cursor CURSOR  
    FOR select shadow_table_name = name, table_name = substring(name, 1, (len(name) -2))  
        from sys.tables 
        where name like '%^_S' escape '^'
OPEN _cursor  
FETCH NEXT FROM _cursor
INTO @shadow_table_name, @parent_table_name

WHILE @@FETCH_STATUS = 0  
BEGIN  
  PRINT @shadow_table_name

  insert into #Results([parent_table_name], [colun_name], [type_name], [precision], [scale], [max_length])
    select  @parent_table_name parent_table_name, c.name, t.name, c.precision, c.scale, c.max_length
    from    sys.columns c
            inner join sys.types t on t.user_type_id = c.user_type_id
    where   c.object_id = object_id(@parent_table_name )
    except
    select  @parent_table_name parent_table_name, c.name, t.name, c.precision, c.scale, c.max_length
    from    sys.columns c
            inner join sys.types t on t.user_type_id = c.user_type_id
    where   c.object_id = object_id(@shadow_table_name)
    and     c.name not in ('id', 'UpdateByUserId', 'WhenChanged', 'UpdateOperation', 'UpdateByProcedure', 'InternalTransactionId')

  FETCH NEXT FROM _cursor
  INTO @shadow_table_name, @parent_table_name
END

CLOSE _cursor;  
DEALLOCATE _cursor;  

select * from  #results






