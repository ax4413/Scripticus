<# Search #>

Select-Xml -Path "C:\users\syeadon\Desktop\ScorReportMergeUtility\@Project.manifest" -XPath "//x:Project/x:Properties/x:Property[@x:Name = 'Name']" -Namespace @{
    x = 'www.microsoft.com/SqlServer/SSIS'
} | ForEach-Object { $_.Node } | Format-Table -AutoSize



<# single edit #>

$filePath = "C:\users\syeadon\Desktop\ScorReportMergeUtility\@Project.manifest"
$namespace = @{ x = 'www.microsoft.com/SqlServer/SSIS' }
$xPath = "//x:Project/x:Properties/x:Property[@x:Name = 'Name']"
$newValue = "arse"

$xml = [xml](Get-Content $filePath)
$xml | Select-Xml -XPath $xPath -Namespace $namespace | ForEach-Object { $_.Node.set_InnerText($newValue) }
$xml.Save($filePath)



<# multiple edits #>

$filePath = "C:\users\syeadon\Desktop\ScorReportMergeUtility\@Project.manifest"

$namespace = @{ x = 'www.microsoft.com/SqlServer/SSIS' }

$NodeValue = @{"//x:Project/x:Properties/x:Property[@x:Name = 'Name']" = "boob";
               "//x:Project/x:Properties/x:Property[@x:Name = 'ID']" = "bum"}

$xml = [xml](Get-Content $filePath)

foreach($nv in $NodeValue.Keys) {
    foreach($node in Select-Xml -xml $xml -XPath $nv -Namespace $namespace) {
        $node.Node.set_InnerText($NodeValue.Item($nv))
    } 
}

$xml.Save($filePath)