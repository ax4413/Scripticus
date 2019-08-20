#function Write-Params($params, $template = "{0,-34} = {1}"){
#    $params.GetEnumerator() | Sort-Object -Property Key | 
#    ForEach-Object { write-host $($template -f $_.key, $_.value) }
#}

function Write-HostWithDate($message, $params, [switch]$NewLineBefore, [switch]$NewLineAfter){
  $message = $message -f $params
  $message = "{0:yyyy-MM-dd HH:mm:ss} - $message" -f (Get-Date)
  if($NewLineBefore) { Write-Host " "}
  write-host $message
  if($NewLineAfter) { Write-Host " "}
}


function Write-Header($Title = [int], $length = 34, [string] $padding = '=', [switch]$NewLineBefore, [switch]$NewLineAfter){
  $Title = "$($padding * 2) $Title "

  $paddingLength = 0
  if(($length - $Title.Length) -gt 0){
    $paddingLength = $length - $Title.Length 
  }

  $Title = "$Title$($padding * $paddingLength)"

  if($NewLineBefore) { Write-Host " "}
  Write-Host $Title
  if($NewLineAfter) { Write-Host " "}
}


function Write-SectionBreak([int] $length = 34, [string] $padding = '=', [switch]$NewLineBefore, [switch]$NewLineAfter){
  if($NewLineBefore) { Write-Host " "}
  Write-Host $($padding * $length)
  if($NewLineAfter) { Write-Host " "}
}


function Write-PsBoundParams
{    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        $params
    )
    try
    {
        $lineLength = 75        

        if($Params.Count -gt 0){
            $ColumnNameLength  = ($Params.GetEnumerator() | Select-Object -ExpandProperty key | Measure-Object -Maximum -Property Length).Maximum + 1

            $BoundParams.GetEnumerator() | Sort-Object $_.Key | ForEach-Object { 
                Write-Host (Format-Line -ColumnNameLength $ColumnNameLength -LineLength $lineLength -Key ($_.Key) -Value ($_.Value))
            }
        }
    }
    catch
    {
        Write-Host 'Write-ScriptParams() has encountered an error.' -ForegroundColor Red -BackgroundColor Black
        throw
    }
    
}


function Write-Params
{    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        $params
    )
    try
    {
        $lineLength = 75        

        if($Params.Count -gt 0){
            $ColumnNameLength  = ($Params.GetEnumerator() | Select-Object -ExpandProperty key | Measure-Object -Maximum -Property Length).Maximum + 1

            $BoundParams.GetEnumerator() | Sort-Object $_.Key | ForEach-Object { 
                Write-Host (Format-Line -ColumnNameLength $ColumnNameLength -LineLength $lineLength -Key ($_.Key) -Value ($_.Value))
            }
        }
    }
    catch
    {
        Write-Host 'Write-ScriptParams() has encountered an error.' -ForegroundColor Red -BackgroundColor Black
        throw
    }
    
}


Function Format-Line ([int]$ColumnNameLength, [int]$lineLength, $Key, $Value)
{
    try
    {
        $stdTemplate  = "{0,-$ColumnNameLength}: '{1}'"

        # if null
        if(-not $value){
            return ($stdTemplate -F $Key, 'NULL')
        }
        # Hashtables
        elseif($Value.GetType().Name -eq 'Hashtable'){
        
            $HashNameLength = 0
            $value.GetEnumerator() | Select-Object -ExpandProperty key |
            ForEach-Object {
                $str = $_ -as [System.String]
                if($str.Length -gt $HashNameLength){
                    $HashNameLength = $str.Length
                }
            }

            $HashNameLength += 1

            $hashLine   = ($stdTemplate -F $Key, $Value)
        
            $value.GetEnumerator() | Sort-Object key | ForEach-Object {
                $hashLine = $hashLine + "`r`n" + '- '.PadLeft($ColumnNameLength + 2) + ("{0,-$HashNameLength}= {1}" -F ($_.Key), ($_.Value))
            }

            return $hashLine
        }
        # Arrays
        elseif($Value.GetType().Name -eq 'Object[]'){        
            $values = $value.GetEnumerator()
            $i = 1
            $arrayLine += "".PadLeft(50,'=')
            $arrayLine += "`r`n"
            foreach($v in $values) {
                $arrayLine += $stdTemplate -f $key, "[$i/$($value.Count)]"
                $arrayLine += "`r`n"
                $arrayLine += Format-Line -ColumnNameLength $ColumnNameLength -lineLength $lineLength -Key '' -Value $v
                $arrayLine += "`r`n"
                $i++
            }
            $arrayLine += "".PadLeft(50,'=')
            return $arrayLine
        }
        # Object
        elseif($Value.GetType().Name -eq 'PSCustomObject'){ 
            $objProperties = $Value.PsObject.Members | Where-Object MemberType -eq 'NoteProperty'
            foreach($prop in $objProperties){
                $objLine += $stdTemplate -f $prop.Name, $prop.Value
                $objLine += "`r`n"
            }
            return $objLine
        }
        # strings, ints, etc
        else { 
            return ($stdTemplate -F $Key, $Value)
        }
    }
    catch
    {
        Write-Host 'Format-Line() has encountered an error.' -ForegroundColor Red -BackgroundColor Black
        throw
    }
}


function Write-HostWithError
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   PositionalBinding=$false,
                   ConfirmImpact='Medium')]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        $exceptions,

        [Parameter(Mandatory = $false, Position = 1)]
        [Alias('StatusCode')]
        [int]$exitCode,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$message = ""
    )
    Process
    {  
      $template = "{0,-21} : {1}"
      if(![string]::IsNullOrWhiteSpace($message)){
        Write-Host ($template -f 'Message', $message) -ForegroundColor Red -BackgroundColor Black
        Write-Host ""
      }

      foreach($e in $exceptions){
        $ex = $e.Exception
        if($ex){
          $exType = $ex.GetType()
          if($exType){
            Write-Host ($template -f 'Exception Type', $exType.FullName.Trim()) -ForegroundColor Red -BackgroundColor Black
          }
        }
        $errorMessage = ($e  | Format-List -Force | Out-String).Trim()
        Write-Host $errorMessage -ForegroundColor Red -BackgroundColor Black
      }

      if($PSBoundParameters.ContainsKey('exitCode')){
        Write-Host ($template -f "Error Code", $exitCode) -ForegroundColor Red -BackgroundColor Black
      }  
    }
}


function Write-HostWithPadding([string]$text, $length = 2, [string] $padding = ' ', [switch]$left, [switch]$right){
  $message = ''
  if($left){ $message += ($padding * $length)}
  $message += $text
  if($right){ $message += ($padding * $length)}
  Write-Host $message
}


function Safe-Text($text){
  if(-not($text)){
      "N/A"
  } else {
      $text
  }
}

