# Check for failed SQL jobs on multiple servers
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
foreach ($svr in get-content "C:\ServerList.txt")
{
   write-host $svr
   $srv=New-Object "Microsoft.SqlServer.Management.Smo.Server" "$svr"
   $srv.jobserver.jobs | where-object {$_.lastrunoutcome -eq "Failed" -and $_.isenabled -eq $TRUE} | format-table name,lastrunoutcome,lastrundate -autosize
}








# Check for failed SQL jobs on multiple servers
# This method does not use a text file and outputs the jobs to a array object
# that is then displayed. We are displaying all jobs, if we want to only display
# in error jobs apply the predicate on the assignment to teh arry not on the final
# display call

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null

$SQLInstances = @()
$SQLInstances += "localhost"
$SQLInstances += "localhost"
$SQLInstances += "localhost"

$Results = @()

# Iterate the sql instances
foreach ($instance in $SQLInstances)
{
	# new up a connection to the sql instance
    $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" "$instance"
	
	# add all jobs to an array - any filtering could and should be done here e.g. 
    $Results += $srv.jobserver.jobs		# | where-object {$_.lastrunoutcome -eq "Failed" -and $_.isenabled -eq $TRUE}
}

# The simple way of doing things
#$Results  | format-table OriginatingServer, name, CurrentRunStatus, lastrunoutcome, lastrundate -autosize

# The more dificult way of doing things gives us the duration of the sql job and its completion time
$psObjects = $Results  | Select-Object OriginatingServer, `
                                        @{LABEL='JobName'; ex={$_.name}},`
                                        @{LABEL='RunStatus'; ex={$_.CurrentRunStatus}},`
                                        @{LABEL='LastRunOutcome'; ex={$_.lastrunoutcome}},`
                                        @{LABEL='LastRunDate'; ex={$_.lastrundate}},`
                                        @{LABEL='LastRunCompletedDate'; ex={$_.lastrundate.AddSeconds(($_.JobSteps | Measure-Object -Property LastRunDuration -Sum).Sum)}},`
                                        @{LABEL='Duration';EXPRESSION={($_.JobSteps | Measure-Object -Property LastRunDuration -Sum).Sum}}

# we can now filter on the duration and only select the top 10
$psObjects | Sort-Object -property 'Duration' -Descending | Select-Object -First 10 | Format-Table -AutoSize
# we could have sorted the list this way also
#$psObjects | Sort-Object -property @{Expression={$_.LastRunCompletedDate - $_.LastRunDate}; Ascending=$false}  | Select-Object -First 10 | Format-Table -AutoSize

