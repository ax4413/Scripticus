
function touch($path){
  new-item -path $path -type File
}



# load scripts from teh script dir
$PoshScriptsDir = join-path $env:USERPROFILE '.\Documents\WindowsPowerShell\Scripts'
# load all scripts ## Get-ChildItem "${PoshScriptsDir}\*.ps1" | % {.$_} 
# load some scripts
$scripts = @('downloader/Get-Download.ps1', 'Clear-SpecFlowCache')
$scripts | % { . $(Join-Path $PoshScriptsDir $_) } 
