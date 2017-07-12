-- Memory usage by database
SELECT  [DatabaseName]      = CASE [database_id] WHEN 32767 THEN 'Resource DB'
                                                 ELSE DB_NAME([database_id]) END,
        [Pages in Buffer]   = COUNT_BIG(*) ,
        [Buffer Size in MB] = COUNT_BIG(*)/128 
FROM    sys.dm_os_buffer_descriptors
GROUP BY [database_id]
ORDER BY [Pages in Buffer] DESC;


--  Now let us see another query which returns us details about how 
--  much memory each object uses in a particular database.
SELECT  [Object Name]         = obj.name, 
        [Object Type]         = o.type_desc,
        [Index Name]          = i.name, 
        [Index Type]          = i.type_desc,
        [Cached Pages Count]  = COUNT(*),
        [Cached Pages In MB]  = COUNT(*)/128
FROM    sys.dm_os_buffer_descriptors AS bd
        INNER JOIN (SELECT  object_name(object_id) AS name
                          , object_id
                          , index_id 
                          , allocation_unit_id
                    FROM  sys.allocation_units AS au
                          INNER JOIN sys.partitions AS p
                                  ON au.container_id = p.hobt_id
                                  AND (au.type = 1 OR au.type = 3)
                    UNION ALL
                    SELECT  object_name(object_id) AS name
                          , object_id
                          , index_id
                          , allocation_unit_id
                    FROM  sys.allocation_units AS au
                          INNER JOIN sys.partitions AS p
                                ON au.container_id = p.partition_id
                                AND au.type = 2
                    ) AS obj
                ON bd.allocation_unit_id = obj.allocation_unit_id
        INNER JOIN sys.indexes i 
                ON obj.[object_id] = i.[object_id]
        INNER JOIN sys.objects o 
                ON obj.[object_id] = o.[object_id]
WHERE   database_id = DB_ID()
GROUP BY obj.name, i.type_desc, o.type_desc,i.name
ORDER BY [Cached Pages In MB] DESC;