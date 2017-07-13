[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,Position=0)]
    [ValidateNotNullOrEmpty()]        
    [string]$url,
    
    [Parameter(Mandatory=$True,Position=1)]
    [ValidateNotNullOrEmpty()]   
    # the search string accepts wild cards and regex when in regex mode   
    [string]$searchPredicate,
    
    [switch]$IsRegex
)

function Get-SvnLogs($url){
    ([xml](Invoke-Expression "svn log $url --xml --verbose")).SelectNodes('//logentry')
}

function Query-SvnLog
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ValueFromRemainingArguments=$false, 
                   Position=0, ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
        $logs,

        # Param2 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, ValueFromRemainingArguments=$true, 
                   Position=1, ParameterSetName='Parameter Set 1')]
        $predicate,

        [switch]$IsRegex
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            if($IsRegex){
                $logs | Where-Object { $_.msg -match $predicate}    
            } else {
                $logs | Where-Object { $_.msg -like $predicate}    
            }
        }
    }
    End
    {
    }
}

function Match-Helper{
    if($IsRegex){
        "regex"
    } else {
        if(-not($searchPredicate.StartsWith('*')) -and (-not($searchPredicate.EndsWith('*')))){
            "exact"
        } else {
            "fuzzy"
        }
    }
}

function New-Header{
    Write-Host ""
    Write-Host "Attempting to search for a " -NoNewline
    Write-Host $((Match-Helper).ToUpper()) -ForegroundColor Red -NoNewline
    write-host " match on the text " -NoNewline
    Write-Host $searchPredicate -ForegroundColor Yellow
    write-host "in the commit message for the following svn logs"
    write-host $url -ForegroundColor Yellow
    Write-Host ""
}

$url = "https://10.1.2.33/svn/IceNet3.0/branches/3.10/src/Icenet.Database.Main"
$searchPredicate = '*vwSSAS_PaymentDetail*'

New-Header

#https://10.1.2.33/svn/IceNet3.0/branches/3.10/src/Icenet.Database.Main

Get-SvnLogs -url $url | Query-SvnLog -predicate $searchPredicate
