-- ===	================================================================================================================================
-- ===	Please configure the below variables to define the date range you wish to generate accounting period for...

DECLARE @StartDate										 DATE			= '20530101'		-- The date that you want to insert accounting periods from 'yyyyMMdd'
			, @EndDate											 DATE			= '20540101'		-- The date that you want to insert accounting periods till 'yyyyMMdd'
			, @FinancialYearStartMonth			 TINYINT	= 1							-- The first month in the fiscal year. Allows period to run from not Jan - Jan
			, @IncludeTimeComponentOnEndDate BIT			= 0							-- 1 sets the time component on the end date to 23:59:59.990
																																-- 0 sets the time component on the end date to 00:00:00.000

-- ===	================================================================================================================================
DECLARE @LastEndDate DATE
			,	@ActualFinancialYearStartMonth INT
			, @d1 VARCHAR(50)
			, @d2 VARCHAR(50)
SELECT	@LastEndDate = (SELECT MAX(EndDate) FROM dbo.AccountingPeriod)
			,	@ActualFinancialYearStartMonth = (SELECT DISTINCT DATEPART(MONTH,StartDate) FROM dbo.AccountingPeriod WHERE Period = 1)

IF(@FinancialYearStartMonth NOT IN(1,2,3,4,5,6,7,8,9,10,11,12)) BEGIN
    RAISERROR('%i is not a valid month. Valid values include the following range [1-12]', 18, 1, @FinancialYearStartMonth)
END

ELSE IF(@StartDate IS NULL) BEGIN
    RAISERROR('The StartDate can not be NULL', 18, 1)
END

ELSE IF(@EndDate IS NULL) BEGIN
    RAISERROR('The EndDate can not be NULL', 18, 1)
END

ELSE IF(@StartDate > @EndDate) BEGIN
		SELECT	@d1 = CONVERT(VARCHAR(50), @StartDate, 121)
					,	@d2 = CONVERT(VARCHAR(50), @EndDate, 121)
    RAISERROR('The StartDate %s can not be greater than the EndDate %s', 18, 1, @d1, @d2)
END

ELSE IF(@LastEndDate IS NOT NULL AND @StartDate < @LastEndDate) BEGIN		
		SELECT	@d1 = CONVERT(VARCHAR(50), @StartDate, 121)
					,	@d2 = CONVERT(VARCHAR(50), @LastEndDate, 121)
    RAISERROR('The start date %s can not be before the end of the current accounting periods %s', 18, 1, @d1, @d2)
END

ELSE IF(@ActualFinancialYearStartMonth IS NOT NULL AND @ActualFinancialYearStartMonth <> @FinancialYearStartMonth) BEGIN
    RAISERROR('The EndDate can not be NULL', 18, 1)
END

ELSE BEGIN 
		BEGIN TRANSACTION
				BEGIN TRY 
						-- ===  We need the date as a date time
						DECLARE @StartTime DATETIME = @StartDate
  
						-- ===  calculate how many records we need to insert
						DECLARE @MonthCount INT = ( SELECT DATEDIFF(MONTH, @StartDate, @EndDate))

						-- ===  We use this value to deduct from the current month to artificially set the period
						SET @FinancialYearStartMonth = @FinancialYearStartMonth -1

						-- ===  Itzik-Style CROSS JOIN counts from 1 to the number needed
						; WITH E1(N) AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
															SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
															SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 ) -- 1*10^1 or 10 rows
						, E2(N) AS (SELECT 1 FROM E1 a, E1 b)                                                 -- 1*10^2 or 100 rows
						, E4(N) AS (SELECT 1 FROM E2 a, E2 b)                                                 -- 1*10^4 or 10,000 rows
						, E8(N) AS (SELECT 1 FROM E4 a, E4 b)                                                 -- 1*10^8 or 100,000,000 rows
						, cteTally(N) AS (SELECT TOP (@MonthCount) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E8)

						-- ===  Populate the now empty accounting period table
						INSERT INTO dbo.AccountingPeriod(StartDate, EndDate, Period, IsPeriodOpen, CreateDate, CreateUserId)
								SELECT  [StartDate]     = DATEADD(MONTH, N-1, @StartTime)
											, [EndDate]       = CASE WHEN @IncludeTimeComponentOnEndDate = 1 THEN DATEADD(MILLISECOND, -10, DATEADD(Month, N, @StartTime))
																							 ELSE DATEADD(DAY, -1, DATEADD(Month, N, @StartTime)) END
											, [Period]        = CASE WHEN MONTH(DATEADD(MONTH, N-1, @StartTime)) - @FinancialYearStartMonth < 1
																										THEN 12 + (MONTH(DATEADD(MONTH, N-1, @StartTime)) - @FinancialYearStartMonth)
																								ELSE MONTH(DATEADD(MONTH, N-1, @StartTime)) - @FinancialYearStartMonth END
											, [IsPeriodOpen]  = 1
											, [CreateDate]    = GETDATE()
											, [CreateUserId]  = -1
								FROM    cteTally
								WHERE   N <= @MonthCount
            
						--  === Return our resuts to the client
						SELECT  *
						FROM    dbo.AccountingPeriod

				END TRY
				BEGIN CATCH
						SELECT  ERROR_NUMBER()    AS ErrorNumber
									, ERROR_SEVERITY()  AS ErrorSeverity
									, ERROR_STATE()     AS ErrorState
									, ERROR_PROCEDURE() AS ErrorProcedure
									, ERROR_LINE()      AS ErrorLine
									, ERROR_MESSAGE()   AS ErrorMessage;

						IF @@TRANCOUNT > 0
								ROLLBACK TRANSACTION;
				END CATCH

				-- ===  There has been no error commit the transaction
				IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END	
