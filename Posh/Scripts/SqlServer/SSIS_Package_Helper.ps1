<# ###########################################################################################################

    .SYNOPSIS
    The functions within this script can configure a dtsx package and install it to a SQL Server SSIS store.
    .DESCRIPTION
    The functions within this script can configure a dtsx package and install it to a SQL Server SSIS store.
    Works for 2005 and higher
    .NOTES
    Functions in this script use the New-CustomeException function which can be found in the Error_Helper.ps1 
    script. It is assumed that this script has been dot sourced by the calling script Deploy.ps1.
    .LINKS
    The following two links were heavily used in creating this solution
    http://sev17.com/2012/11/06/scripting-ssis-package-deployments/
    http://poshcode.org/3745
  
########################################################################################################### #>


# Module level
$exitCode = @{
    0 = 'The utility executed successfully.'
    1 = 'The utility failed.'
    4 = 'The utility cannot locate the requested package.'
    5 = 'The utility cannot load the requested package.'
    6 = 'The utility cannot resolve the command line because it contains either syntactic or semantic errors'
}


function Configure-DtsxFile
{
    param($DtsxFullName, $ConnectionManagers, $VariableDeffinitions)

    Write-Verbose -Message 'Configuring the dtsx file...'

    #Read the file
    [xml]$xml = [xml](Get-Content -Path $DtsxFullName)

    # foreach ConnectionManager node if its object name exists in the `$ConnectionManagers hashtable use its value to set the connection string node
    $xml |
    Select-Xml -XPath '//x:Executable/x:ConnectionManagers/x:ConnectionManager' -Namespace @{
        x = 'www.microsoft.com/SqlServer/Dts'
    } |
    ForEach-Object -Process {
        if($ConnectionManagers.Contains($_.Node.ObjectName)) 
        {
            $_.Node.ObjectData.ConnectionManager.ConnectionString = $($ConnectionManagers.$($_.Node.ObjectName)) 
        } 
    }


    # foreach varibale if that variable existsis in teh variable definitions hashtable then modify that variable node with teh value from the hash table
    $xml |
    Select-Xml -XPath '//x:Variables' -Namespace @{
        x = 'www.microsoft.com/SqlServer/Dts'
    } |
    ForEach-Object -Process {
        if($_.Node.HasChildNodes -and $VariableDeffinitions.Contains($_.Node.Variable.ObjectName)) 
        {
            $_.Node.Variable.VariableValue.InnerText = $($VariableDeffinitions.$($_.Node.Variable.ObjectName)) 
        } 
    }

    # over write the file
    $xml.Save($DtsxFullName)
} #Configure-DtsxFile


function Get-SqlVersion
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
    param(
        # The name of the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 0 )]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,
        
        # The sql user name
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 1 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserName,
        
        # The password of sql user
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 2 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserPassword
    )
    
    Begin { }
    
    Process {
        if ($pscmdlet.ShouldProcess("Get the sql version of the $ServerInstance")) 
        {
            Write-Verbose -Message 'Geting Sql version...'
            
            if($pscmdlet.ParamaterSetName -eq 'SqlAuth') 
            {
                $SqlVersion = SQLCMD.EXE -S "$ServerInstance" -d 'master' -U "$SqlUserName" -P "$SqlUserPassword" -Q "SET NOCOUNT ON; SELECT SERVERPROPERTY('ProductVersion')" -h -1 -W 
            }
            else 
            {
                $SqlVersion = SQLCMD.EXE -S "$ServerInstance" -d 'master' -Q "SET NOCOUNT ON; SELECT SERVERPROPERTY('ProductVersion')" -h -1 -W 
            }

            if ($lastexitcode -ne 0) 
            {
                throw $SqlVersion
            }
            else 
            {
                Write-Verbose -Message "Sql version = $SqlVersion"
                $SqlVersion
            }
        }
    }
    
    End { }
} #Get-SqlVersion


