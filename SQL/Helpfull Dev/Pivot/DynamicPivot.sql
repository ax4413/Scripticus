--test data
select p.Name As ProductName, b.BranchName, bsku.InStock as Instock
into #tmp
from BranchSKU bsku
inner join Product p on p.ProductID = bsku.SKUID
inner join Branch b on b.BranchID = bsku.BranchID

--###########################################################

DECLARE @columns VARCHAR(Max)
DECLARE @isnullColumns VARCHAR(Max)
DECLARE @TotalColumns VARCHAR(Max)
DECLARE @query VARCHAR(Max)

SELECT 
	@columns = COALESCE(@columns + ',' + QUOTENAME(CAST(BranchName as varchar))
	, QUOTENAME(CAST(BranchName as varchar)))
	, @isnullColumns = COALESCE(@IsnullColumns + ',ISNULL(' + QUOTENAME(CAST(BranchName as varchar)) + ',0) As ' + QUOTENAME(CAST(BranchName as varchar))
	, 'ISNULL(' + QUOTENAME(CAST(BranchName as varchar))+ ',0) AS ' + QUOTENAME(CAST(BranchName as varchar)))
	, @TotalColumns = 
	COALESCE(@TotalColumns + ',SUM(' + QUOTENAME(CAST(BranchName as varchar)) + ') as ' + QUOTENAME(CAST(BranchName as varchar))
	, 'SUM(' + QUOTENAME(CAST(BranchName as varchar))+ ') as ' + QUOTENAME(CAST(BranchName as varchar)))
FROM #tmp
GROUP BY BranchName

SET @query = '
SELECT ProductName, ' + @isnullColumns + '
FROM #tmp
PIVOT
(
SUM(Instock)
FOR [BranchName]
IN (' + @columns + ')
)
AS p'

EXEC(@query)

DROP TABLE #TMP

--####################################################################################################################
--####################################################################################################################
--####################################################################################################################
--####################################################################################################################
-- example two with a grand total row


CREATE TABLE #temp123
(
Country varchar(15),
Variable varchar(20),
VaribleValue int
)

INSERT INTO #temp123 VALUES ('North America','Sales',2000000)
INSERT INTO #temp123 VALUES ('North America','Expenses',1250000)
INSERT INTO #temp123 VALUES ('North America','Taxes',250000)
INSERT INTO #temp123 VALUES ('North America','Profit',500000)


INSERT INTO #temp123 VALUES ('Europe','Sales',2500000)
INSERT INTO #temp123 VALUES ('Europe','Expenses',1250000)
INSERT INTO #temp123 VALUES ('Europe','Taxes',500000)
INSERT INTO #temp123 VALUES ('Europe','Profit',750000)


INSERT INTO #temp123 VALUES ('South America','Sales',500000)
INSERT INTO #temp123 VALUES ('South America','Expenses',250000)

INSERT INTO #temp123 VALUES ('Asia','Sales',800000)
INSERT INTO #temp123 VALUES ('Asia','Expenses',350000)
INSERT INTO #temp123 VALUES ('Asia','Taxes',100000)



DECLARE @columns VARCHAR(8000)
DECLARE @TotalColumns VARCHAR(8000)

SELECT 
@columns = COALESCE(@columns + ',[' + cast(Variable as varchar) + ']',
                         '[' + cast(Variable as varchar)+ ']'),                
@TotalColumns = COALESCE(@TotalColumns + ',SUM([' + cast(Variable as varchar) + ']) as [' + cast(Variable as varchar) + ']',
                         'SUM([' + cast(Variable as varchar)+ ']) as [' + cast(Variable as varchar)+ ']')
			
FROM    #temp123
GROUP BY Variable



DECLARE @query VARCHAR(8000)
SET @query = '
SELECT *
FROM #temp123
PIVOT
 (
 MAX(VaribleValue)
 FOR [Variable]
 IN (' + @columns + ')
 )
 AS p
UNION
SELECT ''Grand Total'',' + @TotalColumns + '
FROM #temp123
PIVOT
 (
 MAX(VaribleValue)
 FOR [Variable]
 IN (' + @columns + ')
 )
 AS total
 '

EXECUTE(@query)


DROP TABLE #temp123
