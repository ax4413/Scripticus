
/*
Turn table vars into #tables.
Search for: (declare|DECLARE|Declare):Wh*\n*\@{(:a*)}:Wh*(table|TABLE|Table)
Replace with: CREATE  TABLE #\1

(declare|DECLARE|Declare) - searching for the word 'declare' and covering different cases. | means OR.
:Wh* - looking for zero or more tab or whitespace chars.
\n* - looking for zero or more new line chars.
\@ - escaping the @. 
{(:a+)} - Capture group with the {}. You're going to hold it in memory so you can use it later.
		  Grouping the text with ().  Inside the group you're capturing :a+ which is 1 or more
		  chars.
(table|TABLE|Table) - Searching for the word 'table' and covering the differnt cases. | means OR.
*/
declare @Table1 table 
(
CustomerID nchar(5) NOT NULL,
CustomerName int NULL,
CustomerAddr VARCHAR(MAX)
) 

declare 
@MyTable table 
(
CustomerID nchar(5) NOT NULL,
CustomerName int NULL,
CustomerAddr VARCHAR(MAX)
) 

declare 
		@CustTemp Table 
(
CustomerID nchar(5) NOT NULL,
CustomerName int NULL,
CustomerAddr VARCHAR(MAX)
) 

			DECLARE 
					@ATable table 
					(
					CustomerID nchar(5) NOT NULL,
					CustomerName int NULL,
					CustomerAddr VARCHAR(MAX)
					) 