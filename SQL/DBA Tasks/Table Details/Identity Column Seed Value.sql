-- ==== Query to Find Seed Values, Increment Values and Current Identity Column Value 
-- ==== of the Table with Max Value of Datatype
-- ==== http://blog.sqlauthority.com/2014/08/27/sql-server-query-to-find-seed-values-increment-values-and-current-identity-column-value-of-the-table-with-max-value-of-datatype/

SELECT  [Seed]              = IDENT_SEED( TABLE_SCHEMA + '.' + TABLE_NAME) ,
        [Increment]         = IDENT_INCR( TABLE_SCHEMA + '.' + TABLE_NAME) ,
        [CurrentIdentity]   = IDENT_CURRENT( TABLE_SCHEMA + '.' + TABLE_NAME) ,
        [Table]             = TABLE_SCHEMA + '.' + TABLE_NAME ,
        [DataType]          = UPPER(c.DATA_TYPE) ,
        [MaxPosValue]       = t.MaxPosValue,
        [Remaining]         = t.MaxPosValue -IDENT_CURRENT(TABLE_SCHEMA + '.' + TABLE_NAME) ,
        [PercentUnAllocated]= ( ( t.MaxPosValue - IDENT_CURRENT( TABLE_SCHEMA + '.' + TABLE_NAME)) / t.MaxPosValue) * 100
FROM    INFORMATION_SCHEMA.COLUMNS AS c
        INNER JOIN ( 
                    SELECT  name AS Data_Type ,
                            POWER(CAST(2 AS VARCHAR), ( max_length * 8 ) - 1) AS MaxPosValue
                    FROM    sys.types
                    WHERE   name LIKE '%Int'  
                    ) t 
                ON c.DATA_TYPE = t.Data_Type
WHERE   COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1
ORDER BY PercentUnAllocated ASC
