$base = 'F:\VAP\ZSY\_____________________________________________'

$folders = Get-ChildItem $base -Directory -Force

foreach ($folder in $folders)
{
  $group = New-Object System.Security.Principal.NTAccount("BUILTIN", "Administrators")
  $path = $folder.FullName

  $acl = Get-Acl $path
  $acl.SetAccessRuleProtection($True, $False)

  $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($group,"FullControl","ContainerInherit, ObjectInherit","None","Allow")

  $acl.SetOwner($group)
  $acl.SetAccessRule($accessRule)

  $acl | Set-Acl $path

  Remove-Item -Recurse -Force $path
}

Remove-Item -Recurse -Force $base