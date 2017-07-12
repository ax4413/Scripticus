SELECT * FROM CalculateTimeSlots('hour',1, '19010101',2)

CREATE FUNCTION [dbo].[CalculateTimeSlots]
-- A function to calculate time slots over a twenty-four hour period
-- https://www.simple-talk.com/sql/t-sql-programming/time-slots---an-essential-extension-to-calendar-tables/
 (
    --  @SlotType: 'hour', 'minute' or 'second' (invalid defaults to 'hour')
    --  Other allowed abbreviations as in DATEADD/DATEDIFF are also supported
    --  for these three slot types.
    @SlotType           VARCHAR(6)
    --  @SlotDuration: Must be a zero remainder divisor of @SlotType
    --  For @SlotType='second' then when 60%@SlotDuration = 0 the increment is valid
    --  For @SlotType='minute' then when 60%@SlotDuration = 0 the increment is valid
    --  For @SlotType='second' then when 24%@SlotDuration = 0 the increment is valid
    --  If invalid, defaults to 1
    ,@SlotDuration      SMALLINT
    ,@BaseDate          DATETIME
    ,@NumberOfDays      INT
) RETURNS TABLE WITH SCHEMABINDING
RETURN
WITH Tally (n) AS (
    -- Returns exactly 86400 rows (number of seconds in a day)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1                   -- zero-based
    FROM       (VALUES(0),(0),(0),(0),(0),(0))                         a(n) -- 6 rows
    CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n) -- x12 rows
    CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n) -- x12 rows
    CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0))         d(n) -- x10 rows
    CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0))         e(n) -- x10 rows
),                                                                          -- = 86,400 rows
MagicNumbersForHMS AS (
    -- All clock arithmetic magic numbers are consolidated here to drive the calculations
    -- that will follow.
    SELECT SlotType = 'second', SlotOffset=1, UnitsPerNext=60, UnitsPerDay=86400
    UNION ALL SELECT  'minute',            60,             60,             1440
    UNION ALL SELECT  'hour',              3600,           24,             24
),
MiscParameters (t, SlotOffset, SlotDuration, TimeSlots, BaseDate, NoDays) AS (
    -- Start with the base offset as a TIME datatype
    SELECT  CAST('00:00' AS TIME)
          , b.SlotOffset
          -- Set SlotDuration to 1 if not evenly divisible by specified @SlotDuration
          , CASE UnitsPerNext % @SlotDuration
                WHEN 0
                THEN @SlotDuration
                ELSE 1
            END
          -- Calculate the number of time slots for this call
          , CASE
                WHEN @SlotDuration <= 0 OR UnitsPerNext%@SlotDuration <> 0
                THEN UnitsPerDay
                ELSE UnitsPerDay / ISNULL(@SlotDuration, 1)
            END
          -- Pass the BaseDate forward
          , @BaseDate
          -- Calculate the number of days (1 if not specified) for the Cartesian product
          , CASE WHEN @BaseDate IS NULL OR NULLIF(@NumberOfDays, 0) IS NULL
                THEN 1
                ELSE ABS(@NumberOfDays)
            END
    FROM (  -- Default the @SlotType to hours if invalid
            SELECT SlotType = CASE
                                -- Valid for hours
                                WHEN @SlotType IN ('hour', 'hh') THEN 'hour'
                                -- Valid for minutes
                                WHEN @SlotType IN ('minute', 'mi', 'n') THEN 'minute'
                                -- Valid for seconds
                                WHEN @SlotType IN ('second','ss', 's') THEN 'second'
                                ELSE 'hour'
                              END ) a
          INNER JOIN MagicNumbersForHMS b
                  ON a.SlotType = b.SlotType
)
SELECT  [TimeSlot]                    = DATEADD(second, c.n * a.SlotOffset * a.SlotDuration, t)
      , [TimeSlotOffsetUnits]         = c.n * a.SlotDuration                                            -- Offset based on @SlotType
      , [TimeSlotOffsetSeconds]       = c.n * a.SlotOffset * SlotDuration                               -- Offset based on seconds
      , [BaseDate]                    = CAST(b.[Date] AS DATE)                                          -- Extended return columns starting with base date
      , [BaseDateWithTimeSlotStart]   = DATEADD(second, c.n*a.SlotOffset*a.SlotDuration, b.[Date])      -- Base date plus offset
      , [BaseDateWithTimeSlotEnd]     = DATEADD(second, (c.n+1)*a.SlotOffset*a.SlotDuration, b.[Date])  -- Base date plus offset plus duration
FROM    MiscParameters a
        -- CROSS APPLY to generate the requisite number of days from the extended parameters
        -- (1 day/row if not specified)
        CROSS APPLY (
            SELECT TOP (a.NoDays) [Date]=b.n + a.BaseDate
            FROM Tally b
            ORDER BY n  ) b
        -- Generate the Cartesian product of days vs. time slots
        CROSS APPLY (
            SELECT TOP (a.TimeSlots) c.n
            FROM Tally c
            ORDER BY n ) c;


