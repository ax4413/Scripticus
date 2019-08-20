#https://www.powershellmagazine.com/2019/06/14/pstip-a-better-way-to-generate-http-query-strings-in-powershell/

function New-HttpQueryString
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Uri,

        [Parameter(Mandatory = $false)]
        [Hashtable]
        $QueryParameter = @{},

        [Parameter(Mandatory = $false)]
        [int]
        $Port = 80
    )

    Begin
    {
        Add-Type -AssemblyName System.Web
    }
    Process
    {
        # Create a http name value collection from an empty string
        $nvCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $QueryParameter.Keys | % { $nvCollection.Add($_, $QueryParameter.$_) }

        # Build the uri
        $uriRequest = [System.UriBuilder]$uri
        $uriRequest.Query = $nvCollection.ToString()
        $uriRequest.Port = $Port

        return $uriRequest.Uri.OriginalString
    }
    End
    {
    }
}




New-HttpQueryString -Uri http:\\foo.com #-QueryParameter @{'one'='a';'two'='b'}