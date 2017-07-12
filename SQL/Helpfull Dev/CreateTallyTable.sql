--===================================================================
--      Create a Tally table from 1 to 11000
--===================================================================

--===== Do this in a nice, safe place that everyone has.
    USE tempdb
;

--===== Conditionally drop the tables to make reruns in
     -- SSMS easier. The 3 part naming is overkill but
     -- I want to make sure we don't accidently drop a
     -- real table.
     IF OBJECT_ID('tempdb.dbo.TestTable','U') IS NOT NULL
        DROP TABLE tempdb.dbo.TestTable
;
     IF OBJECT_ID('tempdb.dbo.Tally','U') IS NOT NULL
        DROP TABLE tempdb.dbo.Tally
;

--===== Create and populate the Tally table on the fly.
     -- Obviously, if you already have one, you don't need to do this
     -- but I wanted those that didn't already have on to be able to
     -- participate. Change the tables in the FROM clause to
     -- master.dbo.syscolumns if using SQL Server 2000 or earlier.
 SELECT TOP 11000
        IDENTITY(INT,1,1) AS N
   INTO dbo.Tally
   FROM master.sys.all_columns ac1
	   CROSS JOIN master.sys.all_columns ac2
;

--===== Add a CLUSTERED Primary Key to maximize performance
  ALTER TABLE dbo.Tally
    ADD CONSTRAINT PK_Tally_N
        PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100
;

--===== Allow the general public to use it
  GRANT SELECT ON dbo.Tally TO PUBLIC
;

