DROP TABLE [dbo].[Calendar]
GO
CREATE TABLE [dbo].[Calendar](
	[Date_Key]                [int]         NOT NULL,
	[Date]                    [date]        NOT NULL,
	[DateTime]                [datetime]    NOT NULL,
	[Date_String_UK]          [varchar](15) NOT NULL,
	[Date_String_US]          [varchar](15) NOT NULL,
	[Date_Name]               [varchar](50) NOT NULL,
	[Day_Of_Week]             [int]         NOT NULL,
	[Day_Name_Of_Week]        [varchar](15) NOT NULL,
	[Day_Of_Month]            [int]         NOT NULL,
	[Day_Of_Year]             [int]         NOT NULL,
	[Weekday_Weekend]         [varchar](15) NOT NULL,
	[Week_Of_Year]            [int]         NOT NULL,
	[ISO_Week_Of_Year]        [int]         NOT NULL,
	[Month_Name]              [varchar](15) NOT NULL,
	[Month_Of_Year]           [int]         NOT NULL,
	[Is_Week_Day]             [bit]         NOT NULL,
	[Is_Last_Day_Of_Month]    [bit]         NOT NULL,
  [Is_Bank_Holiday]         [bit]             NULL,
	[Calender_Quarter]        [int]         NOT NULL,
	[Calendar_Year]           [int]         NOT NULL,
	[Calendar_Year_Week]      [varchar](15) NOT NULL,
	[Calendar_Year_ISO_Week]  [varchar](15) NOT NULL,
	[Calendar_Year_Month]     [varchar](20) NOT NULL,
	[Calendar_Year_Quarter]   [varchar](15) NOT NULL,
  [Next_Working_Day]        [date]            NULL,
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Calendar] ADD CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED 
(
	[Date_Key] ASC
)
GO

ALTER TABLE [dbo].[Calendar] ADD CONSTRAINT [UQ_Calendar_Date] UNIQUE NONCLUSTERED 
(
	[Date] ASC
)
GO

ALTER TABLE [dbo].[Calendar] ADD CONSTRAINT [UQ_Calendar_DateTime] UNIQUE NONCLUSTERED 
(
	[DateTime] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_Calendar_IsWeekDayAndBankHolidayDate]
ON [dbo].[Calendar] ([Is_Week_Day],[Is_Bank_Holiday],[Date])
GO


-- =======================================================================================================



