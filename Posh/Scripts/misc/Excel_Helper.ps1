﻿<#
.Synopsis
   Edit the data sources contained within this excel file
.DESCRIPTION
   Edit the data sources contained within this excel file. Modify the connection string and command text 
.EXAMPLE
   Edit-ExcelDataSources -excelFile "C:\Users\syeadon\Desktop\CashFlowActual.xlsx"`
                      -NewConnectionString "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=GreenDeal_Reporting;Data Source=localhost\nostrumsql;Extended Properties=`"Security=SSPI`";Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=WNHWDEV23V;Use Encryption for Data=False;Tag with column collation when possible=False" `
                      -NewCommandText "`"GreenDeal_Reporting`".`"dbo`".`"vw_CashflowActual`""
.EXAMPLE
   $params = @{'excelFile'           = "C:\Users\syeadon\Desktop\CashFlowActual.xlsx";
               'PathToOpenXmlDLL'    = “C:\temp\DocumentFormat.OpenXml.dll”;
               'NewConnectionString' = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=GreenDeal_Reporting;Data Source=localhost\nostrumsql;Extended Properties=`"Security=SSPI`";Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=WNHWDEV23V;Use Encryption for Data=False;Tag with column collation when possible=False" ;
               'NewCommandText'      = "`"GreenDeal_Reporting`".`"dbo`".`"vw_CashflowActual`"" }
   
   Edit-ExcelDataSources @params
#>
function Edit-ExcelDataSources
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    Param
    (
        # The excel file we want to modify
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})] 
        [Alias('ExcelFileToEdit')]
        [string]
        $excelFile,

        # Command text is the sql statement embeded within the file
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("CommandText")]
        [string]
        $NewCommandText = "",
	
        # The connection string we want to edit
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("ConnectionString")]
        [string]
        $NewConnectionString = "",

        # The connection string we want to edit
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})] 
        [string]
        $PathToOpenXmlDLL
    )

    Begin
    {
        # Exit on error
        $ErrorActionPreference = "Stop"

        # Create an instance of a empty strongly typed [System.Type] array
        [System.Type[]]$t = @()
        # Create an instance of a empty strongly typed [System.Object] array
        [System.Object[]]$o = @()

        if($NewConnectionString -eq "" -and $NewCommandText -eq "") {
            Write-Error "Both the NewConnectionString and NewCommandText properties cannot be null. Chose which one you want to edit." `
                -Category InvalidArgument
        }        
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
		   
			try {                
                # Load the OPenXml types
                [Reflection.Assembly]::LoadFile($PathToOpenXmlDLL) | Out-Null

                # Open the excel file workbook
                $wkb = [DocumentFormat.OpenXml.Packaging.SpreadsheetDocument]::Open($excelFile, $true)

                # load xmldoc with stream from selected Excel doc
                [System.XML.XMLDocument]$xmlDoc = New-Object System.Xml.XmlDocument
                $xmlDoc.Load($($wkb.WorkbookPart.ConnectionsPart.GetStream()));

                # select connections node from loaded xml Excel
                $csNode = $xmlDoc.SelectSingleNode("*/*/*[@connection]")

                if($csNode -eq $null -or $($csNode.Attributes) -eq $null -or $($csNode.Attributes.Count) -eq 0) {
                    Write-Error "Either connection string node or its attributes are null or empty"
                }

                # store original node values
                $oldConnectionString = $csNode.Attributes["connection"].Value
                $oldCommandText = $csNode.Attributes["command"].Value

                # delete existing ConnectionsPart - to ensure that bleed-over data is not present
                $wkb.WorkbookPart.DeletePart($($wkb.WorkbookPart.ConnectionsPart)) | Out-Null

                # Create a replacement ConnectionsPart               
                # This is difficult because the method AddNewPart has a .NET Generic type of T    
                # Get reference to all methods of that name on this type, which have teh same method signature
                $method = [DocumentFormat.OpenXml.Packaging.OpenXmlPartContainer].GetMethod("AddNewPart", $t)
                # Make the non generic method generic of type T
                $closedMethod = $method.MakeGenericMethod([DocumentFormat.OpenXml.Packaging.ConnectionsPart])
                # Call the generic implentation of this method
                $closedMethod.Invoke($wkb.WorkbookPart, $o) | Out-Null


                # assign the new connection string or if null the old connection string
                $NewConnectionString = if($NewConnectionString -eq $null) { $oldConnectionString }else{ $NewConnectionString }                
                $csNode.Attributes["connection"].Value = $NewConnectionString
                Write-Debug "New Connection String saved: $NewConnectionString"
                
                # assign the new command text or if null the old command text
                $NewCommandText = if($NewCommandText -eq $null) { $oldCommandText }else{ $NewCommandText }                
                $csNode.Attributes["command"].Value = $NewCommandText
                Write-Debug "New Command Text saved: $NewCommandText"

                # save the stream changes back to the file system
                $xmlDoc.Save($($wkb.WorkbookPart.ConnectionsPart.GetStream()))

                Write-Host "Data sources changed for $(Split-Path $excelFile -leaf -Resolve)"
            }
			catch {  			        
			    throw $Error[0]
			}
            finally{
                # close any open workbooks
                if($wkb -ne $null) { 
                    $wkb.Close() 
                }
             } 
        }
    }
    End
    {
    }
}
