
function Get-SomethingDangerous ($Name, $Type){
    write-host " - invoking $Name $Type`r`n"
    if($Type -gt 0){
        "found $Name"
    } else {
        throw "boom"
    }
}


# Execute a script block safely
# typically used to execute a GET that could throw if no item was found
Function Invoke-Safely ([scriptblock]$code, $params, [switch]$logException) {
    try{
        & $code @params
    }catch{
        if($logException){
            write-host "-------------------------------------------------------------------------" -ForegroundColor Gray
            write-host "Swallowing Exception`r`n" -ForegroundColor Yellow
            
            $ex = $_.Exception
            if($ex){
                $exType = $ex.GetType()
                if($exType){
                   write-host "Exception Type        : $($exType.FullName)".Trim()
                }
            }

            write-host "$(($_ | Format-List -Force | Out-String).Trim())`r`n" -ForegroundColor Yellow
            Write-Host $code -ForegroundColor red
            write-host "`r`n-------------------------------------------------------------------------" -ForegroundColor Gray
        }
    }
}     


# i swallow the exception
$x = Invoke-Safely -code { param([string]$p1, [int]$p2) Get-SomethingDangerous -Name $p1 -Type $p2 } `
                   -params 'q:\temp\Logs', -1 `
                   -logException


# I can now evaluate the objects existance safely
if($x){
    write-host "x returned $x"
    $x | gm
} else {
    write-host "x returned null"
}




################################################################################################




function Procede-If
{
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $obj,

        [Parameter(Mandatory=$true, Position=1)]
        [ScriptBlock]$Predicate,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateSet("Continue", "Warn", "Fail")]
        $ActionPrefernce = "Continue"
    )

    Process
    {
        $state = & $Predicate $obj

        if($state -eq $true)
        {
            if($ActionPrefernce -eq 'Fail'){
                Write-Error 'boom'
            } 
            if($ActionPrefernce -eq 'Warn'){
                Write-Warning 'foo'
            } 
            if($ActionPrefernce -eq 'Continue'){
                $obj
            }
        }
    }    
}


2 | Procede-If -Predicate { $_ -eq 2 } | % { $_ * $_ }