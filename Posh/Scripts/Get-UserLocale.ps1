cls

# tags  : powershell-remoting, wmi, scriptblock, unary array construction

function Get-UserLocale{
  [CmdletBinding(DefaultParameterSetName='ParameterSet1', PositionalBinding=$false)]
  Param (
    [string[]]$UserName, 
    [string[]]$ComputerName = 'localhost'
  )
  $ScriptBlockToRun = {
    Param($users)     
    $registry_query_template = "Registry::HKEY_USERS\{0}\Control Panel\International"
    
    foreach($user in $users) {
      $registry_query = $registry_query_template -f $user.sid
      Get-ItemProperty $registry_query -ErrorAction SilentlyContinue | 
      select @{name='User'; Ex={$user.Name}}, @{name='SID'; Ex={$user.SID}}, Locale, LocaleName
    }
  }

  $query = "select * from Win32_UserAccount where $(($UserName | % { "name = '$_'"}) -join ' OR ')"
  Write-Verbose "wmi query = $query"

  # this command cant be issued through remoting ???
  $usersArray = Get-WmiObject -ComputerName $ComputerName -Query $query

  if($ComputerName -eq 'localhost'){
    . $ScriptBlockToRun -users $usersArray
  }else {
    $session = New-PSSession -ComputerName $ComputerName
    # comma needed to force the var as a single aray not stream of items
    # see: https://stackoverflow.com/questions/55281599
    Invoke-Command -Session $session -ScriptBlock $ScriptBlockToRun -ArgumentList (,$usersArray) 
    $session | Remove-PSSession
  }
}

Get-UserLocale -UserName 'SVC-BTMSSQL', 'SVC-TSMSSQL' #-ComputerName 'NPSQL01', 'NPSQL02', 'NPSQL03', 'NPSQL04', 'NPSQL05' #| sort 
