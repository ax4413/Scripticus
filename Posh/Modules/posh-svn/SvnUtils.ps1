function isSvnDirectory() {
  $location = Get-Location
  is-SvnDirectory -dir $location
  #return (test-path ".svn")
}

function is-SvnDirectory($dir) {
  #Write-Host "Testing $dir"
  if(test-path  "$dir\.svn"){
    return $true
  } else{
    $parent = (Get-item $dir).Parent
    if(-not $parent){
      return $false
    } else {
      is-SvnDirectory -dir $parent.FullName
    }
  }
}


function Get-SvnStatus {
  if(IsSvnDirectory) {
    $untracked  = 0
    $added      = 0
    $modified   = 0
    $deleted    = 0
    $missing    = 0
    $conflicted = 0
    $branch     = Get-SvnBranch

    svn status |
    foreach-object {
      $char = $_[0]
      switch($char) {
         'A' { $added++ }
         'C' { $conflicted++ }
         'D' { $deleted++ }
         'M' { $modified++ }
         'R' { $modified++ }
         '?' { $untracked++ }
         '!' { $missing++ }
      }
    }

    return @{ "Untracked"  = $untracked;
              "Added"      = $added;
              "Modified"   = $modified;
              "Deleted"    = $deleted;
              "Missing"    = $missing;
              "Conflicted" = $conflicted;
              "Branch"     = $branch}
   }
}

function Get-SvnBranch {
  $ErrorActionPreference = 'Stop'
  if(IsSvnDirectory) {
    try{
      $info = svn info
      $url = $info[2].Replace("URL: ", "") #URL: svn://server/repo/trunk/test
      $root = $info[4].Replace("Repository Root: ", "") #Repository Root: svn://server/repo

      $path = $url.Replace($root, "")
      $pathBits = $path.Split("/", [StringSplitOptions]::RemoveEmptyEntries)

      if($pathBits[0] -eq "trunk") {
        return "trunk";
      }
      if($pathBits[0] -match "branches|tags") {
        return "branch $($pathBits[1])"
      }
    }
    catch{
        #swallow exception
    }
  }
  $ErrorActionPreference = 'Continue'
}

function tsvn {
  if($args) {
    if($args[0] -eq "help") {
      #I don't like the built in help behaviour!
      $tsvnCommands.keys | sort | % { write-host $_ }

      return
    }

    $newArgs = @()
    $newArgs += "/command:" + $args[0]

    $cmd = $tsvnCommands[$args[0]]
    if($cmd -and $cmd.useCurrentDirectory) {
       $newArgs += "/path:."
    }

    if($args.length -gt 1) {
      $args[1..$args.length] | % { $newArgs += $_ }
    }

    tortoiseproc $newArgs
  }
}

