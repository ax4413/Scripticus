select * from accountingperiod_s order by 1 desc


declare @uid uniqueidentifier = newid()

exec RegisterNgUserId @userid = -1, @internaltransactionid = @uid


update accountingperiod
 set enddate = dateadd(year,1, enddate)
 where accountingperiodid = 479 

select dbo.GetNgInternalTransactionId()




-- === look in the quese
SELECT  TOP 1000 *, 
        casted_message_body = CASE message_type_name WHEN 'X' 
                                THEN CAST(message_body AS NVARCHAR(MAX)) 
                                ELSE message_body 
                              END 
FROM [TrackingNotificationQueue] WITH(NOLOCK)

SELECT  TOP 1000 *, 
        casted_message_body = CASE message_type_name WHEN 'X' 
                                THEN CAST(message_body AS NVARCHAR(MAX)) 
                                ELSE message_body 
                              END 
FROM [TrackingRequestQueue] WITH(NOLOCK)

SELECT  TOP 1000 *, 
        casted_message_body = CASE message_type_name WHEN 'X' 
                                THEN CAST(message_body AS NVARCHAR(MAX)) 
                                ELSE message_body 
                              END 
FROM [TrackingResponseQueue] WITH(NOLOCK)

/*
?<Changes>
  <InternalTransactionId>4BA9DBB1-E26F-44C9-B499-92A2BF8A16F0</InternalTransactionId>
  <TableName>AccountingPeriod</TableName>
  <TransactionTimestamp>2016-08-23T11:46:58.8407256</TransactionTimestamp> -- correct time
  <PrimaryKeyIds>
    <Row>
      <Id>479</Id>
    </Row>
  </PrimaryKeyIds>
</Changes>
*/

select * from VanillaAuditDEV_JB..TransactiontableLookup