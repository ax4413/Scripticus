$process = Get-Process
$cpu = $process | Sort-Object CPU -Descending | Select-Object -First 5
$ws  = $process | Sort-Object WorkingSet -Descending | Select-Object -First 5

$a = @()
$a += $cpu
$a += $ws

$a | Sort-Object id -Unique


Write-Host "--------------------------------------------------------------------------"


$a | Sort-Object Id |
        Select-Object 'Handles', 'NPM', 'PM', 'WS', 'VM', 'CPU', 'Id', 'ProcessName' -Unique | 
            Format-Table @{n='Handles'; ex={$_.Handles}; align='right'; width=10} ,
                         @{n='NPM'; ex={$_.NPM}; align='right'; width=7}, 
                         @{n='PM'; ex={$_.PM}; align='right'; width=15}, 
                         @{n='WS'; ex={"{0:N2}" -f $_.WS}; align='right'; width=17},
                         @{n='VM'; ex={$_.VM}; align='right'; width=15}, 
                         @{n='CPU'; ex={"{0:N2}" -f $_.CPU}; align='right'; width=12},
                         @{n='Id'; ex={$_.Id}; align='right'; width=7}, 
                         @{n='ProcessName'; ex={$_.ProcessName}; align='right'; width=20} -wrap 