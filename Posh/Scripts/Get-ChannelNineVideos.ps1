<#
.Synopsis
   Download channel 9 videos
.DESCRIPTION
   Download channel 9 videos from #param1 to #param2
.EXAMPLE
   Get-Channel9Videos -url "http://channel9.msdn.com/Series/advpowershell3" -dir "C:\Users\stephen.yeadon\Downloads\Powershell"
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   Use this cmdlet to download channel 9 videos
#>
function Get-Channel9Videos
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")]
        [Alias("url")] 
        [String]
        $url,


        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [Alias("OutputDir")] 
        [String]
        $outputDir,

        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidateSet("mp4high", "wmvhigh")]
        [Alias("VideoEncoding")]
        [String]
        $encoding
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            
            # Base directory
            $url = "http://channel9.msdn.com/Series/advpowershell3"

            # Location to download files to
            $outputDir = "C:\Users\stephen.yeadon\Downloads\Powershell\advpowershell3"

            # Append /RSS to the url
            $rssUrl = $url + "/RSS/" + $encoding

            # Get the feed
            $feed=[xml](New-Object System.Net.WebClient).DownloadString($rssUrl)

            # xml index
            $c = 0

            # get  the count of element sin the rss xml - i dont know a better way of doing this
            $t = 0
            foreach($q in $feed.rss.channel.item){
                $t++
            }


            # loop the rss element collection
            foreach($i in $feed.rss.channel.item) {

	            $c++;
	
                # get the download link
                $downloadUrl = New-Object System.Uri($i.enclosure.url)

                # let the user know what is going on
                Write-Output "Download File:".PadRight(15, " ") $downloadUrl.ToString()

                # define a file to be downloaded to
                $fileName = $downloadUrl.Segments[-1]
                $outputFilePath = Join-Path $outputDir $fileName

                # let the user know what is going on
                Write-Output "To:".PadRight(15, " ") $outputFilePath

	            # Verbose logging
	            Write-Verbose ""
	            Write-Verbose $i
	            Write-Verbose ""

    
                try{
                    # Create directory if required and download file
                    if ([IO.Directory]::Exists($outputDir)) { 
                        # Download file if we havent done so already
                        if (!(test-path $outputFilePath)){
                            (New-Object System.Net.WebClient).DownloadFile($downloadUrl, $outputFilePath) 
                        }
                    } 
                    else { 
                        # create the directory as it does not exist
                        New-Item -ItemType directory -Path $outputDir

                        # Download file if we havent done so already
                        if (!(test-path $outputFilePath)){
                            (New-Object System.Net.WebClient).DownloadFile($downloadUrl, $outputFilePath)
                        }
                    } 
        
                    # Add the newly downloaded file tyo an array
                    $downloadedFiles += @($outputFilePath)


                    # let the user know what is going on
                    Write-Output "Success file $c of $t downloaded"
                }
                catch{
                    # let the user know what is going on
                    Write-Outputt "Failure"
                }
                finally{
                    Write-Output ""
                }
            }
        }
    }
    End
    {
    }
}


<#
$feed=[xml](New-Object System.Net.WebClient).DownloadString("http://channel9.msdn.com/Events/MIX/MIX11/RSS")
foreach($i in $feed.rss.channel.item) {
    $url = New-Object System.Uri($i.enclosure.url)
    $url.ToString()
    $url.Segments[-1]
    (New-Object System.Net.WebClient).DownloadFile($url, $url.Segments[-1])
}
#>