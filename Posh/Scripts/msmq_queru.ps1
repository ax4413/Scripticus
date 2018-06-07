param(
	$queue_name = ''
)
cls

$windowSize = 107

function New-Title( [string]$Title, [int]$PadWidth, [string]$PadChar="=" ) {
  $sb = New-Object -TypeName "System.Text.StringBuilder";

  $tempTitle = "{0} {1}" -f $PadChar, $Title

  if($PadWidth -eq 0 -or $PadWidth -lt ($Title.Length + 4)){ $PadWidth = $Title.Length + 4 }

  $sb.AppendLine("") | Out-Null
  $sb.AppendLine("".PadRight($PadWidth, $PadChar)) | Out-Null
  $sb.AppendLine($tempTitle.PadRight($PadWidth - $PadChar.Length, " ") + $PadChar) | Out-Null
  $sb.AppendLine("".PadRight($PadWidth, $PadChar)) | Out-Null

  return $sb.ToString()
}



New-Title -Title "Queues like - *$queue_name*" -PadWidth $windowSize

gwmi -Class Win32_PerfRawData_MSMQ_MSMQQueue | 
  Where { $_.Name -like "*$queue_name*" } | 
  sort Name | 
  ft -Prop Name, MessagesInQueue, BytesInQueue  -AutoSize



New-Title -Title "Busy Queues like - *$queue_name*" -PadWidth $windowSize

gwmi -Class Win32_PerfRawData_MSMQ_MSMQQueue | 
  Where { $_.Name -like "*$queue_name*" -and $_.MessagesInQueue -gt 0 } | 
  sort -Descending MessagesInQueue | 
  ft -Prop Name, MessagesInQueue, BytesInQueue  -AutoSize


  
New-Title -Title "Dead Letter Queues" -PadWidth $windowSize

gwmi -Class Win32_PerfRawData_MSMQ_MSMQQueue | 
  Where { $_.Name -like "Computer *" } | 
  sort -Descending MessagesInQueue | 
  ft -Prop Name, MessagesInQueue, BytesInQueue  -AutoSize  

