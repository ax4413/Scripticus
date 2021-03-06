<#
.Synopsis
   Creates a byte representation of the dll as a string
.DESCRIPTION
   Creates a byte representation of the dll as a string
.EXAMPLE
   New-AssembleyBits -dll "C:\Users\syeadon\Desktop\IceNgSqlClr.dll"
.EXAMPLE
   New-AssembleyBits -dll "C:\Users\syeadon\Desktop\IceNgSqlClr.dll" | Out-File -FilePath "C:\Users\syeadon\Desktop\bits.txt"
#>
function New-AssembleyBits
{
    [CmdletBinding(DefaultParameterSetName='DefaultParameterSet', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='medium')]
    [OutputType([String])]
    Param
    (
        # The file path to the nuspec file
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='DefaultParameterSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateScript({Test-Path $_ -PathType 'leaf' -Filter "*.dll"})] 
		[string]
        $dll		
    )

    Begin
    {
		[string]$AssemblyBits = "0x"
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Return the dll as assembly bits"))
        {
            [System.IO.FileStream]$stream = New-Object IO.FileStream $dll ,'Open','Read','Read'
			
			[int]$currentByte = $stream.ReadByte()
			
			[System.Globalization.CultureInfo] $ci
			
			while ($currentByte -gt -1) {
				$AssemblyBits = $AssemblyBits + $currentByte.ToString("X2", $ci::InvariantCulture)
				$currentByte = $stream.ReadByte()
			}

			
			return $AssemblyBits 
        }
    }
    End
    {
    }
}


