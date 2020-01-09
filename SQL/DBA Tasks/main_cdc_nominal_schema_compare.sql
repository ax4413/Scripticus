
/*
select	[table_name]     = t.name,
		[cdc_table_name] = 'dbo_' + t.name + '_A_CT',
		[column_name]    = c.name
into	#cte
from	ETAMSIT1NominalLedger.sys.tables t
		inner join ETAMSIT1NominalLedger.sys.schemas s on s.schema_id = t.schema_id
		inner join ETAMSIT1NominalLedger.sys.columns c on c.object_id = t.object_id		
where	s.name = 'base'
and		c.name not like '%Nominal%'
*/

--select * from #cte order by 1,3

; with nom as (
	select	[table_name]      = t.name,
			[column_name]     = c.name,
			[type_name]       = ty.name,
			[max_length]      = c.max_length, 
			[precision]       = c.precision, 
			[scale]           = c.scale, 
			[is_nullable]     = c.is_nullable,
			[table_join_name] = cte.cdc_table_name
	from	#cte cte
			inner join ETAMSIT1NominalLedger.sys.tables t on t.name = cte.table_name
			inner join ETAMSIT1NominalLedger.sys.schemas s on s.schema_id = t.schema_id and s.name = 'base'
			inner join ETAMSIT1NominalLedger.sys.columns c on c.object_id = t.object_id and c.name = cte.column_name
			inner join ETAMSIT1NominalLedger.sys.types ty on ty.user_type_id = c.user_type_id
)
--select * from nom /*

, main as (
	select	[table_name]  = t.name,
			[column_name] = c.name,
			[type_name]   = ty.name,
			[max_length]  = c.max_length, 
			[precision]   = c.precision, 
			[scale]       = c.scale, 
			[is_nullable] = c.is_nullable
	from	#cte cte 
			inner join ETAMSIT1Main.sys.tables t on t.name = cte.cdc_table_name
			inner join ETAMSIT1Main.sys.schemas s on s.schema_id = t.schema_id and s.name = 'cdc'
			inner join ETAMSIT1Main.sys.columns c on c.object_id = t.object_id and c.name = cte.column_name
			inner join ETAMSIT1Main.sys.types ty on ty.user_type_id = c.user_type_id
)
--select * from main /*


select	[nom_table_name]      = nom.[table_name],
		[nom_column_name]     = nom.[column_name],
		[nom_type_name]  	  = nom.[type_name],
		[nom_max_length] 	  = nom.[max_length],
		[nom_precision]  	  = nom.[precision],
		[nom_scale]      	  = nom.[scale],
    	[main_cdc_table_name] = main.[table_name],
		[main_column_name]    = main.[column_name],
		[main_type_name]  	  = main.[type_name],
		[main_max_length] 	  = main.[max_length],
		[main_precision]  	  = main.[precision],
		[main_scale]      	  = main.[scale]
from	nom
		full outer join main 
			 on  main.[table_name]    = nom.[table_join_name]
			 and main.[column_name]   = nom.[column_name]
			 and main.[type_name]     = nom.[type_name]
			 and main.[max_length]    = nom.[max_length]
			 and main.[precision]     = nom.[precision]
			 and main.[scale]         = nom.[scale]

where nom.table_name is null or main.table_name is null
order by nom.table_name, 
         main.table_name,
		 nom.column_name, 
		 main.column_name

-- */ -- */