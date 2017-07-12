DECLARE @discountPercentage decimal(5,2);
SET @discountPercentage = '## Percentage Here %%% ##';

SELECT TOP 25
Cost
, (@discountPercentage / 100) * Cost as 'Discount £'
, CAST(Cost - ((@discountPercentage / 100) * Cost) as smallmoney) as SellingPrice
from price
where Cost != 0