$packagesDir = 'F:\Tools.ESB.Message.Injector\trunk\packages'

$PackagesWeWantToPush = @( 
    New-Object PSObject -Property @{ Version = '2.2.2'; Name = 'Microsoft.AspNet.SignalR' }
    New-Object PSObject -Property @{ Version = '2.2.2'; Name = 'Microsoft.AspNet.SignalR.Core' }
    New-Object PSObject -Property @{ Version = '2.2.2'; Name = 'Microsoft.AspNet.SignalR.JS' }
    New-Object PSObject -Property @{ Version = '2.2.2'; Name = 'Microsoft.AspNet.SignalR.SystemWeb' }
    New-Object PSObject -Property @{ Version = '9.4.7'; Name = 'NJsonSchema' }
    New-Object PSObject -Property @{ Version = '6.4.0'; Name = 'NServiceBus' }
    New-Object PSObject -Property @{ Version = '6.0.0'; Name = 'NServiceBus.CastleWindsor' }
    New-Object PSObject -Property @{ Version = '1.1.0'; Name = 'NServiceBus.Newtonsoft.Json' }
    New-Object PSObject -Property @{ Version = '2.1.3'; Name = 'NServiceBus.Persistence.Sql'}
    New-Object PSObject -Property @{ Version = '2.1.3'; Name = 'NServiceBus.Persistence.Sql.MsBuild' }
    New-Object PSObject -Property @{ Version = '3.0.1'; Name = 'ServiceControl.Plugin.Nsb6.Heartbeat' }
)


# add a property to describe what the file name would look like
$PackagesWeWantToPush | 
    % { $_ | Add-Member -MemberType ScriptProperty -Name FileNamne -Value { "$($this.Name).$($this.Version).nupkg"  } } 


# find packages on disk which meet our requirments
$PackagesToPush = Get-ChildItem -Path $packagesDir -Filter '*.nupkg' -Recurse | 
    where {$PackagesWeWantToPush.FileName.Contains($_.Name) }


# these are the files we want to publish
#$PackagesToPush | select Name


# push these file to nuget
$PackagesToPush | 
    % { & nuget push $_.FullName -Source http://nuget/api/odata -apiKey 03314021-b8dc-471c-9501-75a90d9d2599 }



