

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
function Set-FilePermisions($path, $user ="Users"){
	$args = @( $path 
		 , "/grant"
		 , ":r"
		 , "$user`:(OI)(CI)F"
		 , "/T" )
	
    write-host "Executing - icacls $args" -ForegroundColor Green
    #EchoArgs.exe icacls $args
    
    icacls $args
}