DROP FUNCTION Internal.GetCalendar
GO
CREATE FUNCTION Internal.GetCalendar
(
	@NumberOfDays INT,
  @StartDate DATETIME
)
RETURNS @Calendar TABLE 
(
	[Date_Key]                [int]         NOT NULL,
	[Date]                    [date]        NOT NULL,
	[DateTime]                [datetime]    NOT NULL,
	[Date_String_UK]          [varchar](15) NOT NULL,
	[Date_String_US]          [varchar](15) NOT NULL,
	[Date_Name]               [varchar](50) NOT NULL,
	[Day_Of_Week]             [int]         NOT NULL,
	[Day_Name_Of_Week]        [varchar](15) NOT NULL,
	[Day_Of_Month]            [int]         NOT NULL,
	[Day_Of_Year]             [int]         NOT NULL,
	[Weekday_Weekend]         [varchar](15) NOT NULL,
	[Week_Of_Year]            [int]         NOT NULL,
	[ISO_Week_Of_Year]        [int]         NOT NULL,
	[Month_Name]              [varchar](15) NOT NULL,
	[Month_Of_Year]           [int]         NOT NULL,
	[Is_Week_Day]             [bit]         NOT NULL,
	[Is_Last_Day_Of_Month]    [bit]         NOT NULL,
  [Is_Bank_Holiday]         [bit]             NULL,
	[Calender_Quarter]        [int]         NOT NULL,
	[Calendar_Year]           [int]         NOT NULL,
	[Calendar_Year_Week]      [varchar](15) NOT NULL,
	[Calendar_Year_ISO_Week]  [varchar](15) NOT NULL,
	[Calendar_Year_Month]     [varchar](20) NOT NULL,
	[Calendar_Year_Quarter]   [varchar](15) NOT NULL
)
AS
BEGIN
	WITH  E1(N) AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                   SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                   SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 ) -- 1*10^1 or 10 rows
      , E2(N) AS ( SELECT 1 FROM E1 a, E1 b )                                          -- 1*10^2 or 100 rows
      , E4(N) AS ( SELECT 1 FROM E2 a, E2 b )                                          -- 1*10^4 or 10,000 rows
      , E8(N) AS ( SELECT 1 FROM E4 a, E4 b )                                          -- 1*10^8 or 100,000,000 rows
      , E9(N) AS ( SELECT TOP (@NumberOfDays) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E8 )     
      , Tally AS ( SELECT [N] = N
                        , [D] = DATEADD(dd, N-1, @StartDate) 
                   FROM   E9 )


  INSERT INTO @Calendar ([Date_Key],[Date],[DateTime],[Date_String_UK],[Date_String_US],[Date_Name],[Day_Of_Week]
                        ,[Day_Name_Of_Week],[Day_Of_Month],[Day_Of_Year],[Weekday_Weekend],[Week_Of_Year]
                        ,[ISO_Week_Of_Year],[Month_Name],[Month_Of_Year],[Is_Week_Day],[Is_Last_Day_Of_Month]
                        ,[Calender_Quarter],[Calendar_Year],[Calendar_Year_Week]
                        ,[Calendar_Year_ISO_Week],[Calendar_Year_Month],[Calendar_Year_Quarter])
      SELECT	[Date_Key]				      = CAST( CONVERT( VARCHAR(8), CAST(T.D AS DATE), 112) AS INT ) ,
			        [Date]					        = CONVERT( DATE, T.D, 103) ,
              [DateTime]              = D ,
			        [Date_String_UK]		    = CONVERT( VARCHAR(10), T.D, 103) ,	-- dd/mm/yyyy (UK)
			        [Date_String_US]		    = CONVERT( VARCHAR(10), T.D, 101) ,	-- mm/dd/yyyy (US)
			        [Date_Name]				      = CASE WHEN CONVERT( INT, DATENAME( DAY, T.D) ) < 10 THEN '0' + CONVERT( VARCHAR(2), DATEPART( dd, T.D ) )
										                         ELSE CONVERT( VARCHAR(2), DATEPART( dd, T.D) )
									                      END + ' ' + DATENAME( MONTH, T.D ) + ' ' + CONVERT( VARCHAR(4), DATEPART( YEAR, T.D) ) ,
			        [Day_Of_Week]			      = DATEPART( WEEKDAY, T.D ) ,
			        [Day_Name_Of_Week]		  = DATENAME( WEEKDAY, T.D ) ,
			        [Day_Of_Month]			    = DATEPART( DAY, T.D ) ,
			        [Day_Of_Year]			      = DATEPART( DAYOFYEAR, T.D ) ,
			        [Weekday_Weekend]		    = CASE WHEN DATEPART( WEEKDAY, T.D) > 5 THEN 'Weekend' else 'Weekday' END ,
			        [Week_Of_Year]			    = DATEPART( WEEK, T.D) ,
			        [ISO_Week_Of_Year]		  = ( ( DATEPART( DAYOFYEAR, DATEDIFF( DAY, 0, T.D ) / 7 * 7 + 3 ) + 6 ) / 7 ) ,
			        [Month_Name]			      = DATENAME( MONTH, T.D) ,
			        [Month_Of_Year]			    = DATEPART( MONTH, T.D) ,	
              [Is_Week_Day]           = CAST(CASE WHEN DATEPART( WEEKDAY, T.D ) IN (6,7) THEN 0 
                                                  ELSE 1 END AS BIT),	
			        [Is_Last_Day_Of_Month]	= CAST(CASE WHEN T.D = DATEADD( DAY, -1, CAST( CONVERT( VARCHAR(6), DATEADD( MONTH, 1, T.D ), 112 ) + '01' AS DATETIME ) ) THEN 1 
										                              ELSE 0 END AS BIT) ,
			        [Calender_Quarter]		  = CASE WHEN DATEPART( MONTH, T.D ) IN (1, 2, 3) THEN 1 
										                         WHEN DATEPART( MONTH, T.D ) IN (4, 5, 6) THEN 2 
										                         WHEN DATEPART( MONTH, T.D ) IN (7, 8, 9) THEN 3 
										                         WHEN DATEPART( MONTH, T.D ) IN (10, 11, 12) THEN 4 END ,
			        [Calendar_Year]			    = DATEPART( YEAR, T.D ) ,
			        [Calendar_Year_Week]	  = CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', Wk' + CAST( DATEPART( WEEK, T.D ) AS VARCHAR(2) ) ,
			        [Calendar_Year_ISO_Week]= CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', IsoWk' + CAST( ( ( DATEPART( DAYOFYEAR, DATEDIFF( DAY, 0, T.D ) / 7 * 7 + 3 ) + 6 ) / 7 ) AS VARCHAR(2) ) ,
			        [Calendar_Year_Month]	  = CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', ' + CAST( DATENAME( MONTH, T.D ) AS VARCHAR(10) ) ,
			        [Calendar_Year_Quarter] = CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', Q' + CAST( CASE WHEN DATEPART( MONTH, T.D ) IN (1, 2, 3) THEN 1 
																									                                                       WHEN DATEPART( MONTH, T.D ) IN (4, 5, 6) THEN 2 
																									                                                       WHEN DATEPART( MONTH, T.D ) IN (7, 8, 9) THEN 3 
																									                                                       WHEN DATEPART( MONTH, T.D ) IN (10, 11, 12) THEN 4 
																								                                                    END AS VARCHAR(2) )
      FROM    Tally T	
	
	RETURN 
