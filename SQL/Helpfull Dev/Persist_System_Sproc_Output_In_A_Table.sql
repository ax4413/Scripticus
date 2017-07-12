/*
	How to store results from sp_ and DBCC statements in a table
		1) the following article explains how to create a table from the deffinition of the results set for the sproc found in BOL
			http://www.simple-talk.com/community/blogs/jonathanallen/archive/2011/12/05/104623.aspx
			http://blogs.x2line.com/al/archive/2007/06/23/3173.aspx
*/

CREATE TABLE #TempTable (spid  smallint
	, ecid  smallint
	, status  nchar(30)
	, loginame  nchar(128)
	, hostname  nchar(128)
	, blk  char(5)
	, dbname  nchar(128) 
	, cmd  nchar(16)
	, request_id  int);

INSERT INTO #TempTable EXEC [sys].[sp_who] 
------------------------------------------------------------------------------------------------------------------------



CREATE TABLE #UserOption(OPT VARCHAR(100)
	, VALUE VARCHAR(50));

INSERT INTO #UserOption EXEC('DBCC useroptions')
------------------------------------------------------------------------------------------------------------------------



CREATE TABLE #x
(
    f1 VARCHAR(150)
   ,f2 VARCHAR(150)
   ,indexname VARCHAR(150)
   ,indexid VARCHAR(150)
   ,f5 VARCHAR(150)
   ,f6 VARCHAR(150)
   ,f7 VARCHAR(150)
   ,f8 VARCHAR(150)
   ,f9 VARCHAR(150)
   ,f10 VARCHAR(150)
   ,f11 VARCHAR(150)
   ,f12 VARCHAR(150)
   ,f13 VARCHAR(150)
   ,f14 VARCHAR(150)
   ,f15 VARCHAR(150)
   ,f16 VARCHAR(150)
   ,bestcount VARCHAR(150)
   ,actualcount VARCHAR(150)
   ,logicalfragmentation VARCHAR(150)
   ,f20 varchar(150))

INSERT #x 
  EXEC('DBCC SHOWCONTIG(Patient) WITH ALL_INDEXES, TABLERESULTS')
------------------------------------------------------------------------------------------------------------------------