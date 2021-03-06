clear
$feed = 'http://channel9.msdn.com/Feeds/RSS/mp4high'

$ErrorActionPreference = "Stop" 

# we need to be pointing at the mp4 high rss feed as we want the best quality files
if($feed.EndsWith("RSS/")) {
    $feed += "mp4high" }

if($feed.EndsWith("RSS")) {
    $feed += "/mp4high" }

if(!$feed.EndsWith("mp4high") -and !$feed.EndsWith("mp4high/")){
    Write-Error "This only works for microsoft channel 9 mp4 files " }

$xml=[xml](New-Object System.Net.WebClient).DownloadString($feed)

$objects=@()
$i = 1

Select-Xml -Xml $xml -XPath //item | 
    ForEach-Object {  $objects += New-Object –TypeName PSObject –Prop ( @{ 'Id'=$i++;
                                                                           'Title'=$_.Node.title; 
                                                                           'PublicationDate'=[DateTime]$_.Node.PubDate;
                                                                           # strip out html fluff
                                                                           'Description'=((([System.Web.HttpUtility]::HtmlDecode($_.Node.description)) -replace "<.*?>",'') -as [string]) ;
                                                                           'Summary'=(([System.Web.HttpUtility]::HtmlDecode($_.Node.summary)) -replace "<.*?>",'') ;
                                                                           # get the url to the video files for download
                                                                           'VideoUri'=if($_.Node.enclosure.url -ne $null -and $_.Node.enclosure.url -ne ''){ 
                                                                                        ([uri]($_.Node.enclosure.url))}
                                                                          } ) }


$objects

Write-Host "Download files? (Y,N)"
if((Read-Host).ToUpper() -eq "Y"){

	Write-Host "Which files do you want to download? e.g. 1 or 1,2,3,4"
	$input = Read-Host 
	$input = $input.Split(',').Trim()

	Write-Host "Where do you want to save your files?"
	$dir = Read-Host 

	if(!Test-Path $dir){
		New-Item $dir -ItemType Container | Out-Null
	}
	
	Set-Location $dir | Out-Null

	$objects | 
		Where-Object { $input.Contains($_.Id) } |
		foreach-object { if($_.VideoUri -ne $null){ 
	                		(New-Object System.Net.WebClient).DownloadFile($_.VideoUri, $_.VideoUri.Segments[-1]) } 
							#Invoke-WebRequest $_.VideoUri -OutFile $_.VideoUri.Segments[-1]
							}
}