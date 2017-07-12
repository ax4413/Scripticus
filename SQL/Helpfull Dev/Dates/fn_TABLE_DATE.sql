IF EXISTS ( SELECT  *
            FROM    dbo.sysobjects
            WHERE   id = object_id(N'[dbo].[F_TABLE_DATE]')
                    AND xtype in (N'FN', N'IF', N'TF') )
    DROP FUNCTION [dbo].[F_TABLE_DATE]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION dbo.F_TABLE_DATE (
    @FIRST_DATE        datetime,
    @LAST_DATE        datetime
)
/*
Function: dbo.F_TABLE_DATE

http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=61519

This function returns a date table containing all dates
from @FIRST_DATE through @LAST_DATE inclusive.
@FIRST_DATE must be less than or equal to @LAST_DATE.
The valid date range is 1754-01-01 through 9997-12-31.
If any input parameters are invalid, the fuction will produce
an error.

The table returned by F_TABLE_DATE contains a date and
columns with many calculated attributes of that date.
It is designed to make it convenient to get various commonly
needed date attributes without having to program and test
the same logic in many applications.

F_TABLE_DATE is primarily intended to load a permanant
date table, but it can be used directly by an application
when the date range needed falls outside the range loaded
in a permanant table.

If F_TABLE_DATE is used to load a permanant table, the create
table code can be copied from this function.  For a permanent
date table, most columns should be indexed to produce the
best application performance.


Column Descriptions
------------------------------------------------------------------


DATE_ID
    Unique ID = Days since 1753-01-01

DATE
    Date at Midnight(00:00:00.000)

NEXT_DAY_DATE
    Next day after DATE at Midnight(00:00:00.000)
    Intended to be used in queries against columns
    containing datetime values (1998-12-13 14:35:16)
    that need to join to a DATE.
    Example:

    from
        MyTable a
        join
        DATE b
        on    a.DateTimeCol >= b. DATE    and
            a.DateTimeCol < b.NEXT_DAY_DATE

YEAR
    Year number in format YYYY, Example = 2005

YEAR_QUARTER
    Year and Quarter number in format YYYYQ, Example = 20052

YEAR_MONTH
    Year and Month number in format YYYYMM, Example = 200511

YEAR_DAY_OF_YEAR
    Year and Day of Year number in format YYYYDDD, Example = 2005364

QUARTER
    Quarter number in format Q, Example = 4

MONTH
    Month number in format MM, Example = 11

DAY_OF_YEAR
    Day of Year number in format DDD, Example = 362

DAY_OF_MONTH
    Day of Month number in format DD, Example = 31

DAY_OF_WEEK
    Day of week number, Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7

YEAR_NAME
    Year name text in format YYYY, Example = 2005

YEAR_QUARTER_NAME
    Year Quarter name text in format YYYY QQ, Example = 2005 Q3

YEAR_MONTH_NAME
    Year Month name text in format YYYY MMM, Example = 2005 Mar

YEAR_MONTH_NAME_LONG
    Year Month long name text in format YYYY MMMMMMMMM,
    Example = 2005 September

QUARTER_NAME
    Quarter name text in format QQ, Example = Q1

MONTH_NAME
    Month name text in format MMM, Example = Mar

MONTH_NAME_LONG
    Month long name text in format MMMMMMMMM, Example = September

WEEKDAY_NAME
    Weekday name text in format DDD, Example = Tue

WEEKDAY_NAME_LONG
    Weekday long name text in format DDDDDDDDD, Example = Wednesday

START_OF_YEAR_DATE
    First Day of Year that DATE is in

END_OF_YEAR_DATE
    Last Day of Year that DATE is in

START_OF_QUARTER_DATE
    First Day of Quarter that DATE is in

END_OF_QUARTER_DATE
    Last Day of Quarter that DATE is in

START_OF_MONTH_DATE
    First Day of Month that DATE is in

END_OF_MONTH_DATE
    Last Day of Month that DATE is in

*** Start and End of week columns allow selections by week
*** for any week start date needed.

START_OF_WEEK_STARTING_SUN_DATE
    First Day of Week starting Sunday that DATE is in

END_OF_WEEK_STARTING_SUN_DATE
    Last Day of Week starting Sunday that DATE is in

START_OF_WEEK_STARTING_MON_DATE
    First Day of Week starting Monday that DATE is in

END_OF_WEEK_STARTING_MON_DATE
    Last Day of Week starting Monday that DATE is in

START_OF_WEEK_STARTING_TUE_DATE
    First Day of Week starting Tuesday that DATE is in

END_OF_WEEK_STARTING_TUE_DATE
    Last Day of Week starting Tuesday that DATE is in

START_OF_WEEK_STARTING_WED_DATE
    First Day of Week starting Wednesday that DATE is in

END_OF_WEEK_STARTING_WED_DATE
    Last Day of Week starting Wednesday that DATE is in

START_OF_WEEK_STARTING_THU_DATE
    First Day of Week starting Thursday that DATE is in

END_OF_WEEK_STARTING_THU_DATE
    Last Day of Week starting Thursday that DATE is in

START_OF_WEEK_STARTING_FRI_DATE
    First Day of Week starting Friday that DATE is in

END_OF_WEEK_STARTING_FRI_DATE
    Last Day of Week starting Friday that DATE is in

START_OF_WEEK_STARTING_SAT_DATE
    First Day of Week starting Saturday that DATE is in

END_OF_WEEK_STARTING_SAT_DATE
    Last Day of Week starting Saturday that DATE is in

*** Sequence No columns are intended to allow easy offsets by
*** Quarter, Month, or Week for applications that need to look at
*** Last or Next Quarter, Month, or Week.  Thay can also be used to
*** generate dynamic cross tab results by Quarter, Month, or Week.

QUARTER_SEQ_NO
    Sequential Quarter number as offset from Quarter starting 1753/01/01

MONTH_SEQ_NO
    Sequential Month number as offset from Month starting 1753/01/01

WEEK_STARTING_SUN_SEQ_NO
    Sequential Week number as offset from Week starting Sunday, 1753/01/07

WEEK_STARTING_MON_SEQ_NO
    Sequential Week number as offset from Week starting Monday, 1753/01/01

WEEK_STARTING_TUE_SEQ_NO
    Sequential Week number as offset from Week starting Tuesday, 1753/01/02

WEEK_STARTING_WED_SEQ_NO
    Sequential Week number as offset from Week starting Wednesday, 1753/01/03

WEEK_STARTING_THU_SEQ_NO
    Sequential Week number as offset from Week starting Thursday, 1753/01/04

WEEK_STARTING_FRI_SEQ_NO
    Sequential Week number as offset from Week starting Friday, 1753/01/05

WEEK_STARTING_SAT_SEQ_NO
    Sequential Week number as offset from Week starting Saturday, 1753/01/06

JULIAN_DATE
    Julian Date number as offset from noon on January 1, 4713 BCE
    to noon on day of DATE in system of Joseph Scaliger

MODIFIED_JULIAN_DATE
    Modified Julian Date number as offset from midnight(00:00:00.000) on
    1858/11/17 to midnight(00:00:00.000) on day of DATE

ISO_DATE
    ISO 8601 Date in format YYYY-MM-DD, Example = 2004-02-29

ISO_YEAR_WEEK_NO
    ISO 8601 year and week in format YYYYWW, Example = 200403

ISO_WEEK_NO
    ISO 8601 week of year in format WW, Example = 52

ISO_DAY_OF_WEEK
    ISO 8601 Day of week number,
    Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7

ISO_YEAR_WEEK_NAME
    ISO 8601 year and week in format YYYY-WNN, Example = 2004-W52

ISO_YEAR_WEEK_DAY_OF_WEEK_NAME
    ISO 8601 year, week, and day of week in format YYYY-WNN-D,
    Example = 2004-W52-2

DATE_FORMAT_YYYY_MM_DD
    Text date in format YYYY/MM/DD, Example = 2004/02/29

DATE_FORMAT_YYYY_M_D
    Text date in format YYYY/M/D, Example = 2004/2/9

DATE_FORMAT_MM_DD_YYYY
    Text date in format MM/DD/YYYY, Example = 06/05/2004

DATE_FORMAT_M_D_YYYY
    Text date in format M/D/YYYY, Example = 6/5/2004

DATE_FORMAT_MMM_D_YYYY
    Text date in format MMM D, YYYY, Example = Jan 4, 2006

DATE_FORMAT_MMMMMMMMM_D_YYYY
    Text date in format MMMMMMMMM D, YYYY, Example = September 3, 2004

DATE_FORMAT_MM_DD_YY
    Text date in format MM/DD/YY, Example = 06/05/97

DATE_FORMAT_M_D_YY
    Text date in format M/D/YY, Example = 6/5/97

*/

