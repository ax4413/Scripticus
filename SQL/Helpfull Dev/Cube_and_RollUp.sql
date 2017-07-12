-- ====================================================================================================
-- The example below are taken directly from this article. It is very clear
-- http://www.databasejournal.com/features/mssql/using-the-rollup-cube-and-grouping-sets-operators.html
-- ====================================================================================================

CREATE TABLE PurchaseItem (
      PurchaseID smallint identity, 
      Supplier varchar(50),
      PurchaseType varchar(20), 
      PurchaseAmt money, 
      PurchaseDate date);
INSERT INTO PurchaseItem VALUES
    ('McLendon''s','Hardware',2121.09,'2014-01-12'),
      ('Bond','Electrical',12347.87,'2014-01-18'),
      ('Craftsman','Hardware',999.99,'2014-01-22'),
      ('Stanley','Hardware',6532.09,'2014-01-31'),
      ('RubberMaid','Kitchenware',3421.10,'2014-02-03'),
      ('RubberMaid','KitchenWare',1290.90,'2014-02-07'),
      ('Glidden','Paint',12987.01,'2014-02-10'),
      ('Dunn''s','Lumber',43235.67,'2014-02-21'),
      ('Maytag','Appliances',89320.19,'2014-03-10'),
      ('Amana','Appliances',53821.19,'2014-03-12'),
      ('Lumber Surplus','Lumber',3245.59,'2014-03-14'),
      ('Global Source','Outdoor',3331.59,'2014-03-19'),
      ('Scott''s','Garden',2321.01,'2014-03-21'),
      ('Platt','Electrical',3456.01,'2014-04-03'),
      ('Platt','Electrical',1253.87,'2014-04-21'),
      ('RubberMaid','Kitchenware',3332.89,'2014-04-20'),
      ('Cresent','Lighting',345.11,'2014-04-22'),
      ('Snap-on','Hardware',2347.09,'2014-05-03'),
      ('Dunn''s','Lumber',1243.78,'2014-05-08'),
      ('Maytag','Appliances',89876.90,'2014-05-10'),
      ('Parker','Paint',1231.22,'2014-05-10'),
      ('Scotts''s','Garden',3246.98,'2014-05-12'),
      ('Jasper','Outdoor',2325.98,'2014-05-14'),
      ('Global Source','Outdoor',8786.99,'2014-05-21'),
      ('Craftsman','Hardware',12341.09,'2014-05-22');
GO


-- ===  The ROLLUP operator allows SQL Server to create subtotals and grand totals, 
-- ===  while it groups data using the GROUP BY clause.
SELECT COALESCE (PurchaseType,'GrandTotal') AS PurchaseType
     , SUM(PurchaseAmt) AS SummorizedPurchaseAmt
FROM   PurchaseItem
GROUP BY ROLLUP(PurchaseType);

SELECT MONTH(PurchaseDate) PurchaseMonth
     , CASE WHEN MONTH(PurchaseDate) IS NULL THEN 'Grand Total' 
            ELSE COALESCE (PurchaseType,'Monthly Total') END AS PurchaseType
     , SUM(PurchaseAmt) AS SummorizedPurchaseAmt
FROM   PurchaseItem
GROUP BY ROLLUP(MONTH(PurchaseDate), PurchaseType);


-- ===  The CUBE operator allows you to summarize your data similar to the ROLLUP operator.  
-- ===  The only difference is the CUBE operator will summarize your data based on every permutation 
-- ===  of the columns passed to the CUBE operator
SELECT MONTH(PurchaseDate) PurchaseMonth
     , CASE WHEN MONTH(PurchaseDate) IS NULL THEN COALESCE ('Grand Total for ' + PurchaseType ,'Grand Total')  
            ELSE COALESCE (PurchaseType,'Monthly SubTotal') END AS PurchaseType
     , SUM(PurchaseAmt) AS SummorizedPurchaseAmt
FROM   PurchaseItem
GROUP BY CUBE(MONTH(PurchaseDate), PurchaseType)
ORDER BY ISNULL(MONTH(PurchaseDate), 99);


-- ===  Sometimes you want to group your data multiple different ways.  The GROUPING SETS operator allows 
-- ===  you to do this with a single SELECT statement, instead of multiple SELECT statements with different 
-- ===  GROUP BY clauses union-ed together
SELECT MONTH(PurchaseDate) PurchaseMonth
     , PurchaseType AS PurchaseType
     , SUM(PurchaseAmt) as SummorizedPurchaseAmt
FROM   PurchaseItem
GROUP BY GROUPING SETS (MONTH(PurchaseDate), PurchaseType );

