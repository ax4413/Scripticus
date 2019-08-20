DECLARE @ReportDate DATETIME = '20150101'
      , @OffsetDays1    INT  = 0
      , @OffsetHours1   INT  = 0
      , @OffsetMinutes1 INT  = 0
      , @OffsetDays2    INT  = 0
      , @OffsetHours2   INT  = 0
      , @OffsetMinutes2 INT  = 0

SELECT  [From]  = DATEADD( minute, @OffsetMinutes1 * 1, DATEADD( hour, @OffsetHours1 * 1, DATEADD( day, @OffsetDays1 * 1, @ReportDate ) ) )
      , [To]    = DATEADD( minute, @OffsetMinutes2 * 1, DATEADD( hour, @OffsetHours2 * 1, DATEADD( day, @OffsetDays2 * 1, @ReportDate ) ) )

SELECT  *
FROM    dbo.vwLsApplication
WHERE   ( [Cust ChangedDate] >= DATEADD( minute, @OffsetMinutes1 * 1, DATEADD( hour, @OffsetHours1 * 1, DATEADD( day, @OffsetDays1 * 1, @ReportDate ) ) ) 
  AND     [Cust ChangedDate] <  DATEADD( minute, @OffsetMinutes2 * 1, DATEADD( hour, @OffsetHours2 * 1, DATEADD( day, @OffsetDays2 * 1, @ReportDate ) ) ) )