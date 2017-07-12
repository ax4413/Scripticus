-- =======================================================================================================================================================================
-- ==== http://www.sqlservercentral.com/articles/T-SQL/90955/
-- =======================================================================================================================================================================


-- ==== Loan Amortization - Payment schedule for a loan

DECLARE @Loans TABLE (
   ID INT, 
   LoanAmount MONEY, 
   Period INT, 
   InterestAPR FLOAT
 )

INSERT INTO @Loans
 SELECT 1, 20000, 48, 12
 UNION ALL SELECT 2, 30000, 60, 11.5
 UNION ALL SELECT 3, 126000, 360, 8.5

;WITH Payments AS (
    SELECT  LoanID	    =   ID, 
		  PaymentNo   =   0, 
		  Balance	    =   LoanAmount,
		  Payment	    = CAST(NULL AS MONEY),
		  Principal   = CAST(NULL AS MONEY),
		  Interest    = CAST(NULL AS MONEY),
		  CumInt	    = CAST(0 AS MONEY),     -- Cumulative Interest
		  R,							   -- APR converted to a monthly rate
		  -- Calculate the monthly payment amount only once (in the anchor of the rCTE)
		  Pmt	    = ROUND(R*((POWER(1+R, Period)*LoanAmount)/(POWER(1+R, Period)-1)), 2),
		  Period
    FROM	  @Loans
		  CROSS APPLY (
				    SELECT R =	CAST((InterestAPR/100.)/12. AS MONEY)
				    ) x
    UNION ALL
    SELECT  LoanID, 
		  PaymentNo + 1, 
		  Balance   = CASE PaymentNo + 1
					   WHEN Period THEN CAST(0 AS MONEY)
					   ELSE Balance - (Pmt - ROUND(R * Balance, 2)) END,
		  Payment   = Pmt,
		  Principal = CASE PaymentNo + 1 WHEN Period THEN Balance
					   ELSE Pmt - ROUND(R * Balance, 2) END,
		  Interest  = CASE PaymentNo + 1 WHEN Period THEN Pmt - Balance
					   ELSE ROUND(R * Balance, 2) END,
		  CumInt    = CASE PaymentNo + 1 WHEN Period THEN CumInt + Pmt - Balance
					   ELSE ROUND(CumInt + R * Balance, 2) END,
		  R,
		  Pmt,
		  Period
    FROM	  Payments
    WHERE	  PaymentNo < Period
)

SELECT  LoanID, PaymentNo As No, Balance, Payment, Principal, Interest, CumInt
FROM	   Payments
ORDER BY LoanID, PaymentNo
OPTION(MAXRECURSION 360)




-- =======================================================================================================================================================================
-- ==== Numerical Analysis

DECLARE @Eqns TABLE 
    ( [ID] INT         -- Polynomial equation to solve for root
    , [Coefx3] FLOAT   -- Coefficient of x^3
    , [Coefx2] FLOAT   -- Coefficient of x^2
    , [CoefX] FLOAT    -- Coefficient of x
    , [C] FLOAT        -- Constant
    , [x0] FLOAT )     -- Initial guess

INSERT INTO @Eqns
    SELECT 1, 3, 2, 5, 4, 0     -- f(x) = 3*x^3 + 2*x^2 + 5*x + 4
    UNION ALL 
    SELECT 2, 1, 0, -2, 2, -10  -- 0 -- f(x) = x^3 - 2*x + 2

;WITH NewtonRaphson ([ID], [Polynomial Function], [Try], [x], [f(x)], [Coefx3], [Coefx2], [CoefX], [C], [xn])
AS (                       -- Passthru variables for iterations
    SELECT  e.[ID] , 
		  fcn.[Equation] ,
		  1 ,
		  e.[x0] , 
		  fcn.[f(x)] ,					   -- Try, current x, value of f at x
		  e.[Coefx3] , 
		  e.[Coefx2] , 
		  e.[CoefX] , 
		  e.[C] ,						   -- Coefficients of f(x)
		  e.[x0] - fcn.[f(x)] / fcn.[f'(x)]   -- Newton's formula
    FROM	  @Eqns e
		  CROSS APPLY (
				SELECT  [f(x)]		= Coefx3 * POWER(x0, 3) + Coefx2 * SQUARE(x0) + CoefX * x0 + C ,
					   [f'(x)]	= Coefx3 * 3 * SQUARE(x0) + Coefx2 * 2 * x0 + CoefX ,
					   Equation	= CAST(Coefx3 AS VARCHAR) + '*x^3 + ' + CAST(Coefx2 AS VARCHAR) + '*x^2 + ' + CAST(Coefx AS VARCHAR) + '*x + ' + CAST(C AS VARCHAR)
				    ) fcn
    
    UNION ALL
    
    SELECT  n.[ID] , 
		  n.[Polynomial Function] ,
		  n.[Try] + 1 , 
		  n.[xn] , 
		  fcn.[f(x)] ,					   -- Try, current x, value of f at x
		  n.[Coefx3] , 
		  n.[Coefx2] , 
		  n.[CoefX] , 
		  n.[C] ,						   -- Coefficients of f(x)
		  n.[xn] - fcn.[f(x)] / fcn.[f'(x)]   -- Newton's formula
    FROM	  NewtonRaphson n
		  CROSS APPLY (
				SELECT  [f(x)]		= Coefx3 * POWER(xn, 3) + Coefx2 * SQUARE(xn) + CoefX*xn + C ,
					   [f'(x)]	= Coefx3 * 3 * SQUARE(xn) + Coefx2 * 2 * xn + CoefX
				    ) fcn
    WHERE	  [Try] < 99 
		  AND n.[f(x)]  <> 0
)

SELECT  [Polynomial Function], 
	   [Try], 
	   [x], 
	   [f(x)] 
FROM	   NewtonRaphson
--WHERE [f(x)]  = 0     -- Uncomment to see only the roots
ORDER BY [ID], [Try]




-- =======================================================================================================================================================================
-- ==== Depreciation Schedules

DECLARE @Assets TABLE (ID INT, PurchaseCost MONEY, Period INT)
INSERT INTO @Assets
    SELECT 1, 20000, 48
    UNION ALL 
    SELECT 2, 30000, 60


;WITH SLDepSched (AssetID, [Month], Period, -- Asset base
				SLDepAmt, SLBookValue, SLCumDep)	 -- Straight Line Depreciation Method
AS (

    SELECT  ID, 
		  0, 
		  Period,
		  ROUND(PurchaseCost/Period, 2),     -- Straight Line Depreciation Amount
		  PurchaseCost, 
		  CAST(0 AS MONEY)
    FROM	  @Assets

    UNION ALL

    SELECT  AssetID, 
		  [Month] + 1, 
		  Period,
		  CASE [Month]+1 WHEN Period THEN SLBookValue ELSE SLDepAmt END,
		  CASE [Month]+1 WHEN Period THEN CAST(0 AS MONEY) ELSE SLBookValue - SLDepAmt END,
		  CASE [Month]+1 WHEN Period THEN SLCumDep + SLBookValue ELSE SLCumDep + SLDepAmt END
    FROM	  SLDepSched
    WHERE	  [Month] < Period
)

SELECT  AssetID, 
	   [Month], 
	   SLDepAmt, 
	   SLBookValue, 
	   SLCumDep                  
FROM	   SLDepSched
ORDER BY AssetID, [Month]




-- =======================================================================================================================================================================