END
GO


-- =======================================================================================================


DROP PROCEDURE Internal.Calendar_Load
GO
CREATE PROCEDURE Internal.Calendar_Load
(
  @NumberOfDays INT   = 100000,
  @StartDate DATETIME = '19000101'
)
AS
BEGIN 

  INSERT INTO dbo.Calendar ([Date_Key],[Date],[DateTime],[Date_String_UK],[Date_String_US],[Date_Name],[Day_Of_Week]
                           ,[Day_Name_Of_Week],[Day_Of_Month],[Day_Of_Year],[Weekday_Weekend],[Week_Of_Year]
                           ,[ISO_Week_Of_Year],[Month_Name],[Month_Of_Year],[Is_Week_Day],[Is_Last_Day_Of_Month]
                           ,[Is_Bank_Holiday], [Calender_Quarter],[Calendar_Year],[Calendar_Year_Week]
                           ,[Calendar_Year_ISO_Week],[Calendar_Year_Month],[Calendar_Year_Quarter])
      SELECT  [Date_Key],[Date],[DateTime],[Date_String_UK],[Date_String_US],[Date_Name],[Day_Of_Week]
             ,[Day_Name_Of_Week],[Day_Of_Month],[Day_Of_Year],[Weekday_Weekend],[Week_Of_Year]
             ,[ISO_Week_Of_Year],[Month_Name],[Month_Of_Year],[Is_Week_Day],[Is_Last_Day_Of_Month]
             ,0,[Calender_Quarter],[Calendar_Year],[Calendar_Year_Week]
             ,[Calendar_Year_ISO_Week],[Calendar_Year_Month],[Calendar_Year_Quarter] 
      FROM    Internal.GetCalendar(@NumberOfDays, @StartDate)
  RAISERROR('Loaded Calendar table',0,0) WITH NOWAIT


  UPDATE  c
     SET  Is_Bank_Holiday = 1
    FROM  dbo.Calendar c
          INNER JOIN BankHoliday bh
                  ON CAST(bh.BankHolidayDate AS DATE)= c.[Date]
  RAISERROR('Set all the Is_Bank_Holiday properties on the Calendar table to 1 where it is a bank holiday',0,0) WITH NOWAIT
  

  -- ===  Update the stats to resolve the very slow nature of updating a table that has no stats
  UPDATE STATISTICS dbo.Calendar
  WITH FULLSCAN
  


  --UPDATE  c
  --   SET  Next_working_Day = x.NextWorkingDay
  --  FROM  dbo.Calendar c
  --        INNER JOIN (  SELECT  [Date_key]        = c1.Date_key
  --                            , [Date]            = c1.date
  --                            , [NextWorkingDay]  = MIN(c2.Date)
  --                      FROM    dbo.Calendar c1
  --                              LEFT OUTER JOIN dbo.Calendar c2
  --                                      ON  c2.Date > c1.Date
  --                                      AND c2.Is_Week_Day = 1
  --                                      AND c2.Is_Bank_Holiday = 0
  --                      GROUP BY c1.Date_key
  --                            , c1.date  ) x
  --                On x.Date_key = c.Date_Key
  --RAISERROR('Set the Next_working_Day property on the Calendar table to a date where we can calculate the next working day ',0,0) WITH NOWAIT


  --DECLARE @YearOfFirstBankHoliday INT
  --      , @YearOfLastBankHoliday  INT

  --SELECT  @YearOfFirstBankHoliday = MIN(Calendar_Year) 
  --      , @YearOfLastBankHoliday  = MAX(Calendar_Year)
  --FROM    dbo.Calendar 
  --WHERE   Is_Bank_Holiday IS NOT NULL

  --UPDATE  dbo.Calendar
  --   SET  Is_Bank_Holiday = 0
  -- WHERE  [Calendar_Year] >= @YearOfFirstBankHoliday
  --   AND  [Calendar_Year] <= @YearOfLastBankHoliday
  --RAISERROR('Set all the Is_Bank_Holiday properties on the Calendar table to 0 where there dates fall within the range of bank holidays we have',0,0) WITH NOWAIT

  ---- ===  No bank holidays defined for these years. so we cant raelly know when the next working day is
  --UPDATE  dbo.Calendar
  --   SET  Next_working_Day = NULL
  -- WHERE  [Calendar_Year] >= @YearOfFirstBankHoliday
  --    OR  [Calendar_Year] <= @YearOfLastBankHoliday
  --RAISERROR('Set all the Next_working_Day properties on the Calendar table to NULL where their dates fall outside of the range of bank holidays',0,0) WITH NOWAIT

