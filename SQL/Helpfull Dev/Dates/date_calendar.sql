--====	Get details about dates between the two dates supplied

DECLARE @StartDate DATETIME = '19010101';
DECLARE @EndDate   DATETIME = '21000101';

DECLARE @NumberOfDays INT;
SELECT	@NumberOfDays = DATEDIFF( DAY, @StartDate, @EndDate );

--====	This is required to stop processing records after a certain number have been processed.
--====	I am using it in place of TOP in the sub query as it allows the use of a variable.
SET ROWCOUNT @NumberOfDays

IF( DATEDIFF( MONTH, '99991231', @EndDate ) >= 0 )
	RAISERROR (	N'The paramater @EndDate is too large it will over flow the DatetTime type if we continue this process. Max value allowed = 9999-11-30', 18, 1 ) WITH NOWAIT;
ELSE
BEGIN

	--====	This is the bulk of the sql. here is were we get deatils about these dates
	SELECT	[Date_Key]				= CAST( CONVERT( VARCHAR(8), CAST(T.D AS DATE), 112) AS INT ) ,
			[Date]					= CONVERT( DATE, T.D, 103) ,
			[Date_String_UK]		= CONVERT( VARCHAR(10), T.D, 103) ,	-- dd/mm/yyyy (UK)
			[Date_String_US]		= CONVERT( VARCHAR(10), T.D, 101) ,	-- mm/dd/yyyy (US)
			[Date_Name]				= CASE
										WHEN CONVERT( INT, DATENAME( DAY, T.D) ) < 10 THEN '0' + CONVERT( VARCHAR(2), DATEPART( dd, T.D ) )
										ELSE CONVERT( VARCHAR(2), DATEPART( dd, T.D) )
									END + ' ' + DATENAME( MONTH, T.D ) + ' ' + CONVERT( VARCHAR(4), DATEPART( YEAR, T.D) ) ,
			[Day_Of_Week]			= DATEPART( WEEKDAY, T.D ) ,
			[Day_Name_Of_Week]		= DATENAME( WEEKDAY, T.D ) ,
			[Day_Of_Month]			= DATEPART( DAY, T.D ) ,
			[Day_Of_Year]			= DATEPART( DAYOFYEAR, T.D ) ,
			[Weekday_Weekend]		= CASE WHEN DATEPART( WEEKDAY, T.D) > 5 THEN 'Weekend' else 'Weekday' END ,
			[Week_Of_Year]			= DATEPART( WEEK, T.D) ,
			[ISO_Week_Of_Year]		= ( ( DATEPART( DAYOFYEAR, DATEDIFF( DAY, 0, T.D ) / 7 * 7 + 3 ) + 6 ) / 7 ) ,
			[Month_Name]			= DATENAME( MONTH, T.D) ,
			[Month_Of_Year]			= DATEPART( MONTH, T.D) ,		
			[Is_Last_Day_Of_Month]	= CASE 
										WHEN T.D = DATEADD( DAY, -1, CAST( CONVERT( VARCHAR(6), DATEADD( MONTH, 1, T.D ), 112 ) + '01' AS DATETIME ) ) THEN 1 
										ELSE 0 
									END ,
			[Calender_Quarter]		= CASE 
										WHEN DATEPART( MONTH, T.D ) IN (1, 2, 3) THEN 1 
										WHEN DATEPART( MONTH, T.D ) IN (4, 5, 6) THEN 2 
										WHEN DATEPART( MONTH, T.D ) IN (7, 8, 9) THEN 3 
										WHEN DATEPART( MONTH, T.D ) IN (10, 11, 12) THEN 4 
									END ,
			[Calendar_Year]			= DATEPART( YEAR, T.D ) ,
			[Calendar_Year_Week]	= CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', Wk' + CAST( DATEPART( WEEK, T.D ) AS VARCHAR(2) ) ,
			[Calendar_Year_ISO_Week]= CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', IsoWk' + CAST( ( ( DATEPART( DAYOFYEAR, DATEDIFF( DAY, 0, T.D ) / 7 * 7 + 3 ) + 6 ) / 7 ) AS VARCHAR(2) ) ,
			[Calendar_Year_Month]	= CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', ' + CAST( DATENAME( MONTH, T.D ) AS VARCHAR(10) ) ,
			[Calendar_Year_Quarter] = CAST( DATEPART( YEAR, T.D ) AS VARCHAR(4) ) + ', Q' + CAST( CASE 
																									WHEN DATEPART( MONTH, T.D ) IN (1, 2, 3) THEN 1 
																									WHEN DATEPART( MONTH, T.D ) IN (4, 5, 6) THEN 2 
																									WHEN DATEPART( MONTH, T.D ) IN (7, 8, 9) THEN 3 
																									WHEN DATEPART( MONTH, T.D ) IN (10, 11, 12) THEN 4 
																								END AS VARCHAR(2) ) 
	FROM (	--====	Get a list of dates between > @StartDate. 
			--====	We only return some of these records this is handled by ROWCOUNT which stops processing at a certain value
			--====	ROWCOUNT can use a variable to set teh level TOP can not
			SELECT	[N] = ROW_NUMBER() OVER(ORDER BY T1.N, T2.N) ,
					[D] = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY T1.N, T2.N), @StartDate)
			FROM	Scratch.dbo.Tally T1
					CROSS JOIN Scratch.dbo.Tally T2
		) T		
	;
END




--SELECT	TOP 3 *
--FROM	DimDate

--SELECT	TOP 3 *
--FROM	DimTime

--SELECT	TOP 3 *
--FROM FactApplicationProcessingHistory

--SELECT	TOP 3 *
--FROM FactArrearsTransaction





SELECT TOP 86399 -- Number of seconds in a day
       IDENTITY(INT,1,1) AS N
INTO #T
FROM master.sys.all_columns ac1
	CROSS JOIN master.sys.all_columns ac2

SELECT	[ID]			= N, 
		[Time]			= CAST(DATEADD(SECOND, N, 0) AS TIME),
		[Hour_Number]	= DATEPART( HOUR, DATEADD(SECOND, N, 0)),
		[Hour_Str]		= RIGHT('00' + CAST(DATEPART( HOUR, DATEADD(SECOND, N, 0)) AS VARCHAR(2)), 2),
		[Minute_Number]	= DATEPART( MINUTE, DATEADD(SECOND, N, 0)),
		[Minute_Str]	= RIGHT('00' + CAST(DATEPART( MINUTE, DATEADD(SECOND, N, 0)) AS VARCHAR(2)), 2),
		[Second_Number]	= DATEPART( SECOND, DATEADD(SECOND, N, 0)),
		[Second_Str]	= RIGHT('00' + CAST(DATEPART( SECOND, DATEADD(SECOND, N, 0)) AS VARCHAR(2)), 2),
		[AM_PM]			= CASE WHEN DATEADD(SECOND, 0, N) < 43200 THEN 'AM' ELSE 'PM' END 
FROM	#T
ORDER BY id