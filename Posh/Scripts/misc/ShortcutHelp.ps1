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
function Get-Shortcuts
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([object])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType Container})]
        [Alias("Directory")] 
        $Path
    )

    Begin
    {
        $results =@()
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            if($lnks -eq $null) {
                $lnks = Get-ChildItem -Path $Path  -Recurse -Filter "*.lnk"
            }
            
            foreach($lnk in $lnks) {
                
                $result = Get-ShortcutDetails -ShortcutFileInfo $lnk

                $results += $result
            }

            $results
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
function Get-ShortcutDetails
{
    [CmdletBinding(DefaultParameterSetName='FileInfo', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='FileInfo')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf})]
        [Alias("File")] 
        [System.IO.FileInfo]$ShortcutFileInfo,

        # 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='FileName')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf})]
        [Alias("FilePath")] 
        [String]$ShortcutPathName
    )

    Begin
    {
        $wsh = New-Object -ComObject WScript.Shell;
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            

            if(($pscmdlet.ParameterSetName -eq "FileInfo") -and ($ShortcutFileInfo.Extension -eq ".lnk" ) -and (Test-Path -Path $ShortcutFileInfo.FullName -PathType Leaf)) {
                $lnk = $ShortcutFileInfo.FullName
            } 
            elseif (($pscmdlet.ParameterSetName -eq "FileName") -and ($ShortcutPathName.EndsWith(".lnk")) -and (Test-Path -Path $ShortcutPathName -PathType Leaf)) {
                $lnk = $ShortcutPathName
            } 
            else {
                throw
            }           
            
            
            $lnkObj = $wsh.CreateShortcut($lnk);
    
            $result = New-Object psobject -Property @{
                "FilePath" = $lnk;
                "TargetPath" = $lnkObj.TargetPath;
            };
    
            Add-Member -InputObject $result -MemberType NoteProperty -Name TargetExists -Value ($lnko.TargetPath -ne "" -and (Test-Path $lnko.TargetPath))
            Add-Member -InputObject $result -MemberType ScriptProperty -Name IsUNC -Value {return $this.TargetPath.StartsWith("\\"); }
    
            $result;
            
        }
    }
    End
    {
    }
}