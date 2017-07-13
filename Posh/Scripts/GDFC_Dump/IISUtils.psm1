function Get-SitePath
{
  param(
    [Parameter(Mandatory=$true, 
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]
    $name
  )
  "IIS:\Sites\$name"
}

function Get-AppPoolPath
{
  Param(
    [Parameter(Mandatory=$true, 
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    $name
  )
  "IIS:\AppPools\$name"
}

Export-ModuleMember -Function Get-SitePath
Export-ModuleMember -Function Get-AppPoolPath