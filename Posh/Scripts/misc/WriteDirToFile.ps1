# The directory containing your files 
$directory = "\\192.168.22.21\c$\inetpub\wwwroot"; 

# The text file to write filenames to (does not have to exist first) 
$txtFile = "C:\ps3.txt"   

# Get filenames from this directory 
# Get-ChildItem is aliased by 'dir' 
$files = Get-ChildItem $directory;   

# Loop through the files in the directory 
foreach($file in $files) 
{
	Add-Content $txtFile $file.Name; 
}