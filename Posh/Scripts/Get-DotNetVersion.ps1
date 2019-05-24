

# https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
function Get-DotNetFrameworkVersion {
    [CmdletBinding()]
    param(
        [string[]]$Computer = "localhost"
    )

    $ScriptBlockToRun = {
        $Release = Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | Get-ItemPropertyValue -Name Release 
    
        if($release -ge 461808)     { $NetFrameworkVersion = "4.7.2"}
        elseif($release -ge 460798) { $NetFrameworkVersion = "4.7.1"}
        elseif($release -ge 460798) { $NetFrameworkVersion = "4.7"  }
        elseif($release -ge 394802) { $NetFrameworkVersion = "4.6.2"}
        elseif($release -ge 394254) { $NetFrameworkVersion = "4.6.1"}
        elseif($release -ge 393295) { $NetFrameworkVersion = "4.6"  }
        elseif($release -ge 379893) { $NetFrameworkVersion = "4.5.2"}
        elseif($release -ge 378675) { $NetFrameworkVersion = "4.5.1"}
        elseif($release -ge 378389) { $NetFrameworkVersion = "4.5"  }
        else { $NetFrameworkVersion = ".Net 4.5 or later is NOT installed." }

        return [PSCustomObject]@{
            'Computer' = $env:COMPUTERNAME
            'Version'  = $NetFrameworkVersion
            'Release ' = $Release

        }
    }
    Write-Host "Retrieving .NET Framework Version Details..."
    if ($Computer -eq "localhost") { 
        . $ScriptBlockToRun
    } else {
        $RemoteSession = New-PSSession $Computer
        Invoke-Command -Session $RemoteSession -ScriptBlock $ScriptBlockToRun
    }
}


cls
Get-DotNetFrameworkVersion | fl

#Get-DotNetFrameworkVersion 'npsql01', 'npsql02', 'npsql03', 'npsql04', 'npsql05' | fl