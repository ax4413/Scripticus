function ConverTo-JsonWithOutEncoding($text){
    $text | ConvertTo-Json -Depth 50 | % { [System.Text.RegularExpressions.Regex]::Unescape($_) }
}

function Get-WebSiteApplication($websiteName){
    $bindings = @(((Get-Website -Name $websiteName | select -ExpandProperty bindings | select -ExpandProperty  collection)[0].BindingInformation) -split ':')

    $protocol = $(if($bindings[0] -eq 443){'https'}else{'http'})
    $wsn      = $bindings[2]
    $fqws     = "${protocol}://${wsn}"

    write-Information "Retrieving webapplications for '$fqws' ..."
    Write-Information " "

    Get-WebApplication -Site $websiteName | select @{l='Address'; ex={ "$fqws$($_.Path)/metrics/health"}} | select -ExpandProperty Address
}

function Summerise-Endpoint {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $Result
    )
    
    $statusColour = [ConsoleColor]::Red
    if($result.IsHealthy -eq 'True') { $statusColour = [ConsoleColor]::Green }

    Write-Host "Endpoint:  $($result.Endpoint)"
    Write-Host "IsHealthy: " -NoNewline
    Write-Host "$($result.IsHealthy)" -ForegroundColor $statusColour
}

function Test-Endpoint {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $Endpoint
    )
    
    Process
    {
        try{
            $result = Invoke-RestMethod -Uri $Endpoint

            $result = [PSCustomObject]@{
                'Endpoint'   = ''
                'ISHealthy' = $result.IsHealthy
                'Healthy'   = $result.Healthy
                'UnHealthy' = $result.UnHealthy
            }
        }
        catch{
            $result = [PSCustomObject]@{
                'Endpoint'   = ''
                'ISHealthy' ='False'
                'Healthy'   = ''
                'UnHealthy' = $_.ToString()
            }
        }

        $result.Endpoint = $Endpoint
        
        $result | Summerise-Endpoint
                   
        Write-Information "Healthy:   $(ConverTo-JsonWithOutEncoding $result.Healthy)"
        Write-Information "UnHealthy: $(ConverTo-JsonWithOutEncoding $result.UnHealthy)"
        write-Information " "
        write-Information "==========================================================================="
        write-Information " "
        write-Information " "

        write-host " "

        #$result
    }
}



cls
Get-WebSiteApplication -websiteName 'bttstoct18*' | Test-Endpoint