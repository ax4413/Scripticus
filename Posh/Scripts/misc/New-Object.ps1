$a = @() # array
$h = @{} # hashtable

# make a new object the verbose way
get-process s* | % { $obj = New-Object -TypeName PSObject
                     $obj | Add-Member –MemberType NoteProperty –Name ProcessName –Value $_.ProcessName
                     $obj | Add-Member –MemberType NoteProperty –Name Path –Value $_.Path
                     Write-Host $obj  }


## ######################################################################################################################

# use a hash table to make a new object more succinct
get-process s* | % { $properties = @{'ProcessName'=$_.ProcessName; 'Path'=$_.Path}
                     $object = New-Object –TypeName PSObject –Prop $properties
                     Write-Host $object }


## ######################################################################################################################

# very shorthand way to create object
get-process s* | % { $object = New-Object –TypeName PSObject –Prop (@{'ProcessName'=$_.ProcessName; 'Path'=$_.Path})
                     Write-Host $object }


## ######################################################################################################################

# shorthand way to create new objects and add them to a array
get-process s* | % { $objects=@() } 
                   { $objects += New-Object –TypeName PSObject –Prop ( @{ 'ProcessName'=$_.ProcessName; 'Path'=$_.Path } ) }
$objects


## ######################################################################################################################

# add a script property to the new ps obj
get-process s* | % { $obj = New-Object -TypeName PSObject
                     $obj | Add-Member –MemberType NoteProperty –Name ProcessName –Value $_.ProcessName
                     $obj | Add-Member –MemberType NoteProperty –Name Path –Value $_.Path
                     $obj | Add-Member -MemberType ScriptProperty -Name Dir -Value {
                                [string](Get-ChildItem -Path $_.Path | Select-Object Directory)
                            }
                     Write-Host $obj  }


## ######################################################################################################################

# add a script method to a object. if you call the method without a paramater you will be prompted for one.
$proxy = New-Object -TypeName PSObject
$proxy | Add-Member -MemberType ScriptMethod -Name GetItemType -Value {
            .{
                param (
                    [Parameter(Mandatory=$true)]
                    [ValidateNotNullOrEmpty()]
	                [string]$Name
                )
                "return $Name"
            } @args
        } -PassThru


$proxy.GetItemType('foo')


## ######################################################################################################################

$x = New-Object PSObject |
	Add-Member -MemberType NoteProperty -Name RDCollectionName -Value "RemoteApps" -PassThru |
	Add-Member -MemberType NoteProperty -Name DomainName -Value $DomainName -PassThru |
	Add-Member -MemberType NoteProperty -Name RDCollectionDescription -Value "Remote Desktop Apps Collection" -PassThru |
	Add-Member -MemberType NoteProperty -Name Tenant -Value $tenant -PassThru |
	Add-Member -MemberType NoteProperty -Name FolderName -Value "${ClientName}${UniqueIdentifier}" -PassThru |
	Add-Member -MemberType NoteProperty -Name RemoteDesktopAppDisplayName -Value $DisplayName -PassThru |
	Add-Member -MemberType NoteProperty -Name RemoteDesktopAppExeFileDir -Value $RemoteDesktopAppExeFileDir -PassThru |
	Add-Member -MemberType NoteProperty -Name RemoteDesktopAppExecutableFile -Value $ExecutableFile -PassThru |
	Add-Member -MemberType NoteProperty -Name RemoteDesktopAppAlias -Value $RemoteDesktopAppAlias -PassThru |
	Add-Member -MemberType ScriptProperty -Name UserGroups -Value {
		if ($this.RemoteDesktopAppDisplayName -eq "Icenet 4 SmartClient") {
			@("$($this.DomainName)\Domain Admins", "$($this.DomainName)\SG-RDS EQCS $($this.Tenant) Users")
		}
		else {
			@("$($this.DomainName)\Domain Admins", "$($this.DomainName)\SG-RDS EQCS $($this.Tenant) Users", "$($this.DomainName)\SG-RDS Client $($this.Tenant) Users")
		}
	} -PassThru |
	Add-Member -MemberType ScriptMethod -Name ToParams -Value {
		param([string]$ConnectionBroker)
		$params = @{
			'ConnectionBroker' = $ConnectionBroker ;
			'Alias'            = $this.RemoteDesktopAppAlias ;
			'DisplayName'      = $this.RemoteDesktopAppDisplayName ;
			'FilePath'         = $this.RemoteDesktopAppExecutableFile ;
			'FolderName'       = $this.FolderName ;
			'ShowInWebAccess'  = 1 ;
			'CollectionName'   = $this.RDCollectionName ;
			'IconPath'         = $this.RemoteDesktopAppExecutableFile ;
		}

		if ($this.UserGroups -and $this.UserGroups.Count -gt 0) {
			$params.Add('UserGroups', $this.UserGroups)
		}
		return $params
	} -PassThru

$x.ToParams('blahblahblah')


## ######################################################################################################################

# A collection of of our templates and their meta data
$templates=@()

$templates += New-Object –TypeName PSObject –Prop ( @{ 'Application'= 'ActivationProcessService';
                                                       'Environment'= 'QA'
                                                       'Client'     = 'VirginMedia'
                                                       'Instance'   = '505295-SSCLUQA'} )
$templates += New-Object –TypeName PSObject –Prop ( @{ 'Application'= 'BankPaymentRequestService';
                                                       'Environment'= 'QA'
                                                       'Client'     = 'VirginMedia'
                                                       'Instance'   = '505295-SSCLUQA'} )

# Add some additional properties to the custom objects
foreach($t in $templates) {
    $t | Add-Member -MemberType ScriptProperty -Name FullName -Value { (Get-ChildItem ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0}\{1}", $Root, $this.Application)) | select -First 1 -ExpandProperty FullName) }
    $t | Add-Member -MemberType ScriptProperty -Name DirectoryPath -Value { (Split-Path ($this.FullName)) }
    $t | Add-Member -MemberType ScriptProperty -Name FileName -Value { ([System.IO.Path]::GetFileName($this.FullName)) }
}


## ######################################################################################################################

function Property-Exists($obj, $property){
    if ($obj.PSObject.Properties.Match($property).Count) {
      $true
    } else {
      $false
    }
}


## ######################################################################################################################

# new up an object the new and easy way PoSH v3++ (these are note properties)
[PSCustomObject]@{
   'Application'= 'ActivationProcessService';
   'Environment'= 'QA'
   'Client'     = 'VirginMedia'
   'Instance'   = '505295-SSCLUQA'
}


## ######################################################################################################################