END
GO



-- =======================================================================================================


TRUNCATE TABLE dbo.Calendar 
EXEC Internal.Calendar_Load 100000, '19000101'


SELECT * FROM BankHoliday

SELECT * FROM dbo.Calendar WHERE CALENDAR_YEAR = 2009
SELECT * FROM dbo.Calendar WHERE Is_Week_Day = 1 AND Is_Bank_Holiday = 0




  UPDATE  c
     SET  Next_working_Day = x.NextWorkingDay
    FROM  dbo.Calendar c
          INNER JOIN (  SELECT  [Date_key]        = c1.Date_key
                              , [Date]            = c1.date
                              , [NextWorkingDay]  = MIN(c2.Date)
                        FROM    dbo.Calendar c1
                                LEFT OUTER JOIN dbo.Calendar c2
                                        ON  c2.Date > c1.Date
                                        AND c2.Is_Week_Day = 1
                                        AND c2.Is_Bank_Holiday = 0
                        GROUP BY c1.Date_key
                              , c1.date  ) x
                  On x.Date_key = c.Date_Key


SELECT Date, LEAD(Date) OVER (ORDER BY Date)
FROM Calendar



UPDATE  c
   SET  Next_working_Day = x.Next_working_Day
  FROM  Calendar c
        INNER JOIN (  SELECT Date_Key, LEAD(Date) OVER (ORDER BY Date) AS Next_working_Day
                      FROM Calendar ) x
                ON c.Date_key = x.Date_Key


SELECT  *
FROM    dbo.Calendar c
        INNER JOIN 

SELECT  Date
FROM    dbo.Calendar
WHERE   Is_Week_Day = 0
   OR   Is_Bank_Holiday = 1