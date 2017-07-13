
function Get-AssemblyVersionInfo([System.String[]] $path){

    Get-ChildItem -Path $path -Filter '*.dll' -Recurse |
        Add-Member -MemberType ScriptProperty -Name FileVersion -Value { 
            $this.VersionInfo.FileVersion } -PassThru |
        Add-Member -MemberType ScriptProperty -Name ProductVersion -Value { 
            $this.VersionInfo.ProductVersion } -PassThru |
        Add-Member -MemberType ScriptProperty -Name AssemblyVersion -Value { 
            [Reflection.AssemblyName]::GetAssemblyName($this.FullName).Version } -PassThru |               
    Select-Object Name, Directory, FileVersion, ProductVersion, AssemblyVersion
}






$assemblies = "C:\Users\syeadon\Desktop\Windows Service\*.dll"

Get-AssemblyVersionInfo -path $assemblies


Get-AssemblyVersionInfo -path $assemblies |
Out-GridView


Get-AssemblyVersionInfo -path $assemblies |
Export-Csv -Path "c:\temp\Version.csv"





