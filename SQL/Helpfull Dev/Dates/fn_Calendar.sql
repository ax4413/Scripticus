--==============================================================================================
--	Function to replace the calendar table or populate the calendar table
--	http://www.mssqltips.com/sqlservertip/2800/sql-server-function-to-return-a-range-of-dates/
--==============================================================================================

ALTER FUNCTION [dbo].[fn_Calendar]
(     
      @Increment	CHAR(1),
      @StartDate    DATETIME,
      @EndDate      DATETIME
)
RETURNS  
@SelectedRange    TABLE 
(DateKey Varchar(8), IndividualDate DATETIME, YearID int, MonthID int, QuaterID int, WeekID int, DayID int, QuaterName Varchar(50), WeekName varchar(50))
AS 
BEGIN

	;WITH cteRange (DateRange) AS (
        SELECT @StartDate
        UNION ALL
        SELECT 
                CASE
                    WHEN @Increment = 'd' THEN DATEADD(dd, 1, DateRange)
                    WHEN @Increment = 'w' THEN DATEADD(ww, 1, DateRange)
                    WHEN @Increment = 'm' THEN DATEADD(mm, 1, DateRange)
                END
        FROM cteRange
        WHERE DateRange <= 
                CASE
                    WHEN @Increment = 'd' THEN DATEADD(dd, -1, @EndDate)
                    WHEN @Increment = 'w' THEN DATEADD(ww, -1, @EndDate)
                    WHEN @Increment = 'm' THEN DATEADD(mm, -1, @EndDate)
                END)
          
      INSERT INTO @SelectedRange (DateKey, IndividualDate, YearID, MonthID, QuaterID, WeekID, DayID, QuaterName, WeekName)
		  SELECT convert(varchar(8), DateRange, 112) [DateKey]
			, DateRange [IndividualDate]
			, year(DateRange) [YearID]
			, month(DateRange) [MonthID]
			, datepart(quarter, DateRange) [QuarterID]
			, datepart(week, DateRange) [WeekID]
			, day(DateRange) [DayID]
			, 'Quarter ' + right('00' + cast(datepart(quarter, DateRange) as varchar(2)), 2) + ' ' + cast(year(DateRange) as varchar(4)) [QuarterName]
			, 'Week ' + right('00' + cast(datepart(week, DateRange) as varchar(2)), 2) + ' ' + cast(year(DateRange) as varchar(4)) [WeekName]
		  FROM cteRange
		  ORDER BY DateRange
		  OPTION (MAXRECURSION 32767);
		  --OPTION (MAXRECURSION 3660);
      RETURN
END
GO


select * from fn_Calendar('d','1930-01-02 00:00:00','2012-05-01 00:00:00')
select * from fn_Calendar('M','1930-01-02 00:00:00','2012-05-01 00:00:00')
select * from fn_Calendar('Y','1930-01-02 00:00:00','2012-05-01 00:00:00')