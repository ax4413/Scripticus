# http://www.mssqltips.com/sqlservertip/3232/using-powershell-to-scan-and-find-sql-server-database-connection-information-inside-ms-excel-files/
# Usefull links
# http://subjunctive.wordpress.com/2008/04/01/powershell-file-search/
# http://stackoverflow.com/questions/8677628/recursive-file-search-using-powershell
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/06/24/use-powershell-and-regular-expressions-to-search-binary-data.aspx
# http://social.msdn.microsoft.com/Forums/vstudio/en-US/77b0346d-37b3-4840-9df5-e1b74167aac9/byte-array-string-encoding?forum=clr



# turn off errors to screen, there will some with regard to path length, file system permissions or out of memory, etc.
$ErrorActionPreference = 'SilentlyContinue'

# setup search path
$SerachPath = 'C:\Temp\reports\'

# search the path putting results in collection in variable
$results = Try {
    Get-ChildItem -path $SerachPath -recurse -include (‘*.xls’, ‘*.xlsx’) | 
        Select-Object Fullname, Name, Extension, BaseName 
} 
Catch [system.exception]
{
    [system.exception].toString()
}

# Print number of files found
write-host "File count: $results.Count"

$Base = 'c:\temp\results\'
Remove-Item -Path $($Base + '*') -recurse -force

# loop through the collection and place results in directory depending on the extension for separate processing later
foreach ($row in $results){
    
    Write-Host "Processing file $($row.Name)"

    # if xls file process one way otherwise use the other method
    if ($row.Extension -eq '.xls') {
        # Create a xls sub folder
        $BaseDestination = Join-Path -Path $Base -ChildPath 'xls'

        if(!(Test-Path -Path $BaseDestination -PathType Container)){
            New-Item -Path $BaseDestination -ItemType Container }

        # Copy the excel file to temporary directory, which needs to exist
        $excelFilePath = $BaseDestination + $row.BaseName.ToString() + '.xls'
        Copy-Item -Path $row.Fullname.ToString() -Destination $excelFilePath
        
        # Get file from temporary directory
        $Stream = New-Object IO.FileStream -ArgumentList (Resolve-Path $excelFilePath), 'Open', 'Read'
        
        # Note: Codepage 28591 returns a 1-to-1 char to byte mapping
        $Encoding = [Text.Encoding]::GetEncoding(28591)
        $StreamReader = New-Object IO.StreamReader -ArgumentList $Stream, $Encoding
        $BinaryText = $StreamReader.ReadToEnd()
        $StreamReader.Close()
        $Stream.Close()
        $ind1 = $BinaryText.IndexOf('Provider=SQL')
        
        # $ind1
        if ($ind1 -gt 0) {
            $row.Fullname.ToString()
            $BinaryText.Substring($ind1, 256)
        }

        Remove-Item -Path $($BaseDestination + '*') -recurse -force
    }
    else
    {
		# Create a xlsx sub folder
        $BaseDestination = Join-Path -Path $Base -ChildPath 'xlsx'

        if(!(Test-Path -Path $BaseDestination -PathType Container)){
            New-Item -Path $BaseDestination -ItemType Container }

		# Copy the xlsx file to a temp location and save the file as a zip
        $ZipFilePath = $BaseDestination + $row.BaseName.ToString() + '.zip'
        Copy-Item -Path $row.Fullname.ToString() -Destination $ZipFilePath -Verbose
        
		# Open the zip
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($ZipFilePath)
        
		# Extract all of the zips content
        foreach($item in $zip.items()) {
            $shell.Namespace($BaseDestination).copyhere($item) }
        
		# This is the file we are looking for
        $connectionFilePath = Join-Path -Path $BaseDestination -ChildPath 'xl\connections.xml'
        
		# Read the xml file
        if (Test-Path -Path $connectionFilePath -PathType Leaf) {
            
			[xml]$xml = Get-Content $connectionFilePath
        	# looking for a sql connection
            if ($xml.connections.connection.dbPr.connection -ne $null -and `
				$xml.connections.connection.dbPr.connection.Contains('Provider=SQL') ) {
                write-host $row.Fullname.ToString()
                write-host $xml.connections.connection.dbPr.connection
            }
        }
        
		# tidy up
        Remove-Item -Path $($BaseDestination + '*') -recurse -force
    }
}