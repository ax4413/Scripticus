DROP TABLE #XML
CREATE TABLE #XML( ID INT, OpticianAddressXML XML );

INSERT INTO #XML( ID, OpticianAddressXML )
  SELECT  ID,
          OpticianAddressXML = CONVERT( XML, OpticianAddressXML )
  FROM    Orders o
  WHERE   o.[Status] NOT IN ( 1, 6, 7, 10)


SELECT * FROM #XML


SELECT  ID,
        [OpticianAddressID]= OpticianAddress.item.value('.', 'int')
FROM    #XML
        CROSS APPLY OpticianAddressXML.nodes('/OpticianAddress/Id[1]') AS OpticianAddress(item)
ORDER BY ID


SELECT  ID,
        OpticianAddressXML
FROM    Orders o
WHERE   o.[Status] NOT IN ( 1, 6, 7, 10)
  AND   OpticianAddressXML NOT LIKE '%<Id>0</Id>%'
ORDER BY ID




;WITH data AS (
    SELECT  CAST(CAST(RequestMessage AS NVARCHAR(MAX)) AS XML) request
    FROM    ThirdPartyRequest
    WHERE   Type = (  SELECT  ListId
                              --, Description
                      FROM    List
                      WHERE   ListDescriptionId = ( SELECT ListDescriptionId FROM ListDescription WHERE Code = 'ThirdPartyRequestType' )
                              AND InternalValue = 51  )
            AND RequestMessage IS NOT NULL
)

SELECT  d.request
        , x.c.value('(FlowGroup47HItems/FlowGroup47HV1/GreenDealPlanId)[1]', 'varchar(50)')
        , x.c.query('.')
FROM    data d
        CROSS APPLY d.request.nodes('/DataFlowHeaderV1/DataFlow/FlowGroup46HItem') AS x(c)
