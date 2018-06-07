function Blitz([string] $PathToDelete){
    if(-not (Test-Path $PathToDelete)) {
        Write-Error "Path $PathToDelete does not exist"
        exit
    }

    $folders = Get-ChildItem $PathToDelete -Directory -Force

    foreach ($folder in $folders) {
        Remove-Directory $folder
    }

    $folder = Get-Item -path $PathToDelete
    Remove-Directory $folder
}

function Remove-Directory($folder){
    if(-not $folder) {
        Write-Error "Path $folder does not exist"
        exit
    }
    
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

blitz 'F:\VAN\SYTrunk\Payment Service'