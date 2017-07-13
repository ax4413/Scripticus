function Get-ConsoleBackgroundColor(){
    $c = $Host.UI.RawUI.BackgroundColor
    $bc= [System.ConsoleColor]::DarkMagenta

    if($c -ge 0){
        if($c.GetType() -eq [System.ConsoleColor]){
            $bc = [System.ConsoleColor]$c
        }
    }

    return $bc
}

$global:SvnPromptSettings = New-Object PSObject -Property @{

    BeforeText                = '['
    BeforeForegroundColor     = [ConsoleColor]::white
    BeforeBackgroundColor     = Get-ConsoleBackgroundColor

    AfterText                 = ' ]'
    AfterForegroundColor      = [ConsoleColor]::white
    AfterBackgroundColor      = Get-ConsoleBackgroundColor

    AddedForegroundColor      = [ConsoleColor]::Green
    ModifiedForegroundColor   = [ConsoleColor]::Yellow
    DeletedForegroundColor    = [ConsoleColor]::Red
    UntrackedForegroundColor  = [ConsoleColor]::White
    MissingForegroundColor    = [ConsoleColor]::Red
    ConflictedForegroundColor = [ConsoleColor]::DarkGray

    BranchForegroundColor     = [ConsoleColor]::Magenta
    BranchBackgroundColor     = Get-ConsoleBackgroundColor

    WorkingForegroundColor    = [ConsoleColor]::Yellow
    WorkingBackgroundColor    = Get-ConsoleBackgroundColor
}



function Write-SvnStatus($status) {
    if ($status) {
        $s = $global:SvnPromptSettings

        Write-Host $s.BeforeText -NoNewline -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor
        
        if($status.Branch) {
            Write-Host " $($status.Branch) " -NoNewline -BackgroundColor $s.BranchBackgroundColor -ForegroundColor $s.BranchForegroundColor
        }

        if($status.Added) {
          Write-Host " +$($status.Added)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.AddedForegroundColor
        }
        if($status.Modified) {
          Write-Host " ~$($status.Modified)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.ModifiedForegroundColor
        }
        if($status.Deleted) {
          Write-Host " -$($status.Deleted)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.DeletedForegroundColor
        }

        if ($status.Untracked) {
          Write-Host " ?$($status.Untracked)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.UntrackedForegroundColor
        }

        if($status.Missing) {
           Write-Host " !$($status.Missing)" -NoNewline -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.MissingForegroundColor
        }

        if($status.Conflicted) {
          write-host " #$($status.Conflicted)" -NoNewLine -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.ConflictedForegroundColor
        }

        Write-Host $s.AfterText -NoNewline -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor
    }
}

# Should match https://github.com/dahlbyk/posh-git/blob/master/GitPrompt.ps1
if (!$Global:VcsPromptStatuses) { $Global:VcsPromptStatuses = @() }
function Global:WriteVcsStatus { $Global:VcsPromptStatuses | foreach { & $_ } }

# Scriptblock that will execute for write-vcsstatus
$Global:VcsPromptStatuses += {
	$Global:SvnStatus = Get-SvnStatus
	Write-SvnStatus $SvnStatus
}
