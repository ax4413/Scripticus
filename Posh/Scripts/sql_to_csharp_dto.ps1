cls

Write-Host "Convert sql to c# data transfer objects"

$instance  = '.'
$database  = 'xxxDataMigration'
$namespace = "Migration.DataAccess.Entities.MigrationData"
$outputDir = 'F:\Source\icenet-tools\data-migration\Migration.DataAccess\Entites\MigrationData'
$accessModifier = "public"

$get_table_sql = "
select  s.name schema_name, t.name name, t.object_id
from    sys.tables t
        inner join sys.schemas s on s.schema_id = t.schema_id
where   s.name = 'MigrationData'
order by s.name, t.name
"

$get_columns_sql = "
select  c.name, typ.name type, c.is_nullable, c.is_identity, c.column_id
from    sys.columns c
        inner join sys.types typ on typ.user_type_id = c.user_type_id
where   c.object_id = {object_id}
order by c.is_identity desc, c.column_id
"

$dataTypeMap = @{
    'bigint'           = 'Int64';
    'binary'           = 'Byte[]';
    'bit'              = 'Boolean';
    'char'             = 'string';
    'date'             = 'DateTime';
    'datetime'         = 'DateTime';
    'datetime2'        = 'DateTime';
    'datetimeoffset'   = 'DateTimeOffset';
    'decimal'          = 'Decimal';
    'FILESTREAM'       = 'Byte[]';
    'float'            = 'Double';
    'image'            = 'Byte[]';
    'int'              = 'int';
    'money'            = 'Decimal';
    'nchar'            = 'string';
    'ntext'            = 'string';
    'numeric'          = 'Decimal';
    'nvarchar'         = 'string';
    'real'             = 'Single';
    'rowversion'       = 'Byte[]';
    'smalldatetime'    = 'DateTime';
    'smallint'         = 'Int16';
    'smallmoney'       = 'Decimal';
    'sql_variant'      = 'Object';
    'text'             = 'string';
    'time'             = 'TimeSpan';
    'timestamp'        = 'Byte[]';
    'tinyint'          = 'Byte';
    'uniqueidentifier' = 'Guid';
    'varbinary'        = 'Byte[]';
    'varchar'          = 'string';
    'xml'              = 'Xml';
}


function Get-ProperyString($TableName, $Column, $AccessModifier = 'public'){
    $dataType = $dataTypeMap["$($column.type)"]

    if($column.is_nullable -and $dataType -inotin ('string')){
        $dataType += '?'
    }

    return "{0} {1} {2} {3}" -f $AccessModifier, $dataType, $Column.name, '{ get; set; }'
}


$tables = @(Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $get_table_sql)

foreach($table in $tables){
    Write-Host "Creating $($table.name).cs..."

    $sql = $get_columns_sql -replace '{object_id}', $table.object_id
    $columns = @(Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $sql)

    $sb = [System.Text.stringBuilder]::new()
    $sb.AppendLine("using System;") | Out-Null
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("namespace $namespace") | Out-Null
    $sb.AppendLine("{") | Out-Null
    $sb.AppendLine("    $accessModifier class $($table.name)") | Out-Null
    $sb.AppendLine("    {") | Out-Null
    
    foreach($column in $columns){
        $p = Get-ProperyString -ableName $table.name -Column $column -AccessModifier $accessModifier
        $sb.AppendLine("        $p") | Out-Null
    }

    $sb.AppendLine("    }") | Out-Null
    $sb.AppendLine("}") | Out-Null

    $dtoFile = Join-Path $outputDir "$($table.name).cs"
    if(-not(Test-Path $dtoFile)){
        New-Item $dtoFile -Force | Out-Null
    }
    $sb.Tostring() | Out-File $dtoFile -Force

    Write-Host " - Created $dtoFile"
    Write-Host " "
}


