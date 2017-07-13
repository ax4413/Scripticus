<#
.Synopsis
   This function returns a error code for a given exception
.DESCRIPTION
   This function returns a error code for a given exception. It does this by accessing the 
   `$Error[0] variable and identifieng its type
.EXAMPLE
   Get-ErrorCode
.OUTPUTS
   [int] All ints except zero denote an error. Zero is the success code.
.NOTES
   Passing in the Verbose flag will provide error details as well as just the error code
#>
function Get-ErrorCode
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([int])]
    Param
    (
    )

    Begin
    {
        # Treat all errors as terminating errors
        $ErrorActionPreference = "Stop"
        # initialize the error code to be -1 generic error
        $ErrorCode = -1
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Identify error code from `$Error[0]"))
        {
            try
            {   
                # .Net exceptions are negative            
                switch((($Error[0].Exception).GetType()).FullName) {
					"System.Net.WebException" { $ErrorCode = -3 }
					"System.IO.DirectoryNotFoundException" { $ErrorCode = -2 }
                    "System.IO.FileNotFoundException" { $ErrorCode = -3 }
					<# Extend as required... BUT -99 is reserved for missing Error_Helper#>
					default { $ErrorCode = -1 }				
				}
                
                # Custom exceptions are positive. No default required as the error code is allready -1
                if($ErrorCode -eq -1 ){
                    switch($Error[0].FullyQualifiedErrorId) {
                        "dtutilException" {$ErrorCode = 1}
                        "MissingReportConfigurationException" {$ErrorCode = 2}
						<# Extend as required... #>
                    }
                }
            }
            catch
            {
                $ErrorCode = -1
            }
            finally
            {
				Write-Verbose "Exception Type        : $($($($Error[0].Exception).GetType()).FullName)"
				write-verbose ($Error[0] | format-list -Force | out-string)				
                $errorCode
            }
        }
    }
    End
    {
    }
}


<#
.Synopsis
   Creates an custom ErrorRecord that can be used to report a terminating or non-terminating error.
.DESCRIPTION
   Creates an custom ErrorRecord that can be used to report a terminating or non-terminating error.
.EXAMPLE
   A simple custom error
   throw (New-CustomErrorRecord -ErrorId "dtutilException" -ErrorCategory "OperationStopped" -Message "Some message")
.EXAMPLE
   A simple custom containing the original exception
   throw (New-CustomErrorRecord -ErrorId "dtutilException" -ErrorCategory "OperationStopped" -Exception $error[0]")   
.EXAMPLE   
   A more complex example containing a formated message
   $obj = new-object psobject -property @{
            ExitCode = $lastexitcode
            ExitDescription = "blah blah blah"
            Command  = "The failing command"
            Result   = "Exception description"
            Success  = ($lastexitcode -eq 0)}
	
	throw (New-CustomErrorRecord -ErrorId "dtutilException" -ErrorCategory "OperationStopped" -Message ($obj | format-list -Force | out-string)")
.EXAMPLE
   How to throw a fully defined custom exception from a existing exception. Notice how we
   embed the original exception and inner exception.
   
   try {
      $i = 1
      $zero = 0
      $i/$zero
   } catch {
      $ex  = $Error[0].Exception.GetType().FullName
      $exc = $Error[0].Exception.ErrorRecord.CategoryInfo.Category
      $exm = $Error[0].Exception.Message
      $exi = $Error[0].Exception.InnerException.GetType().FullName
    
      $er = New-CustomErrorRecord -ErrorId "DivideByZero" `
             -Exception $ex -ErrorCategory $exc `
             -Message $exm -InnerException $exi `
             -TargetObject "`$zero"
    
      throw $er
   }
   
.NOTES
   The ErrorId property is very usefull. It is used to identify custom eerors in the Get-ErrorCode function.
.LINKS
   The following links proved extremly helpfull when implementing this method
   http://www.powershellmagazine.com/2011/09/14/custom-errors/
   http://msdn.microsoft.com/en-us/library/system.management.automation.errorrecord(v=vs.85).aspx
#>
function New-CustomErrorRecord {
    param(
		# The Exception that will be associated with the ErrorRecord.
        [Parameter(Mandatory = $false, Position = 0)]
        [System.String]
        $Exception = 'Microsoft.PowerShell.Commands.WriteErrorException',
		
		# A scripter-defined identifier of the error. This identifier must be a non-localized string for a specific error type. 
		# The error id is used to identify custome errors in the function Get-ErrorCode.
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('ID')]
        [System.String]
        $ErrorId,
		
		# An ErrorCategory enumeration that defines the category of the error.  
        [Parameter(Mandatory = $false, Position = 2)]
        [Alias('Category')]
        [System.Management.Automation.ErrorCategory]
        [ValidateSet('NotSpecified', 'OpenError', 'CloseError', 'DeviceError',
            'DeadlockDetected', 'InvalidArgument', 'InvalidData', 'InvalidOperation',
                'InvalidResult', 'InvalidType', 'MetadataError', 'NotImplemented',
                    'NotInstalled', 'ObjectNotFound', 'OperationStopped', 'OperationTimeout',
                        'SyntaxError', 'ParserError', 'PermissionDenied', 'ResourceBusy',
                            'ResourceExists', 'ResourceUnavailable', 'ReadError', 'WriteError',
                                'FromStdErr', 'SecurityError')]
        $ErrorCategory ='NotSpecified',
		
		# The object that was being processed when the error took place.  
        [Parameter(Mandatory = $false, Position = 3)]
        [System.Object]
        $TargetObject="",
		
		# Describes the Exception to the user. 
        [Parameter()]
        [System.String]
        $Message,
		
		# The Exception instance that caused the Exception association with the ErrorRecord. 
        [Parameter()]
        [System.Exception]
        $InnerException
    )
    begin {
        
    }
    process {
       
        # ...build and save the new Exception depending on present arguments, if it...
        $_exception  =  if ($Message -and $InnerException) {
                            # ...includes a custom message and an inner exception
                            New-Object $Exception $Message, $InnerException
                        } elseif ($Message) {
                            # ...includes a custom message only
                            New-Object $Exception $Message
                        } else {
                            # ...is just the exception full name
                            New-Object $Exception
                        }
        # now build and output the new ErrorRecord
        New-Object Management.Automation.ErrorRecord $_exception, $ErrorID, $ErrorCategory, $TargetObject
    }
}
