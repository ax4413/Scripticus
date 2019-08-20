--=== Table Details
SELECT  TableId     = object_id
      , TableName   = t.name
FROM    sys.Tables  t
WHERE   t.is_ms_shipped = 0
ORDER BY t.Name


--=== Column detail
SELECT  TableId       = t.object_id
      , TableName     = t.name  
      , ColumnId      = c.column_id
      , ColumnName    = c.name      
      , TypeName      = ty.name
      , [Presision]   = CASE ty.name 
                            WHEN'char' THEN '(' + cast(c.max_length AS VARCHAR(5)) + ')'
                            WHEN'date' THEN ''
                            WHEN'datetime' THEN ''
                            WHEN'decimal' THEN '(' + cast(c.precision AS VARCHAR(5)) + ',' + cast(c.scale AS VARCHAR(5)) + ')'
                            WHEN'int' THEN ''
                            WHEN'smallint' THEN ''
                            WHEN'tinyint' THEN ''
                            WHEN'varchar' THEN '(' + CASE c.max_length WHEN-1 THEN 'MAX' ELSE cast(c.max_length AS VARCHAR(5)) END + ')'
                            WHEN'uniqueidentifier' THEN '' 
                            ELSE'ERROR' -- This will cause the table creation script to fail parsing
                          END 
      , Nullable      = c.is_nullable
      , [IsComputed]  = c.is_computed
      , [IsIdentity]  = c.is_identity
      , [PrimaryKey]  = COALESCE(i.name,'')
FROM  sys.tables t
      INNER JOIN sys.columns c
              ON t.object_id = c.object_id
      INNER JOIN sys.types ty 
              ON ty.user_type_id = c.user_type_id      
      LEFT OUTER JOIN sys.index_columns ic
              ON ic .object_id = c.object_id
              AND ic.column_id = c.column_id
      LEFT OUTER JOIN sys.indexes i 
              ON ic.index_id = i.index_id
              AND ic.object_id = i.object_id
              AND i.is_primary_key = 1 
ORDER BY t.name, c.name, c.column_id



--=== Forigne Key Details
SELECT  FkId                  = fk.object_id
      , ForiegnKey            = fk.name
      , ParentTableId         = pt.Object_id
      , ParentTableName       = pt.Name
      , ParentColumnId        = pc.Column_Id
      , ParentColumnName      = pc.Name
      , ReferencedTableId     = ct.Object_id
      , ReferencedTableName   = ct.Name
      , ReferencedColumnId    = cc.Column_Id
      , ReferencedColumnName  = cc.Name
FROM    sys.foreign_keys fk
        INNER JOIN sys.foreign_key_columns fkc 
                ON fk.object_id = fkc.constraint_object_id
        INNER JOIN sys.tables pt 
                ON  pt.object_id = fkc.parent_object_id
	      INNER JOIN sys.columns pc 
		            ON  pc.object_id = fkc.parent_object_id
			          AND pc.column_id = fkc.parent_column_id
        INNER JOIN sys.tables ct 
                ON  ct.object_id = fkc.referenced_object_id
	      INNER JOIN sys.columns cc
		            ON  cc.object_id = fkc.referenced_object_id
			          AND cc.column_id = fkc.referenced_column_id
ORDER BY fkc.constraint_column_id



--=== Extended properties
SELECT Class              = ep.class
      , ClassDescription  = ep.class_desc
      , TableId           = ep.major_id
      , TableName         = t.name      
      , ColumnId          = ep.minor_id
      , ColumnName        = c.name
      , ExtendedProperty  = ep.name
      , Value             = ep.value
FROM sys.extended_properties ep
      inner join sys.tables t
              on t.object_id = ep.major_id
      left outer join sys.columns c
              on c.object_id = t.object_id
              and c.column_id = ep.minor_id
ORDER BY t.name, ep.minor_id
GO



--=== Forigne Key Details
SELECT  FkId                  = fk.object_id
      , ForiegnKey            = fk.name
      , ParentTableId         = pt.Object_id
      , ParentTableName       = pt.Name
      , ParentColumnId        = pc.Column_Id
      , ParentColumnName      = pc.Name
      , ReferencedTableId     = ct.Object_id
      , ReferencedTableName   = ct.Name
      , ReferencedColumnId    = cc.Column_Id
      , ReferencedColumnName  = cc.Name
FROM    sys.foreign_keys fk
        INNER JOIN sys.foreign_key_columns fkc 
                ON fk.object_id = fkc.constraint_object_id
        INNER JOIN sys.tables pt 
                ON  pt.object_id = fkc.parent_object_id
	      INNER JOIN sys.columns pc 
		            ON  pc.object_id = fkc.parent_object_id
			          AND pc.column_id = fkc.parent_column_id
        INNER JOIN sys.tables ct 
                ON  ct.object_id = fkc.referenced_object_id
	      INNER JOIN sys.columns cc
		            ON  cc.object_id = fkc.referenced_object_id
			          AND cc.column_id = fkc.referenced_column_id
