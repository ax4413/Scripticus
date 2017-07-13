<#
	.SYNOPSIS
		Get-SqlFilteredErrorLog
	.DESCRIPTION
		Locate keywords in error log
	.PARAMETER serverInstance
		SQL Server instance
	.PARAMETER filter
		Keyword to use for filtering the search
	.PARAMETER errorLog
		Number of error log to search. Leave blank to search current
	.EXAMPLE
		.\Get-SqlFilteredErrorLog -serverInstance MyServer\SQL2012 -UserName steve -Password letMeIn -filter Error 
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#>

param (
	[string]$serverInstance = "$(Read-Host 'Server Instance' [e.g. Server01\SQL2012])",
	[string]$Username = "$(Read-Host 'Keyword UserName' [e.g. steve])",
	[string]$Password = "$(Read-Host 'Keyword Password' [e.g. LetMeIn])",
	[string]$filter = "$(Read-Host 'Keyword Filter' [e.g. Error])",
	[int]$logNumber = "$(Read-Host 'Log Number 0=Current' [e.g. 1])"
)

begin {
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
}
process {
	try {
		
		$mySrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
		$mySrvConn.ServerInstance=$serverInstance
		$mySrvConn.LoginSecure = $false
		$mySrvConn.Login = $Username
		$mySrvConn.Password = $Password
		
		$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $mySrvConn
		
		If ($logNumber -eq 0) {
			$output = $srv.ReadErrorLog() | where {$_.Text -like "$filter*"}		
		} else {
			$output = $srv.ReadErrorLog($logNumber) | where {$_.Text -like "$filter*"}		
		}			
		
		Write-Output $output
	}
	catch [Exception] {
		Write-Error $Error[0]
		$err = $_.Exception
		while ( $err.InnerException ) {
			$err = $err.InnerException
			Write-Output $err.Message
		}
	}
}