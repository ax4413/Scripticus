IF OBJECT_ID('tempdb.dbo.#tmp') IS NOT NULL
  DROP TABLE #TMP
GO

create table #tmp(database_name varchar(128), queue_name varchar(128), queue_count int, clean_queue_sql varchar(max) )

DECLARE @database_name    VARCHAR(128)  
      , @longest_db_name  INT
      , @message          VARCHAR(2000)
      , @sql              VARCHAR(MAX)
      , @sql_template     VARCHAR(MAX)

SET @sql_template = '
insert into #tmp(database_name, queue_name, queue_count)
select ''{database}'' as db_name , q.name, p.rows
from   {database}.sys.objects as o
       join {database}.sys.partitions as p on p.object_id = o.object_id
       join {database}.sys.objects as q on o.parent_object_id = q.object_id
where  q.name in ( select name from {database}.sys.service_queues where is_ms_shipped = 0 )
  and  p.index_id = 1'
  
DECLARE _cursor CURSOR FOR   
select  name, MAX(LEN(name)) OVER( PARTITION BY 1)
from    sys.databases 
where   database_id > 4 
  and   is_broker_enabled = 1
  and   state = 0 -- online
order by name  

OPEN _cursor  
  
FETCH NEXT FROM _cursor   
INTO @database_name, @longest_db_name
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    PRINT '  '
    SET @message = LEFT( @database_name + '  ' + REPLICATE('=', 100), 60) 
    PRINT 'Processing - '  + @message
    
    SET @sql = REPLACE(@sql_template, '{database}', @database_name)
    
    PRINT @sql
    EXEC(@sql)

    FETCH NEXT FROM _cursor   
    INTO @database_name, @longest_db_name
END   
CLOSE _cursor;  
DEALLOCATE _cursor;  


update #tmp
set clean_queue_sql = REPLACE( 
                        REPLACE('
USE {DatabaseName};
DECLARE @handle UNIQUEIDENTIFIER;
WHILE (SELECT COUNT(*) FROM {NameOfQueue}) > 0
BEGIN
	RECEIVE TOP (1) @handle = conversation_handle FROM {NameOfQueue};
	END CONVERSATION @handle WITH CLEANUP
END
', '{NameOfQueue}', queue_name ), '{Databasename}', database_name )


select * 
from   #tmp 
where  queue_count > 1
--  and  queue_name in ('TrackingResponseQueue', 'TrackingNotificationQueue')
order by database_name, queue_name