function Get-DtutilPath
{
    param($SqlVersion)
    
    Write-Verbose -Message 'Setting dtutil path...'

    $paths = [Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';'

    if ($SqlVersion -like '9*') 
    {
        $dtutil = $paths | Where-Object -FilterScript {
            $_ -like '*Program Files\Microsoft SQL Server\90\DTS\Binn\' 
        }
        if ($dtutil -eq $null) 
        {
            throw 'SQL Server 2005 Version of dtutil not found.'
        }
    }
    elseif ($SqlVersion -like '10*') 
    {
        $dtutil = $paths | Where-Object -FilterScript {
            $_ -like '*Program Files\Microsoft SQL Server\100\DTS\Binn\' 
        }
        if ($dtutil -eq $null) 
        {
            throw 'SQL Server 2008 or 2008R2 Version of dtutil not found.'
        }
    }
    elseif ($SqlVersion -like '11*') 
    {
        $dtutil = $paths | Where-Object -FilterScript {
            $_ -like '*Program Files\Microsoft SQL Server\110\DTS\Binn\' 
        }
        if ($dtutil -eq $null) 
        {
            throw 'SQL Server 2012 Version of dtutil not found.'
        }
    }

    if ($dtutil -eq $null) 
    {
        throw 'Unable to find path to dtutil.exe. Verify dtutil installed.'
    }
    else 
    {
        $dtutil += 'dtutil.exe'
        Write-Verbose -Message "dtutil = '$dtutil'"
    }

    $dtutil
} #Set-DtutilPath
 

function Get-FolderList
{
    param($PackageFullName)

    Write-Verbose -Message 'Getting a folder list...'

    if ($PackageFullName -match '\\') 
    {
        $folders = $PackageFullName  -split '\\'
        0..$($folders.Length -2) | ForEach-Object -Process { 
            New-Object -TypeName psobject -Property @{
                Parent   = $(if($_ -gt 0) 
                    {
                        $($folders[0..$($_ -1)] -join '\') 
                    }
                    else 
                    {
                        '\' 
                    }
                )
                FullPath = $($folders[0..$_] -join '\')
                Child    = $folders[$_]
            }
        }
    }
} #Get-FolderList


function Test-SsisFolderPath
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
    param(
        # The name of the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 0 )]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,
        
        # The name of the folder on the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 1 )]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath,
        
        # The path to dtutil
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 2 )]
        [ValidateNotNullOrEmpty()]
        [string]$dtutil,
        
        # The sql user name
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 3 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserName,
        
        # The password of sql user
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 4 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserPassword
    )
    
    Begin { }
    
    Process {
        if ($pscmdlet.ShouldProcess("Test the path of '$FolderPath' on $ServerInstance")) 
        {
            Write-Verbose -Message 'Testing path...'

            if($pscmdlet.ParamaterSetName -eq 'SqlAuth') 
            {
                $result = & $dtutil /SourceServer "$ServerInstance" /SourceUser "$SqlUserName" /SourcePassword "$SqlUserPassword" /FExists SQL`;"$FolderPath" 
            }
            else 
            {
                $result = & $dtutil /SourceServer "$ServerInstance" /FExists SQL`;"$FolderPath" 
            }
                
            if ($lastexitcode -gt 1) 
            {
                $result = $result -join "`n"
                throw "$result `n $($exitCode[$lastexitcode])"
            }

            if ($result -and $result[4] -eq 'The specified folder exists.') 
            {
                $true
            }
            else 
            {
                $false
            }
        }
    }
    
    End { }
} #Test-SsisFolderPath


function New-Folder
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
    param(
        # The name of the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 0 )]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,
        
        # The name of the parent folder on the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 1 )]
        [ValidateNotNullOrEmpty()]
        [string]$ParentFolderPath,
        
        # The name of the new folder
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 2 )]
        [ValidateNotNullOrEmpty()]
        [string]$NewFolderName,
        
        # The path to dtutil
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 3 )]
        [ValidateNotNullOrEmpty()]
        [string]$dtutil,
        
        # The sql user name
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 4 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserName,
        
        # The password of sql user
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 5 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserPassword
    )
    
    Begin { }
    
    Process {
        if ($pscmdlet.ShouldProcess('Create a new folder ')) 
        {
            Write-Verbose -Message 'Creating a new folder...'
            
            if($pscmdlet.ParamaterSetName -eq 'SqlAuth') 
            {
                $result = & $dtutil /SourceServer "$ServerInstance" /SourceUser "$SqlUserName" /SourcePassword "$SqlUserPassword" /FCreate SQL`;"$ParentFolderPath"`;"$NewFolderName" 
            }
            else 
            {
                $result = & $dtutil /SourceServer "$ServerInstance" /FCreate SQL`;"$ParentFolderPath"`;"$NewFolderName" 
            }
            
            $result = $result -join "`n"

            $cmdDesc = New-Object -TypeName psobject -Property @{
                ExitCode        = $lastexitcode
                ExitDescription = "$($exitCode[$lastexitcode])"
                Command         = "$dtutil /SourceServer `"$ServerInstance`" /FCreate SQL;`"$ParentFolderPath`";`"$NewFolderName`""
                Result          = $result
                Success         = ($lastexitcode -eq 0)
            }

            if ($lastexitcode -eq 0) 
            {
                Write-Verbose -Message ($cmdDesc |
                    Format-List -Force |
                Out-String) 
            } 
            else 
            {
                throw (New-CustomErrorRecord -ErrorId 'dtutilException' -ErrorCategory 'OperationStopped' -Message ($cmdDesc |
                        Format-List -Force |
                Out-String)) 
            }
        }
    }
    
    End { }
} #new-folder


