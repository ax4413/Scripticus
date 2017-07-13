function Get-ProjectPath{
    param(
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$rootPath,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$subPath,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$projectName
    )
    "$rootPath\$subPath\$projectName.csproj"
}

function Get-AppUrl{
    param(
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$serverRoot,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$subPath
    )
    "http://$serverRoot/$subPath"
}


<#
.Synopsis
    Repoints the IIS endpoint used by a project file
.DESCRIPTION
    Repoints the IIS endpoint used by a project file to prevent Visual Studio from repointing the web application upon opening. 
.EXAMPLE
    Invoke-RepointIISUrl -ProjectFile c:\project.csproj -CurrentUrl 'http://localhost/project' -Url 'http://localhost/newproject'
.NOTES
    If the project's IISUrl doesn't match $CurrentUrl, nothing happens.
#>
function Invoke-RepointIISUrl
{
    [CmdletBinding(
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [String] $ProjectFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $CurrentUrl,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $Url
    )

    Begin
    {
    }
    Process
    {
        $info = "$projectFile "
        $changed = $false
        
        $xmlns = @{dns= 'http://schemas.microsoft.com/developer/msbuild/2003'}
        $proj = [xml](Get-Content $ProjectFile)

        $items = Select-Xml -Xml $proj -XPath '//dns:IISUrl' -Namespace $xmlns

        $items | ForEach-Object { 
            $node = $_.Node
            if(($node -ne $null) -and ($node.NodeType -eq "Element")){            
                if($node.InnerXml -eq $CurrentUrl){
                    $info += "IISUrl matches $currentUrl, changing to $Url"
                    $changed = $true
                    $node.InnerXml = $Url
                }
                else {
                    $info += "IISUrl doesn't match $CurrentUrl, skipping"
                }
            }
            else {
                $info += "IISUrl Element not found, skipping"
            }
        }

        if ($pscmdlet.ShouldProcess($info, "Repoint IIS Url"))
        {
            if($changed){
                $proj.Save($ProjectFile)
            }
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Invoke-RepointProject
{
    [CmdletBinding(SupportsShouldProcess=$true,
                   PositionalBinding=$false)]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]        
        [String]$ProjectRootPath,
        [Parameter(Position=1)]
        [String]$ProjectSubPath,
        [Parameter(Position=2)]
        [String]$ProjectName,
        [Parameter(Position=3)]
        [String]$CurrentHost,
        [Parameter(Position=4)]
        [String]$NewHost,
        [Parameter(Position=5)]
        [String]$UrlSubPath
    )

    Begin
    {
    }
    Process
    {
        $currentUrl = Get-AppUrl $CurrentHost $UrlSubPath
        $newUrl = Get-AppUrl $NewHost $UrlSubPath

        Get-ProjectPath $ProjectRootPath $ProjectSubPath $ProjectName |
            Invoke-RepointIISUrl -CurrentUrl $currentUrl -Url $newUrl

    }
    End
    {
    }
}

Export-ModuleMember Invoke-RepointIISUrl
Export-ModuleMember Invoke-RepointProject