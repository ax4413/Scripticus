function Invoke-EnsureFolderExists 
{
    [CmdletBinding(
                SupportsShouldProcess=$true, 
                PositionalBinding=$true,
                ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Path)

    if((Test-Path $Path) -eq 0)
    {
        
        if($PSCmdlet.ShouldProcess($Path, "Create folder")) {
            New-Item -Path $Path -ItemType "directory" -Force
        }
    }
}

Export-ModuleMember -Function Invoke-EnsureFolderExists