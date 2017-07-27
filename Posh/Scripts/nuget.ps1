function invoke-nuget($id, $version, $source = 'http://nuget/api/', $destination = 'd:\temp'){
  if($version){
    nuget install $id -Version $version -Source $source -o $destination
  } else {
    nuget install $id -Source $source -o $destination
  }
}