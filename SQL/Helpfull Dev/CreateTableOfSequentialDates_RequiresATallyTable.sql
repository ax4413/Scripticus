--===================================================================
--      Create and populate a test table with dates between D1 & D2.
--	   A tally table is required to perform this action
--===================================================================

--===== Define the start and end dates for the testing.
DECLARE @StartDate DATETIME
,       @EndDate   DATETIME
;
 SELECT @StartDate = '2009-12-24'
,       @EndDate   = '2019-01-07'
;

--===== Create and populate the test table on-the-fly.
     -- Obviously, this depends on a Tally Table being
     -- present in TempDB. Change that to wherever
     -- your Tally Table is or what it's named.
 SELECT Date = DATEADD(dd,t.N-1,@StartDate)
   INTO dbo.TestTable
   FROM dbo.Tally t
  WHERE t.N < DATEDIFF(dd,@StartDate,@EndDate)+2
  ORDER BY t.N
;
GO