$doc = 'C:\Temp\BaseData\DependencyTree.xml'

# Option 1 ==========================================================
$Hash = $null
$Hash=@{}  

Select-Xml -Path $doc -XPath //Table | 
    ForEach-Object { $Hash[$_.Node.Ordinal -as [int]]=$_.Node.Name }

$Hash.GetEnumerator() | Sort-Object key

Write-Host "========================================================"

# Option 2 ==========================================================
$Hash = $null
$Hash=@{} 

[xml]$xmlDoc = get-content -Path $doc
$xmlDoc.get_DocumentElement().ChildNodes | 
    ForEach-Object { $Hash.Add($($_.Ordinal -as [int]), $($_.Name)) }

$Hash.GetEnumerator() | Sort-Object key



# Example xml file ==================================================
<#
<DependencyTree>
  <Table Ordinal="1" Name="dbo.Entity" />
  <Table Ordinal="2" Name="dbo.SystemUser" />
  <Table Ordinal="3" Name="dbo.ListDescription" />
  <Table Ordinal="4" Name="dbo.List" />
  <Table Ordinal="5" Name="dbo.ReasonCode" />
  <Table Ordinal="6" Name="dbo.ApplicationStatus" />
  <Table Ordinal="7" Name="dbo.AllowableApplicationStatus" />
  <Table Ordinal="8" Name="dbo.AssetType" />
  <Table Ordinal="9" Name="dbo.AttachmentType" />
  <Table Ordinal="10" Name="dbo.BACSReturnCode" />
  <Table Ordinal="11" Name="dbo.BankHoliday" />
  <Table Ordinal="12" Name="dbo.BatchProcess" />
  <Table Ordinal="13" Name="dbo.CacheDefinition" />
  <Table Ordinal="14" Name="dbo.ChecklistCondition" />
  <Table Ordinal="15" Name="dbo.Country" />
  <Table Ordinal="16" Name="dbo.DataSanitiserParameter" />
  <Table Ordinal="17" Name="dbo.FormatMask" />
  <Table Ordinal="18" Name="dbo.OperationalTime" />
  <Table Ordinal="19" Name="dbo.NoteType" />
  <Table Ordinal="20" Name="dbo.Page" />
  <Table Ordinal="21" Name="dbo.Role" />
  <Table Ordinal="22" Name="dbo.SecuredTask" />
  <Table Ordinal="23" Name="dbo.SqlInjectionParsingParameters" />
  <Table Ordinal="24" Name="dbo.SuspenseAccount" />
  <Table Ordinal="25" Name="dbo.SystemNoteType" />
  <Table Ordinal="26" Name="dbo.SystemParameter" />
  <Table Ordinal="27" Name="dbo.TaxCategory" />
  <Table Ordinal="28" Name="dbo.WebService" />
  <Table Ordinal="29" Name="dbo.Window" />
  <Table Ordinal="30" Name="dbo.XmlTransformDefinition" />
  <Table Ordinal="31" Name="dbo.TransactionType" />
  <Table Ordinal="32" Name="dbo.AddressType" />
  <Table Ordinal="33" Name="dbo.FinancialProductType" />
  <Table Ordinal="34" Name="dbo.RelationshipType" />
  <Table Ordinal="35" Name="dbo.FilterTestType" />
  <Table Ordinal="36" Name="dbo.FilterTestTypeValidProperty" />
  <Table Ordinal="37" Name="dbo.ThirdPartyStatus" />
  <Table Ordinal="38" Name="dbo.ThirdPartyService" />
  <Table Ordinal="39" Name="dbo.TestingServiceResponse" />
  <Table Ordinal="40" Name="dbo.TestingServiceResponseSet" />
  <Table Ordinal="41" Name="dbo.TestingServiceResponseSetLink" />
</DependencyTree>
#>