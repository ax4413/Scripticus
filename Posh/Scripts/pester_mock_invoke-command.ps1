function Get-NextFreeIp($Machines, $IpAddresses) {
	<# simplified the logic #>
	foreach ($ip in $IpAddresses) {
		$status = Invoke-Command -ComputerName $Machines -ScriptBlock { param($_ip) Test-Connection $_ip -Count 1 -Quiet } -ArgumentList $ip

		if ($status -eq $false) {
			return $ip
			break
		}
	}
}

Describe "Get-NextFreeIp" {
	It "When ip equals 192.168.0.10 return false" {
		Mock Invoke-Command { $true }
		Mock Invoke-Command { $false } -ParameterFilter { $ArgumentList[0].IPAddress -eq '192.168.0.10' }
		$nextIp = Get-NextFreeIp -Machines 'm01', 'm02' -IpAddresses @(1..50 | ForEach-Object { [PSCustomObject]@{ IPAddress = "192.168.0.$_" } })
		$nextIp.IPAddress | Should be '192.168.0.10'
	}
}