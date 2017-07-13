<#
.Synopsis
   Function that creates wrapper around command to enable easy acces to verbose/debug output.
.DESCRIPTION
   This function takes as input name of the command that:
        is not advanced (doesn't have CmdletBinding attribute)
        uses Write-Verbose or Write-Debug
   It creates wrapper around it to enable -Verbose and -Debug switches for easy access to both streams.
   The following example creates a new command that wrapps the Get-User command. To use the wrapper command
   simmply call Get-AdvancedUser 'Stephen'
.EXAMPLE
   function Get-User {
      param (
        $Name
      )
        Write-Verbose "Getting information for user: $Name"
        net user $Name
   }

   ConvertTo-Advanced -Name Get-user

.NOTES
   http://www.powershellmagazine.com/2014/08/11/pstip-taking-control-of-verbose-and-debug-output-part-1/
   http://www.powershellmagazine.com/2014/08/12/pstip-taking-control-of-verbose-and-debug-output-part-2/
   http://www.powershellmagazine.com/2014/08/13/pstip-taking-control-of-verbose-and-debug-output-part-3/
   http://www.powershellmagazine.com/2014/08/14/pstip-taking-control-of-verbose-and-debug-output-part-4/
   http://www.powershellmagazine.com/2014/08/15/pstip-taking-control-of-verbose-and-debug-output-part-5/
#>
function ConvertTo-Advanced {
    [OutputType([System.Management.Automation.CommandInfo])]
    [CmdletBinding()]
    param (
        # Name of the command that should be wrapped in advanced function.
        [Parameter(Mandatory = $true)]
        [ValidateScript({

            $command = Get-Command -Name $_ -ErrorAction Stop

            if ($command.CmdletBinding) {
                throw 'This is already an advanced command.'
            }

            $astVerboseOrDebug = $command.ScriptBlock.Ast.FindAll(
                {
                    $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                    $args[0].CommandElements[0].Value -match '^Write-(Verbose|Debug)$'
                },
                $true
            )

             if (-not $astVerboseOrDebug) {
                throw 'No need to turn into advanced: Write-Debug and Write-Verbose not used.'
            }

            $true
        })]
        [String]$Name
    )

    $commandInfo = Get-Command @PSBoundParameters

    switch ($commandInfo.CommandType) {
        ExternalScript {
            $isPipelineFriendly = [bool]$commandInfo.ScriptBlock.Ast.ProcessBlock
            $newName = $commandInfo.Name -replace '^', 'Invoke-'
        }

        Function {
            $isPipelineFriendly = [bool]$commandInfo.ScriptBlock.Ast.Body.ProcessBlock
            $newName = $commandInfo.Name -replace '-', '-Advanced'
        }
    }

    $paramBlock = [System.Management.Automation.ProxyCommand]::GetParamBlock($commandInfo)

    if ($isPipelineFriendly) {

        $inputParameter = @'
    [Parameter(ValueFromPipeline = $true)]
    [System.Object]
    ${InputObject}
'@

        if ($paramBlock) {
            $paramBlock = $paramBlock, $inputParameter -join ','
        } else {
            $paramBlock = $inputParameter
        }

        $body = @'
begin {{
    Write-Verbose 'Removing InputObject from PSBoundParameters'
    $PSBoundParameters.Remove('InputObject') | Out-Null
}}

process {{
    Write-Verbose 'Running {0} with $InputObject as pipeline input and PSBoundParameters'
    $InputObject | {0} @PSBoundParameters
}}
'@

    } else {

        $body = @'
    Write-Verbose "Calling {0} with parameters passed."
    {0} @PSBoundParameters
'@

}

    $body = $body -f $commandInfo.Name

    $scriptText = @"
[CmdletBinding()]
param (
$paramBlock
)
$body
"@

    $scriptBlock = [scriptblock]::Create($scriptText)
    New-Item -Path function:\Global:$newName -Value $scriptBlock -Force
}
