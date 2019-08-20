
# create new app pools and get web sites to use it


$webSiteName     = 'BtVanTestShAPP'
$baseAppPoolName = 'BtVanTestShIceNet4'
$userName        = 'ICECLOUDNP\BtVanTestShApp'
$password        = 'DdRcM4M7U3P5S7lp2k36lE2S5lKpxk'


foreach($application in @('HelpHost', 'ReschedulingService', 'SettlementService')){
  $webAppPoolName = "${baseAppPoolName}-${application}"

  if(!(Get-ChildItem -Path "IIS:\AppPools" | ? Name -eq $webAppPoolName)){
    New-WebAppPool -Name $webAppPoolName -Force | Out-Null
  }
      
  # set creds on teh app pool
  Set-ItemProperty -Path "IIS:\AppPools\$webAppPoolName" -Name ProcessModel -value @{userName="$userName";password="$password";identitytype=3} 

  # set the web application to use this app pool
  Set-ItemProperty -path "IIS:\Sites\${webSiteName}\${application}" -name "applicationPool" -value "$webAppPoolName"

  #Get-ItemProperty -path "IIS:\Sites\${webSiteName}\${application}" | fl *
}