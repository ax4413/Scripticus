SELECT  [Table Name]            = OBJECT_NAME(p.OBJECT_ID)
      , [Resource Type]         = resource_type,
      , [Resouce Dexscription]  = resource_description
FROM    sys.dm_tran_locks l
        INNER JOIN sys.partitions p
                ON l.resource_associated_entity_id = p.hobt_id

