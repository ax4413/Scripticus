-- tables without PK
SELECT t.name TableName, OBJECTPROPERTY(t.OBJECT_ID,'TableHasPrimaryKey') HasPrimaryKey
FROM sys.tables t
WHERE OBJECTPROPERTY(t.OBJECT_ID,'TableHasPrimaryKey') = 0    -- Missing a primary key


-- Braekdown of types used
SELECT DISTINCT ty.name TypeName, ty.precision, ty.max_length, count(*) ColumnCount
FROM sys.tables t
    INNER JOIN sys.columns c on c.object_id = t.object_id
    INNER JOIN sys.types ty on ty.user_type_id = c.user_type_id
    GROUP BY ty.name, ty.precision, ty.max_length
ORDER BY ty.name, ty.precision, ty.max_length


-- Overview of db tables, columns and their types
SELECT schema_name(t.schema_id) SchemaName, t.name TableName, c.name ColumnName, ty.name TypeName, ty.precision, ty.max_length
FROM sys.tables t
    INNER JOIN sys.columns c on c.object_id = t.object_id
    INNER JOIN sys.types ty on ty.user_type_id = c.user_type_id
ORDER BY t.name,c.column_id





