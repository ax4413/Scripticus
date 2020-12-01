cls

Write-Host "Generate meta data files for sql objects`r`n"

$instance  = '.'
$database  = 'DVVANZZZDataMigration'
$namespace = "Migration.DataAccess.Entities.MigrationData"
$outputDir = 'D:\Entites\MigrationData'
$accessModifier = "public"

# we are interested in MigrationData schema objects see vvv
$get_table_sql = "
select  s.name schema_name, t.name name, t.object_id
from    sys.tables t
        inner join sys.schemas s on s.schema_id = t.schema_id
where   s.name = 'MigrationData'
order by s.name, t.name
"

$get_columns_sql = "
select  c.name, typ.name type, c.max_length, c.precision, c.is_nullable, c.is_identity, c.column_id
from    sys.columns c
        inner join sys.types typ on typ.user_type_id = c.user_type_id
where   c.object_id = {object_id}
order by c.is_identity desc, c.column_id
"


$tables = @(Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $get_table_sql)

foreach($table in $tables){
    $sql = $get_columns_sql -replace '{object_id}', $table.object_id
    $columns = @(Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $sql)

    $o = [PSCustomObject]@{
        'name'  = $table.name
        'schema' = $table.schema_name
        'columns' = @()
    }

    foreach($column in $columns){
        $o.columns += [PSCustomObject]@{
            'name' = $column.name
            'type' = $column.type
            'max_length' = $column.max_length
            'precision' = $column.precision
            'is_nullable' = $column.is_nullable
            'is_identity' = $column.is_identity
        }
    }

    $metaDataFile = Join-Path $outputDir "$($table.name).json"
    if(-not(Test-Path $metaDataFile)){
        New-Item $metaDataFile -Force | Out-Null
    }

    $o | ConvertTo-Json -Depth 10 | Out-File $metaDataFile -Force

    Write-Host " - Created $metaDataFile"
    Write-Host " "
}


