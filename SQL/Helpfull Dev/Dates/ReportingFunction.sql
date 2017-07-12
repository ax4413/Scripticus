IF(OBJECT_ID('[dbo].[ReportingPeriodDefinition]') IS NOT NULL)
    DROP FUNCTION [dbo].[ReportingPeriodDefinition]
GO
-- ================================================================================================
-- Author:      Stephen Yeadon
-- Date:        2014-08-21
-- Description: Define a reporting period.
--              Pass a date, period and duration and recieve a deffinition of the reporting period
-- Notes:       Valid periods include YEAR, MONTH & DAY
--              - @Duration produces historical periods
--              + @Duration produces future periods
-- ================================================================================================
CREATE FUNCTION [dbo].[ReportingPeriodDefinition]
(
    @ProcessDate DATETIME,
    @Period VARCHAR(5),
    @Duration INT
)
RETURNS @ReportingPeriod TABLE (
    ProcessDate DATETIME,
    StartOfReportingPeriod DATETIME,
    EndOfReportingPeriod DATETIME,
    [Description] VARCHAR(50)
)
AS
BEGIN

    --SELECT @Duration = ABS(@Duration)
    SELECT @Period = UPPER(@Period)

    IF(@Period = 'DAY')
        INSERT INTO @ReportingPeriod
            SELECT  @ProcessDate,
                    DATEADD( DAY, @Duration, DATEADD( DAY, DATEDIFF( DAY, 0, @ProcessDate), 0)),
                    DATEADD( DAY, DATEDIFF( DAY, 0, @ProcessDate), 0),
                    CAST( @Duration AS VARCHAR(42)) + ' ' + LEFT(@Period,1) + LOWER( SUBSTRING( @Period, 2, LEN(@Period))) + CASE WHEN @Duration > 1 THEN 's' ELSE '' END
    ELSE IF(@Period = 'MONTH')
        INSERT INTO @ReportingPeriod
            SELECT  @ProcessDate,
                    DATEADD( MONTH, @Duration, DATEADD( DAY, DATEDIFF( DAY, 0, @ProcessDate), 0)),
                    DATEADD( DAY, DATEDIFF( DAY, 0, @ProcessDate), 0),
                    CAST( @Duration AS VARCHAR(42)) + ' ' + LEFT(@Period,1) + LOWER( SUBSTRING( @Period, 2, LEN(@Period))) + CASE WHEN @Duration > 1 THEN 's' ELSE '' END
    ELSE IF(@Period = 'YEAR')
        INSERT INTO @ReportingPeriod
            SELECT  @ProcessDate,
                    DATEADD( YEAR, @Duration, DATEADD( DAY, DATEDIFF( DAY, 0, @ProcessDate), 0)),
                    DATEADD( DAY, DATEDIFF( DAY, 0, @ProcessDate), 0),
                    CAST( @Duration AS VARCHAR(42)) + ' ' + LEFT(@Period,1) + LOWER( SUBSTRING( @Period, 2, LEN(@Period))) + CASE WHEN @Duration > 1 THEN 's' ELSE '' END

    UPDATE @ReportingPeriod
    SET StartOfReportingPeriod = CASE WHEN EndOfReportingPeriod < StartOfReportingPeriod THEN EndOfReportingPeriod ELSE StartOfReportingPeriod END,
        EndOfReportingPeriod   = CASE WHEN StartOfReportingPeriod > EndOfReportingPeriod THEN StartOfReportingPeriod ELSE EndOfReportingPeriod END

    RETURN
END
GO

DECLARE @Date DATETIME
SELECT  @Date = GETDATE()

SELECT * FROM ReportingPeriodDefinition(@Date,'DAY',-2)
SELECT * FROM ReportingPeriodDefinition(@Date,'MONTH',2)
SELECT * FROM ReportingPeriodDefinition(@Date,'YEAR',2)
