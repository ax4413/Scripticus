
function Get-Tables
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $instance,

        [Parameter(Mandatory=$true, Position=1)]
        [string] $database,

        [Parameter(Mandatory=$false, Position=2)]
        [string] $schema,

        [Parameter(Mandatory=$false, Position=3)]
        [string[]] $tables
    )

    Begin
    {
        $sqlTemplate = "
select  s.name schema_name, t.name table_name, t.object_id
from    sys.tables t
        inner join sys.schemas s on s.schema_id = t.schema_id
{Predicate}
order by s.name, t.name
"
    }
    Process
    {
        Write-Information "Geting table meta data for $instance $database"

        $sql = $sqlTemplate

        $predicate = ''
        if($schema -or $tables){
            $predicate =  "where 1=1"

            if($schema){ $predicate += " and s.name = '$schema'" }
            if($tables){ $predicate += " and t.name in ( $("'{0}'" -f ($tables -join "','")) )" }
        }

        $sql = $sql -replace '{Predicate}',$predicate
        
        Write-Verbose $sql

        $results = @(Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $sql)

        if($results.Count -eq 0){ throw "no tables found in $database matching the predicate"}

        foreach($table in $results){
            [PSCustomObject]@{
                'table_name'  = $table.table_name
                'schema_name' = $table.schema_name
                'object_id' = $table.object_id
            }
        }
    }
}

function Get-Columns
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $tableMetaData,
        
        [Parameter(Mandatory=$true, Position=1)]
        [string] $instance,

        [Parameter(Mandatory=$true, Position=2)]
        [string] $database        
    )

    Begin
    {
        $sqlTemplate = "
select  c.name, typ.name type, c.max_length, c.precision, c.is_nullable, c.is_identity, c.column_id
from    sys.columns c
        inner join sys.types typ on typ.user_type_id = c.user_type_id
where   c.object_id = {object_id}
order by c.is_identity desc, c.column_id
"
    }
    Process
    {
        if($tableMetaData -eq $null -or $tableMetaData.table_name -eq $null -or $tableMetaData.object_id -eq $null){
            throw "ArgumentNullException `$tableMetaData"
        }

        Write-Information "Geting column meta data for $instance $database $($tableMetaData.table_name)"

        $sql = $sqlTemplate -replace '{object_id}', $tableMetaData.object_id

        Write-Verbose $sql

        $columns = @(Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $sql)

        $o = [PSCustomObject]@{
            'name'  = $tableMetaData.table_name
            'schema' = $tableMetaData.schema_name
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

        $o
    }
}

function Get-TableMetaData
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $instance,

        [Parameter(Mandatory=$true, Position=1)]
        [string] $database,

        [Parameter(Mandatory=$false, Position=2)]
        [string] $schema,

        [Parameter(Mandatory=$false, Position=3)]
        [string[]] $tables
    )

    Process
    {
        $params = @{ 'instance'=$instance;
                     'database'=$database; }

        if($schema){ $params.Add('schema', $schema)}
        if($tables){ $params.Add('tables', $tables)}

        $results = Get-Tables @params 
        foreach($table in $results){
            Get-Columns -instance $instance -database $database -tableMetaData $table
        }
    }
}



function To-CamelCase
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        $text
    )

    Process
    {
        $text | % { $_.substring(0,1).tolower()+$_.substring(1) }
    }
}

function Get-DataType
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        $column
    )

    Begin
    {
        $dataTypeMap = @{
            'bigint'           = 'Int64';
            'binary'           = 'byte[]';
            'bit'              = 'bool';
            'char'             = 'string';
            'date'             = 'DateTime';
            'datetime'         = 'DateTime';
            'datetime2'        = 'DateTime';
            'datetimeoffset'   = 'DateTimeOffset';
            'decimal'          = 'decimal';
            'FILESTREAM'       = 'byte[]';
            'float'            = 'double';
            'image'            = 'byte[]';
            'int'              = 'int';
            'money'            = 'decimal';
            'nchar'            = 'string';
            'ntext'            = 'string';
            'numeric'          = 'decimal';
            'nvarchar'         = 'string';
            'real'             = 'Single';
            'rowversion'       = 'byte[]';
            'smalldatetime'    = 'DateTime';
            'smallint'         = 'Int16';
            'smallmoney'       = 'decimal';
            'sql_variant'      = 'object';
            'text'             = 'string';
            'time'             = 'TimeSpan';
            'timestamp'        = 'byte[]';
            'tinyint'          = 'byte';
            'uniqueidentifier' = 'Guid';
            'varbinary'        = 'byte[]';
            'varchar'          = 'string';
            'xml'              = 'Xml';
        }
    }
    Process
    {
        $dataType = $dataTypeMap["$($column.type)"]
        if($column.is_nullable -and $dataType -inotin ('string')){
            $dataType += '?'
        }
        $dataType
    }

}

