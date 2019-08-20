-- ===============================================================================================================================
-- ===  USEFULL SQL TO AUTOMATE THE GENARTION OF JSON TO BE USED IN THE CDC DEFINITION FILES            ==========================
-- ===  This json document will need to be modified to exclude columns which you are not interested in  ==========================

DECLARE @t TABLE(name VARCHAR(128))
  INSERT INTO @t(name)
  VALUES
 ('accountingperiod')
,('address')
,('AddressType')
,('agreementbalance')
,('AgreementBalanceDetail')
,('Application')
,('ApplicationCourseDetail')
,('ApplicationReasonCode')
,('applicationstatus')
,('ApplicationStatusHistory')
,('Asset')
,('assetlink')
,('AssetType')
,('bankaccount')
,('BankPaymentRequest')
,('Carddetail')
,('Cashflow')
,('communication')
,('company')
,('ContraSettlement')
,('Country')
,('CourseDetail')
,('creditcheck')
,('dealer')
,('DealerPerson')
,('Deposit')
,('directdebitinstruction')
,('DocumentRequest')
,('Employment')
,('entity')
,('EntityAssetType')
,('entityrelationship')
,('entityRole')
,('FeeType')
,('financialdetail')
,('FinancialEvent')
,('FinancialProduct')
,('FinancialProductType')
,('FinancialTransaction')
,('financialtransactionbatch')
,('FinancialTransactionLink')
,('funderproposal')
,('FunderProposalStatus')
,('FunderProposalStatusHistory')
,('importfilelog')
,('ImportFileMessages')
,('List')
,('ListDescription')
,('log')
,('Note')
,('NoteDocument')
,('NoticeOfDefaultHistory')
,('PaymentRequest')
,('PayoutDetail')
,('Person')
,('proposal')
,('proposalscores')
,('reasoncode')
,('relationshipType')
,('Representative')
,('rpt_CCA2006_SumOfArrears')
,('schedule')
,('scheduleHeader')
,('settlementquote')
,('settlementquoteDetail')
,('SystemParameter')
,('SystemUser')
,('temporaryarrangementtype')
,('TertiaryStatus')
,('ThirdPartyAttribute')
,('ThirdPartyLookup')
,('ThirdPartyRequest')
,('TransactionGroup')
,('TransactionGroupLink')
,('transactiontype')
,('underwritinghistory')

SELECT '{
    "SchemaName":"'          + SCHEMA_NAME(t.schema_id) + '",
    "TableName":"'           + t.name                   + '",
    "IndexName":'            + 'null'                   + ',
    "SupportsNetChanges":'   + 'true'                   + ',
    "AllowPartitionSwitch":' + 'true'                   + ',
    "CaptureAllColumns":'    + 'false'                  + ',
    "ColumnsToInclude":'     + '['
      + col.List +
    ']
},'
from  @t x
      INNER JOIN  sys.tables t on t.name = x.name
      CROSS APPLY ( SELECT  List = STUFF (  ( SELECT  ', ' + QUOTENAME(c.name)
					                                    FROM    sys.columns c
                                                      inner join sys.types ty on ty.system_type_id = c.system_type_id
					                                    WHERE   c.object_id = t.object_id
                                                AND   ty.name != 'text'
					                                    ORDER BY c.is_identity DESC, c.name ASC
					                                    FOR XML PATH('') ), 1, 2, '' ) ) col
      WHERE t.name NOT IN ('RPT_cca2006_sUMoFaRREARS', 'ImportFileLog', 'ImportFileMessage')    
ORDER BY t.name






-- ===============================================================================================================================
-- ===  USEFULL SQL TO AUTOMATE THE GENARTION OF SQL TO BE USED IN SSIS PACKAGES    ==============================================
-- ===  Generate the delete and update statements for the SSIS package              ==============================================


SELECT  t.name,
        'UPDATE b ' + CHAR(10) + 
        'SET ' + col.list + 
        'FROM  [base].' + QUOTENAME(t.name) + ' b' + CHAR(10) + 
        'INNER JOIN [staging].[' + t.name + '_update] s' + CHAR(10) + 
        'ON b.' + t.name + 'Id = s.' +  t.name +'Id' + CHAR(10) + CHAR(10) 
FROM    sys.tables t 
        CROSS APPLY ( SELECT  List = STUFF (  ( SELECT  ', b.' + QUOTENAME(c.name) + '= s.' + QUOTENAME(c.name) + CHAR(10) +CHAR(9)
					                                      FROM    sys.columns c
                                                        INNER JOIN sys.types ty on ty.system_type_id = c.system_type_id
					                                      WHERE   c.object_id = t.object_id
                                                  AND   ty.name != 'text'
					                                      ORDER BY c.is_identity DESC, c.column_id ASC
					                                      FOR XML PATH('') ), 1, 2, '' ) ) col
WHERE   t.schema_id = schema_id('base')
ORDER BY t.name




SELECT t.name,
      'DELETE b ' + CHAR(10) + 
      'FROM  [base].' + QUOTENAME(t.name) + ' b' + CHAR(10) + 
      'INNER JOIN [staging].[' + t.name + '_Delete] s' + CHAR(10) + 
      'ON b.' + t.name + 'Id = s.' +  t.name +'Id' + CHAR(10) + CHAR(10) 
FROM  sys.tables t 
      CROSS APPLY ( SELECT  List = STUFF (  ( SELECT  ', [base].' + QUOTENAME(c.name) + '= [staging].' + QUOTENAME(c.name) + CHAR(10) +CHAR(9)
					                                    FROM    sys.columns c
                                                      inner join sys.types ty on ty.system_type_id = c.system_type_id
					                                    WHERE   c.object_id = t.object_id
                                                AND   ty.name != 'text'
					                                    ORDER BY c.is_identity DESC, c.column_id ASC
					                                    FOR XML PATH('') ), 1, 2, '' ) ) col
WHERE t.schema_id = schema_id('base')
ORDER BY t.name

