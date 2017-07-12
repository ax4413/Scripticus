--===================================================================
--		Use the Create Tally table Script to generate the tally table
--		This code is taken from:
--		http://www.sqlservercentral.com/articles/T-SQL/97910/
--===================================================================
 SELECT Date    = CONVERT(CHAR(10),Date,120)--Display purposes only
,       DOW     = LEFT(DATENAME(dw,Date),9) --Here just for reference
,       ISOWeek = (DATEPART(dy,DATEDIFF(dd,0,Date)/7*7+3)+6)/7
   FROM dbo.TestTable
;