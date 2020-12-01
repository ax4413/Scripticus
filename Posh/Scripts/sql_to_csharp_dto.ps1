cls

$instance  = '.'
$database  = 'DVVANZZZMain'
$namespace = "Migration.DataAccess.Entities.MigrationData"

$modelOutputDir = 'F:\Source\icenet-tools\data-migration\Tests\DataMigration.Domain\Main\Model\'
$modelNamespace = 'DataMigration.Domain.Main.Model'

$entityConfigurationOutputDir = 'F:\Source\icenet-tools\data-migration\Tests\DataMigration.Infrastructure\EntityConfigurations\Main\'
$entityConfigurationNamespace = 'DataMigration.Infrastructure.EntityConfigurations.Main'


$builderOutputDir = 'D:\temp\foo\DataMigration.Domain\ConfigurationData\Builder\'
$builderNamespace = 'DataMigration.Domain.ConfigurationData.Builder'

$interfaceOutputDir = 'D:\temp\foo\DataMigration.Domain\ConfigurationData\Builder\'
$interfaceNamespace = 'DataMigration.Domain.ConfigurationData.Builder'


$InformationPreference = 'Continue'


# load our functions
$functions = join-path $PSScriptRoot 'sql_meta_data_to_object_functions.ps1'
. $functions

# get the metadata
$tableMetaData = Get-TableMetaData -instance $instance -database $database -schema 'dbo' `
                                   -tables "ApplicationStatus", "TertiaryStatus"

# iterate over the metadata parsing it however we like
foreach($tableDefinition in $tableMetaData){
    $tableName = $tableDefinition.name

    if(-not(Test-Path $entityConfigurationOutputDir)){ New-Item -Path $entityConfigurationOutputDir -ItemType "directory" -Force }
    New-Model -MetaData $tableDefinition -ModelNamespace $modelNamespace -Modifier public | Out-File "$modelOutputDir\${tableName}.cs"

    if(-not(Test-Path $modelOutputDir)){ New-Item -Path $modelOutputDir -ItemType "directory" -Force }
    New-EntityConfiguration -MetaData $tableDefinition -EntityConfigurationNamespace $entityConfigurationNamespace -ModelNamespace $modelNamespace -Modifier public | Out-File "$entityConfigurationOutputDir\${tableName}TypeConfiguration.cs"

    #if(-not(Test-Path $interfaceOutputDir)){ New-Item -Path $interfaceOutputDir -ItemType "directory" -Force }
    #New-IBuilder -MetaData $tableDefinition -InterfaceNamespace $interfaceNamespace -ModelNamespace $modelNamespace -Modifier public | Out-File "$interfaceOutputDir\I${tableName}Builder.cs"
    #
    #if(-not(Test-Path $builderOutputDir)){ New-Item -Path $builderOutputDir -ItemType "directory" -Force }
    #New-Builder -MetaData $tableDefinition -BuilderNamespace $builderNamespace -InterfaceNamespace $interfaceNamespace -ModelNamespace $modelNamespace -Modifier public | Out-File "$builderOutputDir\${tableName}Builder.cs"
}