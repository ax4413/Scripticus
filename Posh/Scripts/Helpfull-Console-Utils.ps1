

# Makes our command prompt look pretty
function Prompt() {
  write-host $(get-location) -ForegroundColor Green
  "PS>"
}


# kind of alias new-item
function touch($path){
  new-item -path $path -type File
}


# Fix issues with the file system
function Set-FilePermissions
{
  [CmdletBinding()]
  Param
  (
    # the path to fix the file permissions for
    [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [string] $path, 

    # the user/group to assign permissions to
    [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                Position=1)]
    [string] $user ="Users"
  )

  Begin
  {
  }
  Process
  {
    if(-not $path){
      Write-Verbose "No location supplied using the current location"
      $path = Get-Location | Select-Object -ExpandProperty Path
    } 
    
    if(-not (Test-Path $path -PathType Container)) {
      Write-Error "Error - Invalid path supplied $path"
    }
    
    $args = @(  $path 
              , "/grant"
              , ":r"
              , "$user`:(OI)(CI)F"
              , "/T"  )

    write-host "Executing - icacls $args" -ForegroundColor Green
    #EchoArgs.exe icacls $args
    
    icacls $args

    if($LASTEXITCODE -ne 0){
      Write-Error "Error - icacls failed with error code '$LASTEXITCODE'"
    }
  }
  End
  {
  }
}

