SELECT ROW_NUMBER() OVER(ORDER BY CreatedTime) AS ID, customerid 
INTO wrk_customer
FROM Customer