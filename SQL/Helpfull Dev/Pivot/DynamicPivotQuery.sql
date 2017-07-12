
--CREATE TABLE dbo.Products
--(
--  ProductID INT PRIMARY KEY,
--  Name      NVARCHAR(255) NOT NULL UNIQUE
--  /* other columns */
--);
--INSERT dbo.Products VALUES
--(1, N'foo'),
--(2, N'bar'),
--(3, N'kin');
--CREATE TABLE dbo.OrderDetails
--(
--  OrderID INT,
--  ProductID INT NOT NULL
--    FOREIGN KEY REFERENCES dbo.Products(ProductID),
--  Quantity INT
--  /* other columns */
--);
--INSERT dbo.OrderDetails VALUES
--(1, 1, 1),
--(1, 2, 2),
--(2, 1, 1),
--(3, 3, 1);


--INSERT dbo.Products SELECT 4, N'blat';
--INSERT dbo.OrderDetails SELECT 4,4,5;



DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
SET @columns = N'';
SELECT @columns += N', p.' + QUOTENAME(Name)
  FROM (SELECT p.Name 
		FROM dbo.Products AS p
			INNER JOIN dbo.OrderDetails AS o ON p.ProductID = o.ProductID
  GROUP BY p.Name) AS x;


SET @sql = N'
SELECT ' + STUFF(@columns, 1, 2, '') + '
FROM
(
  SELECT p.Name, o.Quantity
   FROM dbo.Products AS p
	INNER JOIN dbo.OrderDetails AS o ON p.ProductID = o.ProductID
) AS j
PIVOT
(
  SUM(Quantity) FOR Name IN ('
  + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '')
  + ')
) AS p;';
PRINT @sql;
EXEC sp_executesql @sql;