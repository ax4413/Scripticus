-- ==========================================================================================================================
-- ====  TYPICAL DATETIME TO VARCHAR CONVERSION
SELECT  CONVERT(VARCHAR, GETDATE(), 103)    -- British/French             14/08/2014
SELECT  CONVERT(VARCHAR, GETDATE(), 121)    -- ODBC canonical             2014-08-14 16:34:22.777
SELECT  CONVERT(VARCHAR, GETDATE(), 112)    -- ISO                        20140814

SELECT  CONVERT(VARCHAR, GETDATE(), 126)    -- ISO8601                    2014-08-14T16:34:22.777
SELECT  CONVERT(VARCHAR, GETDATE(), 127)    -- ISO8601 with time zone Z.  2014-08-14T16:34:22.777


-- ==========================================================================================================================
-- ==== THE ULTIMATE VARCHAR TO DATE CONVERTER

DECLARE @DateString VARCHAR(50)
SELECT  @DateString = CAST(GETDATE() AS VARCHAR(50));

SELECT  CONVERT( DATETIME, ISNULL( @DateString,'19000101'), 103), CONVERT( SMALLDATETIME, ISNULL( @DateString,'19000101'), 103)
SELECT  CONVERT( DATETIME, ISNULL( @DateString,'19000101'), 121), CONVERT( SMALLDATETIME, ISNULL( @DateString,'19000101'), 121)


-- ==========================================================================================================================
-- ==== CONVERT microseconds to HH:mm:ss:ms
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-ver15
DECLARE @seconds DECIMAL(5,2) = 121.25
SELECT CONVERT(varchar, DATEADD(ms, @seconds * 1000, 0), 114)
-- ==========================================================================================================================
-- ==== CONVERT TO DATETIME FORM UN-TRUST WORTH STRINGS
-- ==== Edit the curent DateFormating in SQLServer
SET DATEFORMAT dmy /*22/05/2011*/
-- Is this a date if so cast else return '19010101'
SELECT  [DateValue], ISDATE([DateValue]),
        CASE WHEN ISDATE([DateValue]) = 1 THEN CONVERT(DATETIME, [DateValue], 103) ELSE '19010101' END '103'
FROM    SomeTable

-- ==== Return the curent DateFormating in SQLServer to defualt
SET DATEFORMAT mdy /*05/22/1996*/


-- ==========================================================================================================================
-- ==== SELECT ONLY THE DATE OF DATETIME
SELECT  CAST( FLOOR( CAST( GETDATE() AS FLOAT)) AS DATETIME)
SELECT  DATEADD( DAY, DATEDIFF( DAY,  0, GETDATE()), 0)


-- ==========================================================================================================================
-- ==== GET DATE PARTS
SELECT  DAY( GETDATE())
SELECT  MONTH( GETDATE())
SELECT  YEAR( GETDATE())

SELECT  DATEPART( hh, GETDATE())
SELECT  DATEPART( mi, GETDATE())


-- ==========================================================================================================================
-- ==== COMPARE DATES
SELECT  *
FROM    SomeTable
WHERE   DATEPART( yyyy, Property) = 2009
        AND DATEPART( mm, Property) = 01
        AND DATEPART( dd, Property) = 06


SELECT  *
FROM    SomeTable
WHERE   DATEDIFF( dd , Property , '01/06/2009' ) = 0


-- ==========================================================================================================================
-- ==== CALCULATE THE DIFFERNCE IN TIME BETWEEN TWO DATES. - This does not work for DateTime2
DECLARE @StartDT DATETIME = '2000-01-01 10:30:50.780'
DECLARE @EndDT   DATETIME = '2000-01-02 12:34:56.789'

SELECT  [StartDate]      = @StartDT,
        [EndDate]        = @EndDT,
        [HHH:MM:SS.MS]   = STUFF( CONVERT( VARCHAR(20), @EndDT - @StartDT, 114 ), 1, 2, DATEDIFF( hh, 0, @EndDT - @StartDT ) ),
        [DD:HH:MM:SS.MS] = RIGHT( '00' + CONVERT( VARCHAR(20), DATEDIFF( hh, 0, @EndDT - @StartDT ) / 24 ), 2 ) + ':' + RIGHT( '00' + CONVERT( VARCHAR(20), DATEDIFF(hh,0,@EndDT-@StartDT) % 24 ), 2) + ':' + SUBSTRING( CONVERT( VARCHAR(20), @EndDT - @StartDT, 114 ), CHARINDEX( ':', CONVERT( VARCHAR(20), @EndDT - @StartDT, 114 ) ) + 1, LEN( CONVERT( VARCHAR(20), @EndDT - @StartDT, 114 ) ) )


-- ==========================================================================================================================
-- ==== CALCULATE HH:MM:SS FROM A TIME IN SECONDS
DECLARE @TimeinSecond INT = 100 -- Change the seconds

SELECT  RIGHT('0' + CAST( @TimeinSecond / 3600 AS VARCHAR),2) + ':' +
	      RIGHT('0' + CAST( ( @TimeinSecond / 60) % 60 AS VARCHAR),2)  + ':' +
	      RIGHT('0' + CAST( @TimeinSecond % 60 AS VARCHAR),2)


-- ==========================================================================================================================
-- ==== FIRST DAY OF MONTH WITH TIME ZERO'ED OUT
SELECT  CAST( DATEADD( DAY, -DAY( GETDATE()) +1, CAST( GETDATE() AS DATE)) AS DATETIME)
SELECT  DATEADD( MONTH, DATEDIFF( MONTH, 0, GETDATE()), 0)
SELECT  DATEADD( DAY, 1, EOMONTH( GETDATE(), -1))