function Install-Package
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
    param(
        # The name of the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 0 )]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,
        
        # The full path to the dtsx package
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 1 )]
        [ValidateNotNullOrEmpty()]
        [string]$DtsxFullName,
        
        # The name that you want to deploy your package under
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 2 )]
        [ValidateNotNullOrEmpty()]
        [string]$PackageFullName,
        
        # The path to dtutil
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 3 )]
        [ValidateNotNullOrEmpty()]
        [string]$dtutil,
        
        # The sql user name
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 4 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserName,
        
        # The password of sql user
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 5 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserPassword
    )
    
    Begin { }
    
    Process {
        if ($pscmdlet.ShouldProcess("Install the package '$DtsxFullName'")) 
        {
            Write-Verbose -Message 'Installing package...'
            
            if($pscmdlet.ParamaterSetName -eq 'SqlAuth') 
            {
                $result = & $dtutil /File "$DtsxFullName" /DestServer "$ServerInstance" /DestUser "$SqlUserName" /DestPassword "$SqlUserPassword" /Copy SQL`;"$PackageFullName" /Quiet 
            }   
            else 
            {
                $result = & $dtutil /File "$DtsxFullName" /DestServer "$ServerInstance" /Copy SQL`;"$PackageFullName" /Quiet 
            }   
            
            $result = $result -join "`n"

            $cmdDesc = New-Object -TypeName psobject -Property @{
                ExitCode        = $lastexitcode
                ExitDescription = "$($exitCode[$lastexitcode])"
                Command         = "$dtutil /File `"$DtsxFullName`" /DestServer `"$ServerInstance`" /Copy SQL;`"$PackageFullName`" /Quiet"
                Result          = $result
                Success         = ($lastexitcode -eq 0)
            }
            
            if ($lastexitcode -eq 0) 
            {
                Write-Verbose -Message ($cmdDesc |
                    Format-List -Force |
                Out-String) 
            } 
            else 
            {
                throw (New-CustomErrorRecord -ErrorId 'dtutilException' -ErrorCategory 'OperationStopped' -Message ($cmdDesc |
                        Format-List -Force |
                Out-String)) 
            }
        }
    }
    
    End { }
} #install-package


function Test-Package
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', 
            SupportsShouldProcess = $true, 
            PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
    param(
        # The name of the server instance
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 0 )]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,
               
        # The name that you want to deploy your package under
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 1 )]
        [ValidateNotNullOrEmpty()]
        [string]$PackageFullName,
        
        # The path to dtutil
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 2 )]
        [ValidateNotNullOrEmpty()]
        [string]$dtutil,
        
        # The sql user name
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 3 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserName,
        
        # The password of sql user
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, ParameterSetName = 'SqlAuth', Position = 4 )]
        [ValidateNotNullOrEmpty()]
        [string]$SqlUserPassword
    )
    
    Begin { }
    
    Process {
        if ($pscmdlet.ShouldProcess("Test the package '$PackageFullName'")) 
        {
            Write-Verbose -Message 'Testing package...'
            
            if($pscmdlet.ParamaterSetName -eq 'SqlAuth') 
            {
                $result = & $dtutil /SourceServer "$ServerInstance" /SourceUser "$SqlUserName" /SourcePassword "$SqlUserPassword" /SQL "$PackageFullName" /EXISTS 
            }
            else 
            {
                $result = & $dtutil /SourceServer "$ServerInstance" /SQL "$PackageFullName" /EXISTS 
            }

            if ($lastexitcode -gt 1) 
            {
                $result = $result -join "`n"
                throw "$result `n $($exitCode[$lastexitcode])"
            }

            $cmdDesc = New-Object -TypeName psobject -Property @{
                ExitCode        = $lastexitcode
                ExitDescription = "$($exitCode[$lastexitcode])"
                Command         = "$dtutil /SourceServer `"$ServerInstance`" /SQL `"$PackageFullName`" /EXISTS"
                Result          = $result[4]
                Success         = ($lastexitcode -eq 0 -and $result -and $result[4] -eq 'The specified package exists.')
            }

            if ($lastexitcode -eq 0) 
            {
                Write-Verbose -Message ($cmdDesc |
                    Format-List -Force |
                Out-String) 
            } 
            else 
            {
                throw ($cmdDesc |
                    Format-List -Force |
                Out-String) 
            }
        }
    }
    
    End { }
} #Test-Package