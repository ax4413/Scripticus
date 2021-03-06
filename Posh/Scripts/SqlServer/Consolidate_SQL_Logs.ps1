$DebugPreference = "Continue"

clear

# #### Get the last run date ##########################################################################################################################################

Write-Host "Getting last run date..."

$connectionString = "Server=CIHwsql0dv\dev0;Database=GreenDealMainQA;Trusted_Connection=True;"
$query = "select min(StartDate) LastRunDate from application"

# Create a sql connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Create a sql command
$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()

#Create and fill the data table    
$table = new-object “System.Data.DataTable”
$table.Load($result)

#Get the only data row returned and extract the last run date
$DataRow = $table | Select-Object LastRunDate
$LastRunDate = Get-Date $DataRow.LastRunDate

#Close the sql connection
$connection.Close()

Write-Host "Last Run $LastRunDate"




# #### Get the event logs #############################################################################################################################################

Write-Host "Getting event data..."

#Get all of the Application Event Logs that are fopr SQL server which are of type error or warning that have occured since the last run date
$Events = Get-EventLog -LogName Application | 
 	          Where-Object{($_.TimeWritten -ge $LastRunDate) -and ($_.Source -like "MSSQL*") -and ($_.EntryType -eq "Error" -or $_.EntryType -eq "Warning*")} | 
 	          Select-Object Index, Category, MachineName, Source, EntryType, TimeGenerated, TimeWritten, Message, ReplacementStrings
    
   
    
    
# #### Write data to sql database #####################################################################################################################################
Write-Host "Setting event data..."     

$connectionString = "Server=CIHwsql0dv\dev0;Database=BPFReportingQA_SY;Trusted_Connection=True;"
$query = @"
INSERT INTO [dbo].[EventLogStaging] ([RecordNumber], [Category], [ComputerName], [EventType], [Message], [SourceName], [TimeGenerated], [TimeWritten]) 
	SELECT	new.[RecordNumber], new.[Category], new.[ComputerName], new.[EventType], new.[Message], new.[SourceName], new.[TimeGenerated], new.[TimeWritten]
    FROM	(SELECT	[RecordNumber]	= #RecordNumber#, 
					[Category]		= '#Category#', 
					[ComputerName]	= '#ComputerName#', 
					[EventType]		= '#MessageType#', 
					[Message]		= '#Message#', 
					[SourceName]	= '#Source#', 
					[TimeGenerated]	= '#TimeGenerated#', 
					[TimeWritten]	= '#TimeWritten#') new
			LEFT OUTER JOIN [dbo].[EventLogStaging] els
					ON  els.[RecordNumber] = new.[RecordNumber]
						AND els.[ComputerName] = new.[ComputerName]
	WHERE	els.Id IS NULL
;
"@


# Create a sql connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Create a sql command
$command = $connection.CreateCommand()


foreach($Event in $Events)
{
    $tmpQuery = $query
    $tmpQuery = $tmpQuery -replace "#RecordNumber#", $Event.Index
    $tmpQuery = $tmpQuery -replace "#Category#", $Event.Category
    $tmpQuery = $tmpQuery -replace "#ComputerName#", $Event.MachineName
    $tmpQuery = $tmpQuery -replace "#MessageType#", $Event.EntryType
    
    $msg = "Message: [" + ($Event.Message -replace "'", "''") + "] /r/n" 
    $msg = $msg + "Additional Detail: [" + ($Event.ReplacementStrings -replace "'", "''") + "]"
    
    $tmpQuery = $tmpQuery -replace "#Message#", $msg
    $tmpQuery = $tmpQuery -replace "#Source#", $Event.Source
    $tmpQuery = $tmpQuery -replace "#TimeGenerated#", $Event.TimeGenerated.ToString("yyyyMMdd HH:mm:ss")
    $tmpQuery = $tmpQuery -replace "#TimeWritten#", $Event.TimeWritten.ToString("yyyyMMdd HH:mm:ss")
    
    Write-Debug ""
    Write-Debug $tmpQuery

    $command.CommandText = $tmpQuery
    $command.ExecuteNonQuery() | Out-Null
}


#Close the sql connection
$connection.Close()

Write-Host "Complete"