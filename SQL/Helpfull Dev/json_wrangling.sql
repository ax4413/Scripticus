declare @json nvarchar(max) = N'[
  {
    "Id": 1807080,
    "InvoiceId": 1605555
  },
  {
    "Id": 1807081,
    "InvoiceId": 1605555
  },
  {
    "Id": 1807082,
    "InvoiceId": 1605555
  }
]'

-- gets one Id at position x
select JSON_Value(@json,  '$[0].Id')

-- gets all Id's
SELECT JSON_VALUE(value, '$.Id'), *
  FROM OPENJSON(@json,'$');





CREATE TABLE InvoiceTable (Items varchar(1000))
INSERT INTO InvoiceTable (Items) 
VALUES ('
    [
      {
        "Id": 1807080,
        "InvoiceId": 1605555,
        "UnitRate": 6924.00,
        "Total": 6924.00
      },
      {
        "Id": 1807081,
        "InvoiceId": 1605555,
        "UnitRate": 16924.00,
        "Total": 16924.00
      },
      {
        "Id": 1807082,
        "InvoiceId": 1605555
      }
    ]
')



SELECT j.*
FROM InvoiceTable i
CROSS APPLY OPENJSON(i.Items) WITH (
   Id int '$.Id',
   InvoiceId int '$.InvoiceId',
   UnitRate numeric(10, 2) '$.UnitRate',
   Total numeric(10, 2) '$.Total'
) j