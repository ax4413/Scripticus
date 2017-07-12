-- ====	https://www.simple-talk.com/sql/t-sql-programming/on-handling-dates-in-sql/?utm_source=sqlservercentral&utm_medium=publink&utm_content=datesinsql

DECLARE @my_year INT
SELECT	@my_year = 1808

SELECT 	[IsALeapYear]	= CASE	WHEN (@my_year %400) = 0 THEN 'Yes'
								WHEN (@my_year % 100) = 0 THEN 'No'
								ELSE CASE WHEN (@my_year % 4) = 0 THEN 'Yes' ELSE 'No 'END 
  							END ;