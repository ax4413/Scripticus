cls

cd D:\temp

$InformationPreference = 'continue'

$repos = @{ 1 = [PSCustomObject]@{Folder='Accrued Interest Calculation Service'; 
                                  Url='http://eqcs-gitlab/icenet-applications/accrued-interest-calculation-service' };
            2 = [PSCustomObject]@{Folder='Accrued Interest Calculation Library'; 
                                  Url='http://eqcs-gitlab/icenet-libraries/accrued-interest-library' };
            3 = [PSCustomObject]@{Folder='Arrears Evaluation Service'; 
                                  Url='http://eqcs-gitlab/icenet-applications/arrears-evaluation-service' }; }



function invoke-git{
    [CmdletBinding()]
    Param
    (
        [parameter(mandatory=$true, position=0, ValueFromRemainingArguments=$true)]$Arguments
    )

    Begin
    {
        # stops posh git erroring with remote exceptions
        Write-Verbose "Pushing `$env:GIT_REDIRECT_STDERR"
        $tmp = $env:GIT_REDIRECT_STDERR
        $env:GIT_REDIRECT_STDERR = '2>&1'
    }
    Process
    {
        Write-Host "Performing a git $($Arguments[0])..."
        Write-Verbose "git $Arguments"

        $output = & git @Arguments  

        if($LASTEXITCODE -ne 0){
            Write-Error "$output"
            return
        }

        @($output -split "\n") | ForEach-Object { Write-Information "  $_" }
    }
    End
    {
        Write-Verbose "Popping `$env:GIT_REDIRECT_STDERR"
        $env:GIT_REDIRECT_STDERR = $tmp
    }    
}  
     
     
                                                           
foreach($r in $repos.GetEnumerator() | sort Name){
    $folder = $r.Value.Folder
    $url = $r.Value.Url
    invoke-git clone $url $folder
    Write-Host " "
}