RETURNS @DATE TABLE (
    [DATE_ID]                          [int]          NOT NULL PRIMARY KEY CLUSTERED,
    [DATE]                             [datetime]     NOT NULL ,
    [NEXT_DAY_DATE]                    [datetime]     NOT NULL ,
    [YEAR]                             [smallint]     NOT NULL ,
    [YEAR_QUARTER]                     [int]          NOT NULL ,
    [YEAR_MONTH]                       [int]          NOT NULL ,
    [YEAR_DAY_OF_YEAR]                 [int]          NOT NULL ,
    [QUARTER]                          [tinyint]      NOT NULL ,
    [MONTH]                            [tinyint]      NOT NULL ,
    [DAY_OF_YEAR]                      [smallint]     NOT NULL ,
    [DAY_OF_MONTH]                     [smallint]     NOT NULL ,
    [DAY_OF_WEEK]                      [tinyint]      NOT NULL ,

    [YEAR_NAME]                        [varchar](4)   NOT NULL ,
    [YEAR_QUARTER_NAME]                [varchar](7)   NOT NULL ,
    [YEAR_MONTH_NAME]                  [varchar](8)   NOT NULL ,
    [YEAR_MONTH_NAME_LONG]             [varchar](14)  NOT NULL ,
    [QUARTER_NAME]                     [varchar](2)   NOT NULL ,
    [MONTH_NAME]                       [varchar](3)   NOT NULL ,
    [MONTH_NAME_LONG]                  [varchar](9)   NOT NULL ,
    [WEEKDAY_NAME]                     [varchar](3)   NOT NULL ,
    [WEEKDAY_NAME_LONG]                [varchar](9)   NOT NULL ,

    [START_OF_YEAR_DATE]               [datetime]     NOT NULL ,
    [END_OF_YEAR_DATE]                 [datetime]     NOT NULL ,
    [START_OF_QUARTER_DATE]            [datetime]     NOT NULL ,
    [END_OF_QUARTER_DATE]              [datetime]     NOT NULL ,
    [START_OF_MONTH_DATE]              [datetime]     NOT NULL ,
    [END_OF_MONTH_DATE]                [datetime]     NOT NULL ,

    [START_OF_WEEK_STARTING_SUN_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_SUN_DATE]    [datetime]     NOT NULL ,
    [START_OF_WEEK_STARTING_MON_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_MON_DATE]    [datetime]     NOT NULL ,
    [START_OF_WEEK_STARTING_TUE_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_TUE_DATE]    [datetime]     NOT NULL ,
    [START_OF_WEEK_STARTING_WED_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_WED_DATE]    [datetime]     NOT NULL ,
    [START_OF_WEEK_STARTING_THU_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_THU_DATE]    [datetime]     NOT NULL ,
    [START_OF_WEEK_STARTING_FRI_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_FRI_DATE]    [datetime]     NOT NULL ,
    [START_OF_WEEK_STARTING_SAT_DATE]  [datetime]     NOT NULL ,
    [END_OF_WEEK_STARTING_SAT_DATE]    [datetime]     NOT NULL ,

    [QUARTER_SEQ_NO]                   [int]          NOT NULL ,
    [MONTH_SEQ_NO]                     [int]          NOT NULL ,

    [WEEK_STARTING_SUN_SEQ_NO]         [int]          NOT NULL ,
    [WEEK_STARTING_MON_SEQ_NO]         [int]          NOT NULL ,
    [WEEK_STARTING_TUE_SEQ_NO]         [int]          NOT NULL ,
    [WEEK_STARTING_WED_SEQ_NO]         [int]          NOT NULL ,
    [WEEK_STARTING_THU_SEQ_NO]         [int]          NOT NULL ,
    [WEEK_STARTING_FRI_SEQ_NO]         [int]          NOT NULL ,
    [WEEK_STARTING_SAT_SEQ_NO]         [int]          NOT NULL ,

    [JULIAN_DATE]                      [int]          NOT NULL ,
    [MODIFIED_JULIAN_DATE]             [int]          NOT NULL ,

    [ISO_DATE]                         [varchar](10)  NOT NULL ,
    [ISO_YEAR_WEEK_NO]                 [int]          NOT NULL ,
    [ISO_WEEK_NO]                      [smallint]     NOT NULL ,
    [ISO_DAY_OF_WEEK]                  [tinyint]      NOT NULL ,
    [ISO_YEAR_WEEK_NAME]               [varchar](8)   NOT NULL ,
    [ISO_YEAR_WEEK_DAY_OF_WEEK_NAME]   [varchar](10)  NOT NULL ,

    [DATE_FORMAT_YYYY_MM_DD]           [varchar](10)  NOT NULL ,
    [DATE_FORMAT_YYYY_M_D]             [varchar](10)  NOT NULL ,
    [DATE_FORMAT_MM_DD_YYYY]           [varchar](10)  NOT NULL ,
    [DATE_FORMAT_M_D_YYYY]             [varchar](10)  NOT NULL ,
    [DATE_FORMAT_MMM_D_YYYY]           [varchar](12)  NOT NULL ,
    [DATE_FORMAT_MMMMMMMMM_D_YYYY]     [varchar](18)  NOT NULL ,
    [DATE_FORMAT_MM_DD_YY]             [varchar](8)   NOT NULL ,
    [DATE_FORMAT_M_D_YY]               [varchar](8)   NOT NULL
)
AS
BEGIN
    DECLARE @cr VARCHAR(2)
    SELECT  @cr = CHAR(13)+CHAR(10)
    DECLARE @ErrorMessage VARCHAR(400)
    DECLARE @START_DATE DATETIME
    DECLARE @END_DATE DATETIME
    DECLARE @LOW_DATE DATETIME

    DECLARE @start_no INT
    DECLARE @end_no INT

    -- Verify @FIRST_DATE is not null
    IF @FIRST_DATE IS NULL
    BEGIN
        SELECT @ErrorMessage = '@FIRST_DATE cannot be null'
        GOTO Error_Exit
    END

    -- Verify @LAST_DATE is not null
    IF @LAST_DATE IS NULL
    BEGIN
        SELECT @ErrorMessage = '@LAST_DATE cannot be null'
    GOTO Error_Exit
    END

    -- Verify @FIRST_DATE is not before 1754-01-01
    IF @FIRST_DATE < '17540101'
    BEGIN
        SELECT @ErrorMessage = '@FIRST_DATE cannot before 1754-01-01'+ ', @FIRST_DATE = '+ ISNULL(CONVERT(VARCHAR(40),@FIRST_DATE,121),'NULL')
        GOTO Error_Exit
    END

    -- Verify @LAST_DATE is not after 9997-12-31
    IF @LAST_DATE > '99971231'
    BEGIN
        SELECT @ErrorMessage = '@LAST_DATE cannot be after 9997-12-31' + ', @LAST_DATE = ' + ISNULL(CONVERT(VARCHAR(40),@LAST_DATE,121),'NULL')
        GOTO Error_Exit
    END

    -- Verify @FIRST_DATE is not after @LAST_DATE
    IF @FIRST_DATE > @LAST_DATE
    BEGIN
        SELECT @ErrorMessage = '@FIRST_DATE cannot be after @LAST_DATE' + ', @FIRST_DATE = ' + ISNULL(CONVERT(VARCHAR(40),@FIRST_DATE,121),'NULL') + ', @LAST_DATE = ' + ISNULL(CONVERT(VARCHAR(40),@LAST_DATE,121),'NULL')
        GOTO Error_Exit
    END

    -- Set  @START_DATE = @FIRST_DATE at midnight
    SELECT  @START_DATE = DATEADD(dd,DATEDIFF(dd,0,@FIRST_DATE),0)
    -- Set  @END_DATE   = @LAST_DATE at midnight
    SELECT  @END_DATE   = DATEADD(dd,DATEDIFF(dd,0,@LAST_DATE),0)
    -- Set  @LOW_DATE   = earliest possible SQL Server datetime
    SELECT  @LOW_DATE   = CONVERT(DATETIME,'17530101')

    -- Find the number of day from 1753-01-01 to @START_DATE and @END_DATE
    SELECT  @start_no   = DATEDIFF(dd,@LOW_DATE,@START_DATE) ,
            @end_no     = DATEDIFF(dd,@LOW_DATE,@END_DATE)

    -- Declare number tables
    DECLARE @num1 TABLE (NUMBER INT NOT NULL PRIMARY KEY CLUSTERED)
    DECLARE @num2 TABLE (NUMBER INT NOT NULL PRIMARY KEY CLUSTERED)
    DECLARE @num3 TABLE (NUMBER INT NOT NULL PRIMARY KEY CLUSTERED)

    -- Declare table of ISO Week ranges
    DECLARE @ISO_WEEK TABLE (
        [ISO_WEEK_YEAR]             INT         NOT NULL PRIMARY KEY CLUSTERED,
        [ISO_WEEK_YEAR_START_DATE]  DATETIME    NOT NULL,
        [ISO_WEEK_YEAR_END_DATE]    DATETIME    NOT NULL
    )

    -- Find rows needed in number tables
    DECLARE @rows_needed        INT
    DECLARE @rows_needed_root   INT
    SELECT  @rows_needed        = @end_no - @start_no + 1
    SELECT  @rows_needed        = CASE WHEN @rows_needed < 10 THEN 10
                                        ELSE @rows_needed END
    SELECT  @rows_needed_root   = CONVERT(INT,CEILING(SQRT(@rows_needed)))

    -- Load number 0 to 16
    INSERT INTO @num1 (NUMBER)
    SELECT NUMBER = 0 UNION ALL SELECT  1 UNION ALL SELECT  2 UNION ALL
    SELECT          3 UNION ALL SELECT  4 UNION ALL SELECT  5 UNION ALL
    SELECT          6 UNION ALL SELECT  7 UNION ALL SELECT  8 UNION ALL
    SELECT          9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
    SELECT         12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL
    SELECT         15
    ORDER BY 1

    -- Load table with numbers zero thru square root of the number of rows needed +1
    INSERT INTO @num2 (NUMBER)
    SELECT  NUMBER = a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER)
    FROM    @num1 a
            CROSS JOIN @num1 b
            CROSS JOIN @num1 c
    WHERE   a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER) < @rows_needed_root
    ORDER BY 1

    -- Load table with the number of rows needed for the date range
    INSERT INTO @num3 (NUMBER)
    SELECT  NUMBER = a.NUMBER+(@rows_needed_root*b.NUMBER)
    FROM    @num2 a
            CROSS JOIN @num2 b
    WHERE   a.NUMBER+(@rows_needed_root*b.NUMBER) < @rows_needed
    ORDER BY 1

    DECLARE @iso_start_year INT
    DECLARE @iso_end_year   INT

    SELECT  @iso_start_year = DATEPART(YEAR,DATEADD(YEAR,-1,@start_date))
    SELECT  @iso_end_year   = DATEPART(YEAR,DATEADD(YEAR,1,@end_date))

    -- Load table with start and end dates for ISO week years
    INSERT INTO @ISO_WEEK ( [ISO_WEEK_YEAR], [ISO_WEEK_YEAR_START_DATE], [ISO_WEEK_YEAR_END_DATE] )
        SELECT  [ISO_WEEK_YEAR]             = a.NUMBER,
                [0ISO_WEEK_YEAR_START_DATE] = DATEADD(dd,(DATEDIFF(dd,@LOW_DATE, DATEADD(DAY,3,DATEADD(YEAR,a.[NUMBER]-1900,0)) )/7)*7,@LOW_DATE),
                [ISO_WEEK_YEAR_END_DATE]    = DATEADD(dd,-1,DATEADD(dd,(DATEDIFF(dd,@LOW_DATE, DATEADD(DAY,3,DATEADD(YEAR,a.[NUMBER]+1-1900,0)) )/7)*7,@LOW_DATE))
        FROM (
                SELECT  NUMBER = NUMBER+@iso_start_year
                FROM    @num3
                WHERE   NUMBER+@iso_start_year <= @iso_end_year ) a
        ORDER BY a.NUMBER

    -- Load Date table
    INSERT INTO @DATE
    SELECT  [DATE_ID]                           = a.[DATE_ID] ,
            [DATE]                              = a.[DATE] ,

            [NEXT_DAY_DATE]                     = DATEADD(DAY,1,a.[DATE]) ,
            [YEAR]                              = DATEPART(YEAR,a.[DATE]) ,
            [YEAR_QUARTER]                      = (10*DATEPART(YEAR,a.[DATE]))+DATEPART(QUARTER,a.[DATE]) ,
            [YEAR_MONTH]                        = (100*DATEPART(YEAR,a.[DATE]))+DATEPART(MONTH,a.[DATE]) ,
            [YEAR_DAY_OF_YEAR]                  = (1000*DATEPART(YEAR,a.[DATE])) + DATEDIFF(dd,DATEADD(yy,DATEDIFF(yy,0,a.[DATE]),0),a.[DATE])+1 ,
            [QUARTER]                           = DATEPART(QUARTER,a.[DATE]) ,
            [MONTH]                             = DATEPART(MONTH,a.[DATE]) ,
            [DAY_OF_YEAR]                       = DATEDIFF(dd,DATEADD(yy,DATEDIFF(yy,0,a.[DATE]),0),a.[DATE])+1 ,
            [DAY_OF_MONTH]                      = DATEPART(DAY,a.[DATE]) ,
            -- Sunday = 1, Monday = 2, ,,,Saturday = 7
            [DAY_OF_WEEK]                       = (DATEDIFF(dd,'17530107',a.[DATE])%7)+1  ,
            [YEAR_NAME]                         = DATENAME(YEAR,a.[DATE]) ,
            [YEAR_QUARTER_NAME]                 = DATENAME(YEAR,a.[DATE])+' Q'+DATENAME(QUARTER,a.[DATE]) ,
            [YEAR_MONTH_NAME]                   = DATENAME(YEAR,a.[DATE])+' '+LEFT(DATENAME(MONTH,a.[DATE]),3) ,
            [YEAR_MONTH_NAME_LONG]              = DATENAME(YEAR,a.[DATE])+' '+DATENAME(MONTH,a.[DATE]) ,
            [QUARTER_NAME]                      = 'Q'+DATENAME(QUARTER,a.[DATE]) ,
            [MONTH_NAME]                        = LEFT(DATENAME(MONTH,a.[DATE]),3) ,
            [MONTH_NAME_LONG]                   = DATENAME(MONTH,a.[DATE]) ,
            [WEEKDAY_NAME]                      = LEFT(DATENAME(WEEKDAY,a.[DATE]),3) ,
            [WEEKDAY_NAME_LONG]                 = DATENAME(WEEKDAY,a.[DATE]),

            [START_OF_YEAR_DATE]                = DATEADD(YEAR,DATEDIFF(YEAR,0,a.[DATE]),0) ,
            [END_OF_YEAR_DATE]                  = DATEADD(DAY,-1,DATEADD(YEAR,DATEDIFF(YEAR,0,a.[DATE])+1,0)) ,

            [START_OF_QUARTER_DATE]             = DATEADD(QUARTER,DATEDIFF(QUARTER,0,a.[DATE]),0) ,
            [END_OF_QUARTER_DATE]               = DATEADD(DAY,-1,DATEADD(QUARTER,DATEDIFF(QUARTER,0,a.[DATE])+1,0)) ,

            [START_OF_MONTH_DATE]               = DATEADD(MONTH,DATEDIFF(MONTH,0,a.[DATE]),0) ,
            [END_OF_MONTH_DATE]                 = DATEADD(DAY,-1,DATEADD(MONTH,DATEDIFF(MONTH,0,a.[DATE])+1,0)),

            [START_OF_WEEK_STARTING_SUN_DATE]   = DATEADD(dd,(DATEDIFF(dd,'17530107',a.[DATE])/7)*7,'17530107'),
            [END_OF_WEEK_STARTING_SUN_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530107',a.[DATE])/7)*7)+6,'17530107'),

            [START_OF_WEEK_STARTING_MON_DATE]   = DATEADD(dd,(DATEDIFF(dd,'17530101',a.[DATE])/7)*7,'17530101'),
            [END_OF_WEEK_STARTING_MON_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530101',a.[DATE])/7)*7)+6,'17530101'),

            [START_OF_WEEK_STARTING_TUE_DATE]   = DATEADD(dd,(datediff(dd,'17530102',a.[DATE])/7)*7,'17530102'),
            [END_OF_WEEK_STARTING_TUE_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530102',a.[DATE])/7)*7)+6,'17530102'),

            [START_OF_WEEK_STARTING_WED_DATE]   = DATEADD(dd,(DATEDIFF(dd,'17530103',a.[DATE])/7)*7,'17530103'),
            [END_OF_WEEK_STARTING_WED_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530103',a.[DATE])/7)*7)+6,'17530103'),

            [START_OF_WEEK_STARTING_THU_DATE]   = DATEADD(dd,(DATEDIFF(dd,'17530104',a.[DATE])/7)*7,'17530104'),
            [END_OF_WEEK_STARTING_THU_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530104',a.[DATE])/7)*7)+6,'17530104'),

            [START_OF_WEEK_STARTING_FRI_DATE]   = DATEADD(dd,(DATEDIFF(dd,'17530105',a.[DATE])/7)*7,'17530105'),
            [END_OF_WEEK_STARTING_FRI_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530105',a.[DATE])/7)*7)+6,'17530105'),

            [START_OF_WEEK_STARTING_SAT_DATE]   = DATEADD(dd,(DATEDIFF(dd,'17530106',a.[DATE])/7)*7,'17530106'),
            [END_OF_WEEK_STARTING_SAT_DATE]     = DATEADD(dd,((DATEDIFF(dd,'17530106',a.[DATE])/7)*7)+6,'17530106'),

            [QUARTER_SEQ_NO]                    = DATEDIFF(QUARTER,@LOW_DATE,a.[DATE]),
            [MONTH_SEQ_NO]                      = DATEDIFF(MONTH,@LOW_DATE,a.[DATE]),

            [WEEK_STARTING_SUN_SEQ_NO]          = DATEDIFF(DAY,'17530107',a.[DATE])/7,
            [WEEK_STARTING_MON_SEQ_NO]          = DATEDIFF(DAY,'17530101',a.[DATE])/7,
            [WEEK_STARTING_TUE_SEQ_NO]          = DATEDIFF(DAY,'17530102',a.[DATE])/7,
            [WEEK_STARTING_WED_SEQ_NO]          = DATEDIFF(DAY,'17530103',a.[DATE])/7,
            [WEEK_STARTING_THU_SEQ_NO]          = DATEDIFF(DAY,'17530104',a.[DATE])/7,
            [WEEK_STARTING_FRI_SEQ_NO]          = DATEDIFF(DAY,'17530105',a.[DATE])/7,
            [WEEK_STARTING_SAT_SEQ_NO]          = DATEDIFF(DAY,'17530106',a.[DATE])/7,

            [JULIAN_DATE]                       = DATEDIFF(DAY,@LOW_DATE,a.[DATE])+2361331,
            [MODIFIED_JULIAN_DATE]              = DATEDIFF(DAY,'18581117',a.[DATE]),
        --/*

            [ISO_DATE]                          = REPLACE(CONVERT(CHAR(10),a.[DATE],111),'/','-') ,

            [ISO_YEAR_WEEK_NO]                  = (100*b.[ISO_WEEK_YEAR]) + (DATEDIFF(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1 ,

            [ISO_WEEK_NO]                       = (DATEDIFF(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1 ,

            -- Sunday = 1, Monday = 2, ,,,Saturday = 7
            [ISO_DAY_OF_WEEK]                   = (DATEDIFF(dd,@LOW_DATE,a.[DATE])%7)+1  ,

            [ISO_YEAR_WEEK_NAME]                = CONVERT(VARCHAR(4),b.[ISO_WEEK_YEAR])+'-W'+
                                                    RIGHT('00'+CONVERT(VARCHAR(2),(DATEDIFF(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1),2) ,

            [ISO_YEAR_WEEK_DAY_OF_WEEK_NAME]    = CONVERT(VARCHAR(4),b.[ISO_WEEK_YEAR])+'-W'+
                                                    RIGHT('00'+CONVERT(VARCHAR(2),(DATEDIFF(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1),2) +
                                                    '-'+CONVERT(VARCHAR(1),(DATEDIFF(dd,@LOW_DATE,a.[DATE])%7)+1) ,
        --*/
            [DATE_FORMAT_YYYY_MM_DD]            = CONVERT(CHAR(10),a.[DATE],111) ,
            [DATE_FORMAT_YYYY_M_D]              = CONVERT(VARCHAR(10),
                                                    CONVERT(VARCHAR(4),YEAR(a.[DATE]))+'/'+
                                                    CONVERT(VARCHAR(2),MONTH(a.[DATE]))+'/'+
                                                    CONVERT(VARCHAR(2),DAY(a.[DATE]))),
            [DATE_FORMAT_MM_DD_YYYY]            = CONVERT(CHAR(10),a.[DATE],101) ,
            [DATE_FORMAT_M_D_YYYY]              = CONVERT(VARCHAR(10),
                                                    CONVERT(VARCHAR(2),MONTH(a.[DATE]))+'/'+
                                                    CONVERT(VARCHAR(2),DAY(a.[DATE]))+'/'+
                                                    CONVERT(VARCHAR(4),YEAR(a.[DATE]))),
            [DATE_FORMAT_MMM_D_YYYY]            = CONVERT(VARCHAR(12),
                                                    LEFT(DATENAME(MONTH,a.[DATE]),3)+' '+
                                                    CONVERT(VARCHAR(2),DAY(a.[DATE]))+', '+
                                                    CONVERT(VARCHAR(4),YEAR(a.[DATE]))),
            [DATE_FORMAT_MMMMMMMMM_D_YYYY]      = CONVERT(VARCHAR(18),
                                                    DATENAME(MONTH,a.[DATE])+' '+
                                                    CONVERT(VARCHAR(2),DAY(a.[DATE]))+', '+
                                                    CONVERT(VARCHAR(4),YEAR(a.[DATE]))),
            [DATE_FORMAT_MM_DD_YY]              = CONVERT(CHAR(8),a.[DATE],1) ,
            [DATE_FORMAT_M_D_YY]                = CONVERT(VARCHAR(8),
                                                    CONVERT(VARCHAR(2),MONTH(a.[DATE]))+'/'+
                                                    CONVERT(VARCHAR(2),DAY(a.[DATE]))+'/'+
                                                    RIGHT(CONVERT(VARCHAR(4),YEAR(a.[DATE])),2))
    FROM (  -- ===  Derived table is all dates needed for date range
            select  top 100 percent
                    [DATE_ID]   = aa.[NUMBER],
                    [DATE]      = DATEADD(dd,aa.[NUMBER],@LOW_DATE)
            FROM (
                    SELECT  NUMBER = NUMBER+@start_no
                    FROM    @num3
                    WHERE   NUMBER+@start_no <= @end_no ) aa
            ORDER BY aa.[NUMBER] ) a
        -- ===  Match each date to the proper ISO week year
        INNER JOIN @ISO_WEEK b
                ON a.[DATE] BETWEEN  b.[ISO_WEEK_YEAR_START_DATE]
                    AND  b.[ISO_WEEK_YEAR_END_DATE]
    ORDER BY a.[DATE_ID]

    RETURN


    -- Return a pseudo error message by trying to
    -- convert an error message string to an int.
    -- This method is used because the error displays
    -- the string it was trying to convert, and so the
    -- calling application sees a formatted error message.
    ERROR_EXIT:

    DECLARE @error INT

    SET @error = CONVERT(INT,@cr+@cr+
    '*******************************************************************'+@cr+
    '* Error in function F_TABLE_DATE:'+@cr+'* '+
    isnull(@ErrorMessage,'Unknown Error')+@cr+
    '*******************************************************************'+@cr+@cr)

    RETURN

END


GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT  SELECT  ON [dbo].[F_TABLE_DATE]  TO [public]
GO
SET DATEFORMAT ydm
go
PRINT 'Checksum with ydm'
GO
SELECT  [Checksum] = checksum_agg(binary_checksum(*))
FROM    dbo.F_TABLE_DATE ( '20000101','20101231' )
GO
SET DATEFORMAT ymd
GO
PRINT 'Checksum with ymd'
GO
SELECT  [Checksum] = checksum_agg(binary_checksum(*))
FROM    dbo.F_TABLE_DATE ( '20000101','20101231' )
GO
SET DATEFORMAT ymd
GO
-- Sample select for date range
SELECT  *
FROM    dbo.F_TABLE_DATE ( '20000101','20101231' )
ORDER BY 1
