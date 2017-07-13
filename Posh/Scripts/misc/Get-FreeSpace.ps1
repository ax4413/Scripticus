function Get-FreeSpace{
    param([string] $HostName = ($env:COMPUTERNAME))

      Get-WmiObject win32_volume -computername $hostname  | `
            Where-Object {$_.drivetype -eq 3} | `
            Sort-Object name | `
            Format-Table name,@{l="Size(GB)";e={($_.capacity/1gb).ToString("F2")}},`
                              @{l="Free Space(GB)";e={($_.freespace/1gb).ToString("F2")}},`
                              @{l="% Free";e={(($_.Freespace/$_.Capacity)*100).ToString("F2")}}

}

#Usage
# Get-FreeSpace -HostName localhost


$servers = "OLTPPROD01","OLTPPROD02","OLTPPROD03","OLTPPROD04","OLTPPROD05"

Foreach ($s in $servers)
{
  Get-WmiObject Win32_LogicalDisk -ComputerName $s -Filter "DriveType=3" |
    #Where-Object {($_.FreeSpace/1GB) -lt 100 } |
    Select-Object @{LABEL='Comptuer';EXPRESSION={$s}},
            DeviceID,
            @{LABEL='Disk Size GB';EXPRESSION={"{0:N2}" -f ($_.Size/1GB)}},
            @{LABEL='Free Space GB';EXPRESSION={"{0:N2}" -f ($_.FreeSpace/1GB)}}
            #@{LABEL='Free Space %';EXPRESSION={"{0:N2}" -f (($_.FreeSpace/$_.Size)*100)}}
            #@{LABEL='Free Space %';EXPRESSION={"{0:P2}" -f ($_.FreeSpace/$_.Size)}}
            #Size,FreeSpace
}