ORDER BY fkc.constraint_column_id
GO



-- ===  Index details 
SELECT  [TableName]           = t.name
      , [IndexName]           = ix.name
      , [IndexType]           = ix.type_desc
      , [IsUnique]            = ix.is_unique
      , [IsPrimaryKey]        = ix.is_primary_key
      , [IsUniqueConstraint]  = ix.is_unique
      , [IsDisabled]          = ix.is_disabled
      , [IsHypothetical]      = ix.is_hypothetical
      , [HasFilter]           = ix.has_filter
      , [FillFactor]          = ix.fill_factor
      , [KeyColumns]          = k.columns
      , [IncludedColumns]     = i.columns
FROM    sys.indexes ix 
        INNER JOIN sys.tables t
                ON t.object_id = ix.object_id
        CROSS APPLY (  SELECT DISTINCT STUFF( (
                            SELECT  ', ' + c.name + CASE WHEN ixc.is_descending_key = 1 then ' DESC' ELSE '' END
                            FROM    sys.index_columns ixc
                                    INNER JOIN sys.columns c
                                            ON c.object_id = ixc.object_id
                                            AND c.column_id = ixc.column_id
                            WHERE   ixc.object_id = ix.object_id
                              AND   ixc.index_id  = ix.index_id
                              AND   ixc.is_included_column = 0
                            ORDER BY ixc.index_column_id 
                      FOR XML PATH('')),1,2,'') AS Columns ) k
        OUTER APPLY (  SELECT DISTINCT STUFF( (
                            SELECT  ', ' + c.name + CASE WHEN ixc.is_descending_key = 1 then ' DESC' ELSE '' END
                            FROM    sys.index_columns ixc
                                    INNER JOIN sys.columns c
                                            ON c.object_id = ixc.object_id
                                            AND c.column_id = ixc.column_id
                            WHERE   ixc.object_id = ix.object_id
                              AND   ixc.index_id  = ix.index_id
                              AND   ixc.is_included_column = 1
                            ORDER BY ixc.index_column_id 
                      FOR XML PATH('')),1,2,'') AS Columns ) i
WHERE   t.is_ms_shipped = 0 -- exclude objects shipped by microsoft
  AND   ix.type != 0        -- exclude heaps
ORDER BY t.name, ROW_NUMBER() OVER (ORDER BY ix.is_primary_key DESC, ix.name)
GO



--=== View Column detail
SELECT  TableId       = v.object_id
      , TableName     = v.name  
      , ColumnId      = c.column_id
      , ColumnName    = c.name      
      , TypeName      = ty.name
      , [Presision]   = CASE ty.name 
                           
                            WHEN 'date'     THEN ''
                            WHEN 'datetime' THEN ''   
                            WHEN 'int'      THEN ''
                            WHEN 'bigint'   THEN ''
                            WHEN 'smallint' THEN ''
                            WHEN 'tinyint'  THEN ''
                            WHEN 'money'    THEN ''
                            WHEN 'float'    THEN ''
                            WHEN 'real'     THEN ''
                            WHEN 'numeric'  THEN ''
                            WHEN 'text'     THEN ''
                            WHEN 'decimal'  THEN '(' + cast(c.precision AS VARCHAR(5)) + ',' + cast(c.scale AS VARCHAR(5)) + ')'
                            WHEN 'char'     THEN '(' + cast(c.max_length AS VARCHAR(5)) + ')'
                            WHEN 'varchar'  THEN '(' + CASE c.max_length WHEN-1 THEN 'MAX' ELSE cast(c.max_length AS VARCHAR(5)) END + ')'
                            WHEN 'nvarchar' THEN '(' + CASE c.max_length WHEN-1 THEN 'MAX' ELSE cast(c.max_length AS VARCHAR(5)) END + ')'
                            ELSE 'ERROR' -- This will cause the table creation script to fail parsing
                          END 
      , Nullable      = c.is_nullable
FROM  sys.Views v
      INNER JOIN sys.columns c
              ON v.object_id = c.object_id
      INNER JOIN sys.types ty 
              ON ty.user_type_id = c.user_type_id      
      LEFT OUTER JOIN sys.index_columns ic
              ON ic .object_id = c.object_id
              AND ic.column_id = c.column_id
      LEFT OUTER JOIN sys.indexes i 
              ON ic.index_id = i.index_id
              AND ic.object_id = i.object_id
              AND i.is_primary_key = 1 
ORDER BY v.name, c.column_id, c.name
