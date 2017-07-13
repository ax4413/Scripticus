get-childitem C:\SQL_Files\Backup\ -recurse |
  foreach-object {
    if ( $_.lastwritetime -lt [datetime]::Now.AddDays(-7) ) {
      remove-item $_.fullname } }
