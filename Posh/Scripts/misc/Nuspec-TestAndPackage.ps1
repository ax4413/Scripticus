$Nuspec = 'D:\Code\IceNet\Icenet 3\Trunk\src\Icenet.Reporting\Icenet.Reporting.Payday_Lbl.nuspec'
$Output = 'C:\Users\syeadon\Desktop'


# Remember the original executing dir
$OriginalDir = $PSScriptRoot

# read the nuspec file
$xml = [xml](Get-Content $Nuspec)

# Change to the solution dir as the paths that we want to check are relative
cd $(Split-Path $Nuspec -Parent)

# Test to ensure that the files deffined in the nuspec file exist. 
# This is necessary as the 'pack' cmd does not do this.
# Replace the recusive '**' string as this is not a valid part of the path
$xml.package.files.file | % { 
        if(-not (Test-Path $($_.src).Replace("\**",""))) {
            Write-Host "invalid file path $($_.src)"
            exit -1
        }
    }

# Change to the solution dir
cd $OriginalDir


# Package the nuget file
nuget pack $Nuspec -outputdirectory $Output | Out-Null


exit 0