function Get-ProperyString {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        $column, 
        
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateSet("public", "private", "internal", "sealed")]
        $AccessModifier
    )

    $dataType = Get-DataType -column $column

    return "{0} {1} {2} {3}" -f $AccessModifier, $dataType, $column.name, '{ get; set; }'
}

function Get-IBuilderProperty
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        $column
    )

    Process
    {
        $dataType = Get-DataType -column $column
        $propertyName = $column.name
        $parameterName = $column.name | To-CamelCase
        "
        $Modifier I{TableName}Builder With$propertyName($dataType $parameterName)
		{
			_instance.$propertyName = $parameterName;
			return this;
		}"
    }

}

function New-Model
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $MetaData,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        $ModelNamespace,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateSet("public", "private", "internal", "sealed")]
        [Alias('AccessModifier')]
        $Modifier = 'public'        
    )

    Begin
    { 
        $classTemplate = "
using System;

namespace $ModelNamespace
{
    $Modifier class $($MetaData.name)
    {
{properties}
    }
}
"
    }
    Process
    {    
        $sb = [System.Text.stringBuilder]::new()
        foreach($column in $MetaData.Columns){
            $p = Get-ProperyString -column $column -AccessModifier $Modifier
            $sb.AppendLine("`t`t$p") | Out-Null
        }

        $class = $classTemplate -replace '{properties}', $sb.Tostring()
        
        $class
    }
}

function New-EntityConfiguration
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $MetaData,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        $EntityConfigurationNamespace,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        $ModelNamespace,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateSet("public", "private", "internal", "sealed")]
        [Alias('AccessModifier')]
        $Modifier = 'public'        
    )

    Begin
    { 
        
    }
    Process
    {    
        $pk = ($MetaData.columns | Where-Object is_identity -eq 1).name

        $class = "
using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using $ModelNameSpace;

namespace $EntityConfigurationNamespace
{
    $Modifier class $($MetaData.name)TypeConfiguration : IEntityTypeConfiguration<$($MetaData.name)>
    {
        public void Configure(EntityTypeBuilder<$($MetaData.name)> builder)
		{
            builder.ToTable(`"$($MetaData.name)`");
			builder.HasKey(x => x.$pk);
        }
    }
}
"
        $class
    }
}

function New-IBuilder
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $MetaData,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        $ModelNamespace,

        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNull()]
        $InterfaceNamespace,

        [Parameter(Mandatory=$false, Position=3)]
        [ValidateSet("public", "private", "internal", "sealed")]
        [Alias('AccessModifier')]
        $Modifier = 'public'        
    )

    Begin
    { 
        $interfaceTemplate = "
using System;
using System.Collections.Generic;
using $ModelNamespace;

namespace $InterfaceNamespace
{
    $Modifier interface {interfaceName} : IBuilder<$($MetaData.name)>
    {
{properties}
    }
}
"
    }
    Process
    {    
        $interfaceName = "I$($MetaData.name)Builder"

        $class = $interfaceTemplate -replace '{interfaceName}', $interfaceName

        $sb = [System.Text.stringBuilder]::new()
        foreach($column in $MetaData.Columns){
            $dataType = Get-DataType -column $column

            $sb.AppendLine("`t`t$InterfaceName With$($column.name)($dataType $($column.name | To-CamelCase));") | Out-Null
        }

        $class = $class -replace '{properties}', $sb.Tostring()
        
        $class
    }
}

function New-Builder
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $MetaData,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        $BuilderNamespace,

        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNull()]
        $ModelNamespace,

        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNull()]
        $InterfaceNamespace,

        [Parameter(Mandatory=$false, Position=4)]
        [ValidateSet("public", "private", "internal", "sealed")]
        [Alias('AccessModifier')]
        $Modifier = 'public'        
    )

    Begin
    { 
        $classTemplate = "
using System;
using System.Collections.Generic;
using $ModelNamespace;
using $InterfaceNamespace;

namespace $BuilderNamespace
{
    $Modifier class {TableName}Builder : I{TableName}Builder
    {
        private {TableName} _instance;

		public {TableName}Builder()
		{
			_instance = new {TableName}();
		}

		public {TableName} Build()
		{
			return _instance;
		}

{properties}
    }
}
"
    }
    Process
    {    
        $class = $classTemplate

        $sb = [System.Text.stringBuilder]::new()
        foreach($column in $MetaData.Columns){
            
            $sb.AppendLine( $(Get-IBuilderProperty -column $column) ) | Out-Null
        }

        $class = $class -replace '{properties}', $sb.Tostring()
        $class = $class -replace '{TableName}', $MetaData.name

        $class
    }
}

