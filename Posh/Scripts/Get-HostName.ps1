function Get-HostName([string]$ip)
{
	Write-Host ""
	Write-Host "${ip} resolves to" ([System.Net.Dns]::gethostentry($ip)).HostName
	Write-Host ""
}

## usage
##GetHostName -ip "192.168.21.143"