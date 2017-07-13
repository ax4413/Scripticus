<#
.Synopsis
   A tool to download files from the internet
.DESCRIPTION
   A tool to download files from the internet
.EXAMPLE
   Get-Download -uri 'https://downloads.sentryone.com/downloads/sqlsentryplanexplorer/x64/PlanExplorerInstaller.exe'
.EXAMPLE
   dl 'https://downloads.sentryone.com/downloads/sqlsentryplanexplorer/x64/PlanExplorerInstaller.exe'
.EXAMPLE
   dl 'https://fobar/baz' -DefaultFileExtension '.zip'   
#>
function Get-Download
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # The path to teh file you want
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
        [Alias("url", "exe")] 
        [System.Uri]
        $uri,

        # The location the download will be saved
        [Parameter(ParameterSetName='Parameter Set 1')]     
        [Alias("OutputLocation")] 
        [string]
        $DownloadFolder,

        # If no file extension can be identified we will use this
        [Parameter(ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
		[ValidateScript({$_ -like '.*'})]
        [string]
        $DefaultFileExtension = '.exe',

        [switch]$Force
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess($uri, "Download file"))
        {
            # default to using your downloads dir
            if(-not $DownloadFolder -or [String]::IsNullOrWhiteSpace($DownloadFolder)){
                 $DownloadFolder = Join-Path $env:USERPROFILE  'Downloads'
            }

            if(-not (Test-Path $DownloadFolder -PathType Container)){
                if($Force){
                    $null = New-Item $DownloadFolder -ItemType Directory -Force
                    Write-Verbose "The download folder '$DownloadFolder$downl' has been created."
                }else{
                    Write-Error "The download folder '$DownloadFolder$downl' does not exist. Exiting Get-Dowwnload early"
                    return
                }
            }

            $name = $uri.Segments[$uri.Segments.Length-1]

            if(-not $name){
                Write-Error "a name cannot be extracted from the uri provided"
                return
            }

            if(-not ([IO.Path]::GetExtension($name))){
                Write-Verbose "Missing file extension. Lets assume '$DefaultFileExtension'"
                $name += $DefaultFileExtension
            }

            # download the file
            $output = Join-Path $DownloadFolder $name
            Invoke-WebRequest -Uri $uri -OutFile $output
            return $output
        }
    }
    End
    {
    }
}


New-Alias dl Get-Download