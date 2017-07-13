<#
$Dir= 'C:\Temp'

$FileTypesToInclued = @('*.txt', '*.sql')

$SearchPattern = 'poop'

Get-ChildItem -Path $Dir -include $FileTypesToInclued -Recurse | 
	Select-String -Pattern $SearchPattern | 
    Group-Object -Property Path | 
    Select-Object -Property Name
#>

<#
.Synopsis
   Get details about where and when in a file a particulr piece of text was located
.DESCRIPTION
   Get details about where and when in a file a particulr piece of text was located
.EXAMPLE
    $Dir = 'c:\temp'
    $SearchPattern = 'BlahBlahBlah'

    Get-FilesContainingText -Dir $Dir -SearchPattern $SearchPattern
.EXAMPLE
    $Dir = 'c:\temp'
    $SearchPattern = 'BlahBlahBlah'

    Get-FilesContainingText $Dir $SearchPattern
.EXAMPLE
    $Dir = 'c:\temp'
    $SearchPattern = 'BlahBlahBlah'
    $FileTypesToInclued = @('*.txt', '*.cs', '*.sql')

    Get-FilesContainingText -Dir $Dir -SearchPattern $SearchPattern -FileTypesToInclued $FileTypesToInclued
#>
Function Get-FilesContainingText {
	[CmdletBinding()]
    Param
    (
        # The directory we want to search
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias("DirectoryToSearch")] 
        [string]
        $Dir,

        # The text we want to search for
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [Alias("TextToLocate")] 
        [string]
        $SearchPattern,

        #  a collection of file types we wish to include in our search
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string[]]
        $FileTypesToInclued
    )

    Begin
    {
    }
    Process
    {
        Write-Host "Searching for '$SearchPattern' in '$Dir'" -NoNewline
		if($FileTypesToInclued.Count -ge 1) {
            Write-Host ", only $FileTypesToInclued will be included."
            Write-Host "This may take some time"

	    	Get-ChildItem -Path $Dir -include $FileTypesToInclued -Recurse | 
				Select-String -Pattern $SearchPattern | 
			    Group-Object -Property Path | 
			    Select-Object -Property Name
    	} else {
            Write-Host " against a unconstrained dataset."
            Write-Host "This may take some time"

    		Get-ChildItem -Path $Dir -Recurse | 
				Select-String -Pattern $SearchPattern | 
			    Group-Object -Property Path | 
			    Select-Object -Property Name
    	}
    }
    End
    {
    }
}
