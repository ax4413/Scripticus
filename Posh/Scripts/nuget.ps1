function nuget-install($id, $version, $source = 'http://nuget/api/', $destination = 'd:\temp'){
  if($version){
    nuget install $id -Version $version -Source $source -o $destination
  } else {
    nuget install $id -Source $source -o $destination
  }
}

function nuget-list($id, $source = 'http://nuget/api/'){
  nuget list $id -Source $source -AllVersions
}