<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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
   The functionality that best describes this cmdlet
#>
function Invoke-ExecuteNonQuery
{
    [CmdletBinding(DefaultParameterSetName='WindowsAuthentication',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # The SQL instance that you want to connect to
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Server")]
        [Alias("ServerName")]
        [Alias("Instance")]
        [string]
        $InstanceName,

        # The database that you want to connect to
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Database")]
        [string]
        $DatabaseName,

        # The location of our files
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $SqlStatement,

        # The SQL logon (username) that you want to use to connect to the instance
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=3,
                   ParameterSetName='SQLAuthentication')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("SqlUserName")]
        [Alias("UserName")]
        [string]
        $SqlLogonName,

        # The SQL password that you want to use to connect to the instance
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=4,
                   ParameterSetName='SQLAuthentication')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Password")]
        [string]
        $SqlPassword
    )

    Begin
    {
        switch ($PsCmdlet.ParameterSetName)
        {
            "WindowsAuthentication"  {
                Write-Verbose -Message "Connecting to $InstanceName by windows authentication"
                $connectionString = "Server=$InstanceName;Database=$DatabaseName;Trusted_Connection=True;"
                break
            }
            "SQLAuthentication"  {
                Write-Verbose -Message "Connecting to $InstanceName by sql authentication'"
                $connectionString = "Server=$InstanceName;uid=$SqlLogonName; pwd=$SqlPassword;Database=$DatabaseName;Integrated Security=False;"
            }
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Execute sql against $InstanceName\$DatabaseName"))
        {
            $connection = New-Object System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $connectionString
            $connection.Open()
            $command = $connection.CreateCommand()
            $command.CommandText  = $SqlStatement

            $count = $command.ExecuteReader()

            Write-Verbose "Command executed. $count records affected"
        }
    }
    End
    {
    }
}



<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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
   The functionality that best describes this cmdlet
#>
function Invoke-ExecuteReader
{
    [CmdletBinding(DefaultParameterSetName='WindowsAuthentication',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # The SQL instance that you want to connect to
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Server")]
        [Alias("ServerName")]
        [Alias("Instance")]
        [string]
        $InstanceName,

        # The database that you want to connect to
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Database")]
        [string]
        $DatabaseName,

        # The location of our files
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $SqlStatement,

        # The SQL logon (username) that you want to use to connect to the instance
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=3,
                   ParameterSetName='SQLAuthentication')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("SqlUserName")]
        [Alias("UserName")]
        [string]
        $SqlLogonName,

        # The SQL password that you want to use to connect to the instance
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=4,
                   ParameterSetName='SQLAuthentication')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Password")]
        [string]
        $SqlPassword
    )

    Begin
    {
        switch ($PsCmdlet.ParameterSetName)
        {
            "WindowsAuthentication"  {
                Write-Verbose -Message "Connecting to $InstanceName by windows authentication"
                $connectionString = "Server=$InstanceName;Database=$DatabaseName;Trusted_Connection=True;"
                break
            }
            "SQLAuthentication"  {
                Write-Verbose -Message "Connecting to $InstanceName by sql authentication'"
                $connectionString = "Server=$InstanceName;uid=$SqlLogonName; pwd=$SqlPassword;Database=$DatabaseName;Integrated Security=False;"
            }
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Execute sql against $InstanceName\$DatabaseName"))
        {
            $connection = New-Object System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $connectionString
            $connection.Open()
            $command = $connection.CreateCommand()
            $command.CommandText  = $SqlStatement

            $result = $command.ExecuteReader()

            $table = new-object “System.Data.DataTable”
            $table.Load($result)

            $connection.Close()
        }
    }
    End
    {
    }
}

$query =  @"
SELECT top 5 *
FROM   SYS.TABLES
"@

$params = @{ 'ServerInstance' = '172.22.38.252' ;
             'Database'       = 'Master' ;
             'UserName'       = 'BuildMaster' ;
             'Password'       = 'system';
             'Query'          = $query ;
}


$outFile = ".\sql_$(Get-Date -Format "ddMMyyyyHHmmss")"

Write-Host "Writting to file $outFile"

Invoke-Sqlcmd @params |
Export-Csv $outFile -NoClobber `
                    -NoTypeInformation `
                    -Delimiter "|" `
                    -Force

cat $outFile