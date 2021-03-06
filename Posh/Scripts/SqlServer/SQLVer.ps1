# SQLVer.ps1
# usage: ./SQLVer.ps1
# Check SQL version
foreach ($svr in get-content "C:\ServerList.txt")
{
  $con = "server=$svr;database=master;Integrated Security=sspi"
  $cmd = "SELECT SERVERPROPERTY('ProductVersion') AS Version, SERVERPROPERTY('ProductLevel') as SP"
  
  $da = new-object System.Data.SqlClient.SqlDataAdapter ($cmd, $con)
  $dt = new-object System.Data.DataTable
  $da.fill($dt) | out-null
  
  $svr
  
  $dt | Format-Table -autosize
}