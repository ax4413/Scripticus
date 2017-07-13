param(
    [Int32]  $step = 0, 
    [string] $value = ""
) #Must be the first statement in your script


# Validate arguments
if($step -eq 0){
    Write-Warning "Using default step argumant: '$step'" }

if($value -eq ""){
    Write-Warning "Using default value argumant: '$value'" }




# begin script
Write-Host "Step: $step"
Write-Host "Value: $value"