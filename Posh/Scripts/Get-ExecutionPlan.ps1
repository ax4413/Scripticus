<#
.Synopsis
   Get a cached execution plan from from within sql server
.DESCRIPTION
   Get a cached XML execution plan from from within sql server query plan cache. This function is required when the xml query plan overflows the buffer used within SSMS.
.EXAMPLE
   Get-ExecutionPlan -SqlInstance localhost\denali -Database DBName -StoredProcedure SprocName
.EXAMPLE
   Get-ExecutionPlan -SqlInstance localhost\denali -Database DBName -Schema dbo -StoredProcedure SprocName -OutputFilePath C:\Temp 
.EXAMPLE
   Get-ExecutionPlan -InstanceName localhost\denali -DatabaseName DBName -Sproc SprocName -UserName sa -Password ####
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Applies to:  SQL Server 2008 
                SQL Server 2008 R2 
                SQL Server 2012 
   This cmdlet is an extension of teh work done by Patrick Keisler which can be found here http://www.patrickkeisler.com/                  
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

Function Get-ExecutionPlan {
    
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                   SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='low')]
    param (    
        #The server you wish to query 
        #
        [Parameter(Mandatory=$true,
                   #ValueFromPipeline=$true,
                   #ValueFromPipelineByPropertyName=$true,
                   #Position=0,
                   HelpMessage ="Please provide a valid sql server instance name e.g localhost\denali")]   
        [ValidateNotNullOrEmpty()]  
        [Alias("InstanceName")] 
        [string]   $SqlInstance,      

        #The database you wish to query
        [Parameter(Mandatory=$true,
                   HelpMessage ="Please provide a valid database name e.g AdventureWorks")]   
        [ValidateNotNullOrEmpty()]  
        [Alias("DatabaseName", "DBName")]  
        [string]   $Database,

        #The schema that the stored procedure belongs to. The defau;t schema is dbo 
        [Parameter(Mandatory=$false,
                   HelpMessage ="Please provide a valid schema name e.g dbo")]   
        [ValidateNotNullOrEmpty()]   
        [string]   $Schema = 'dbo', 
        
        #The stored procedure name you want to get a execution plan for
        [Parameter(Mandatory=$true,
                   HelpMessage ="Please provide a valid stored procedure name e.g Customer_Fetch")]   
        [ValidateNotNullOrEmpty()]   
        [Alias("StoredProcedureName", "Sproc")] 
        [string]   $StoredProcedure,
  
        #The location you want to save the .sqlplan to. If one is not supplied the context that this cmdlet
        #is executing in will be used
        [Parameter(Mandatory=$false,
                   HelpMessage ="Please provide a valid path to save the execution plan to e.g C:\Temp")]   
        [ValidateNotNullOrEmpty()]   
        [ValidateScript({Test-Path $_})]
        [string]   $OutputFilePath,

        #Switch to turn on opening the query plan with teh default application associated with .sqlplan
        [Parameter(Mandatory=$false)]  
        [Switch]  $OpenQueryPlan,

        #The sql login username. If none is provided we will attempt to connect using windows auth
        [Parameter(Mandatory=$false,
                   HelpMessage ="Please provide a valid sql logon username e.g sa")]   
        [string]  $UserName,

        #The sql login password. If none is provided we will attempt to connect using windows auth
        [Parameter(Mandatory=$false,
                   HelpMessage ="Please provide a valid sql logon password e.g password")]   
        [string]  $Password
    )  


    Begin{

        #Build the SQL Server connection objects 
        $conn = New-Object System.Data.SqlClient.SqlConnection 
        $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder 
        $cmd = New-Object System.Data.SqlClient.SqlCommand 
    }


    Process{
        if ($pscmdlet.ShouldProcess("$Database", "Get-ExecutionPlan for $StoredProcedure")) {
            
            try {   
                          
                if($OutputFilePath -eq $null) {
                    #Grab the path where the Powershell script was executed from. 
                    $path = Split-Path $MyInvocation.MyCommand.Path  
                } else {
                    $path = $OutputFilePath
                }
         

                # Build a sql server connection string
                $builder.psBase.DataSource = $SqlInstance 
                $builder.psBase.InitialCatalog = $Database 
                $builder.psBase.ApplicationName = "Get-ExecutionPlan" 
                $builder.psBase.Pooling = $true 
                $builder.psBase.ConnectTimeout = 15 
    
                if([string]::IsNullOrEmpty($UserName) -eq $false -and [string]::IsNullOrEmpty($UserName) -eq  $false) {
                    # initialize for sql authentication
                    $builder.psBase.IntegratedSecurity = $false
                    $builder.psBase.UserID =$UserName
                    $builder.psBase.Password = $Password
                    Write-Verbose "Attempting SQL authentication"
                } else {
                    # initialize for windows authentication
                    $builder.psBase.IntegratedSecurity = $true
                    Write-Verbose "Attempting windows authentication"
                }

                #Assign the sql server connection string
                $conn.ConnectionString = $builder.ConnectionString 
   

                #Build the TSQL statement & connection string, the[void] stops the default behaviour of writing the growing 4sb size to the console
                $sb = New-Object -TypeName "System.Text.StringBuilder"
                [void]$sb.AppendLine("USE [$Database]")
                [void]$sb.AppendLine("SELECT qp.query_plan")
                [void]$sb.AppendLine("FROM sys.dm_exec_procedure_stats ps")
                [void]$sb.AppendLine("INNER JOIN	 sys.objects o ON ps.object_id = o.object_id")
                [void]$sb.AppendLine("INNER JOIN	 sys.schemas s ON o.schema_id = s.schema_id")
                [void]$sb.AppendLine("OUTER APPLY sys.dm_exec_query_plan(ps.plan_handle) qp")
                [void]$sb.AppendLine("WHERE ps.database_id = DB_ID()")
                [void]$sb.AppendLine("AND s.name = '$Schema'")
                [void]$sb.AppendLine("AND o.name = '$StoredProcedure';")

                # Create a friendly view of the sql to ve executed
                $verboseDetail = "SQL to be executed `r`n" + $sb.ToString()   
                Write-Verbose $verboseDetail


                #Assign to the sql command a connection context and cmd string
                $cmd.Connection = $conn 
                $cmd.CommandText = $sb.ToString() 


                if ($conn.State -eq "Closed")  {                       
                    #Open a connection to SQL Server   
                    $conn.Open()  
                    Write-Verbose "SQL connection open"
                }    

        
                #Execute the TSQL statement  
                $Result = $cmd.ExecuteScalar()  
                Write-Verbose "SQL command executed" 

            
                #Write the output to a file  
                $FileName = $path + "\" + $Database + "__" + $StoredProcedure + ".sqlplan"  
                $stream = New-Object System.IO.StreamWriter($FileName)  
                $stream.WriteLine($Result)   
                Write-Output "SQL execution plan saved to $FileName"
            } 
            catch {         
             
                #Capture errors if needed  
                if ($_.Exception.InnerException)  {                          
                    Write-Error $_.Exception.InnerException.Message

                    if ($_.Exception.InnerException.InnerException) {    
                        Write-Error $_.Exception.InnerException.InnerException.Message
                    }  
                }  else  {                   
                    Write-Error $_.Exception.Message
                }    
            } 
            finally {

                if ($stream.BaseStream -ne $null)  {                               
                    #Close the stream object   
                    $stream.close()  
                    Write-Verbose "Stream closed"
                }   
        
                if ($conn.State -eq "Open")  {                              
                    #Close the SQL Server connection   
                    $conn.Close()  
                    Write-Verbose "SQL connection closed"
                }    
            }
        }
    }


    End {

        # If requested - open the execution plan in its default program
        # i need to call this cmd twice as the first time opens the app 
        # and the second the file. I am sure there is a better way of doing this
        if($OpenQueryPlan -and $pscmdlet.ShouldProcess("output.sqlplan (file name may change)", "Open file") -eq $true) {

            Invoke-Item $FileName
            Invoke-Item $FileName
        }
    }

}