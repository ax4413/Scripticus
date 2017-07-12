select sum(q.lines_ofcode) lines_of_code_in_DB
from (
	select t.sp_name, sum(t.lines_of_code) - 1 as lines_ofcode, t.type_desc
	from
	(
		select o.name as sp_name
			, (len(c.text) - len(replace(c.text, char(10), ''))) as lines_of_code
			, case when o.type = 'P' then 'Stored Procedure'
				when o.type in ('FN', 'IF', 'TF') then 'Function'
			end as type_desc
		from sys.objects o
			inner join sys.syscomments c on c.id = o.object_id
		where o.type in ('P', 'FN', 'IF', 'TF')
			and o.is_ms_shipped = 0
	) t
	group by t.sp_name, t.type_desc
	--order by t.sp_name
)q
