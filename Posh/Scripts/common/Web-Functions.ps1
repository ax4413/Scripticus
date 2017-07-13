Add-Type -AssemblyName System.Web

function FromBase64([string]$str) {
  [text.encoding]::utf8.getstring([convert]::FromBase64String($str))
}
function ToBase64([string]$str) {
  [convert]::ToBase64String([text.encoding]::utf8.getBytes($str))
}
function UrlDecode([string]$url) {
  [Web.Httputility]::UrlDecode($url)
}
function UrlEncode([string]$url) {
  [Web.Httputility]::UrlEncode($url)
}
function HtmlDecode([string]$url) {
  [Web.Httputility]::HtmlDecode($url)
}
function HtmlEncode([string]$url) {
  [Web.Httputility]::HtmlEncode($url)
}

function Google-Query {
  Start-Process ('http://www.google.com/search?q=' + (UrlEncode ($args -join " ")))
}