
DECLARE @PrimaryStatus TABLE ( Name VARCHAR(50) )
    INSERT INTO @PrimaryStatus ( Name )
    VALUES  ('Active'), ('Complete'), ('Proposal')

    
DECLARE @StartDateTo                DATETIME    = '20160229'
      , @StartDateFrom              DATETIME    = '20141117' -- vm start date
      , @Introducer                 VARCHAR(50) = '(All)'   
      , @Product                    VARCHAR(50) = '(All)'
      , @Source                     VARCHAR(50) = '(All)'  
      , @SecondaryStatus            VARCHAR(50) = '(All)'   
      , @Title                      VARCHAR(50) = 'Portfolio Balance 2012'
      , @Drilldown                  BIT         = 0      
      , @FirstDueDateFrom           DATETIME    = NULL  
      , @FirstDueDateTo             DATETIME    = NULL  
      , @PrevDueDateFrom            DATETIME    = NULL 
      , @PrevDueDateTo              DATETIME    = NULL 
      , @NextDueDateFrom            DATETIME    = NULL 
      , @NextDueDateTo              DATETIME    = NULL 
      , @CompletedDateFrom          DATETIME    = NULL 
      , @CompletedDateTo            DATETIME    = NULL 
      , @BalanceFrom                INT         = NULL 
      , @BalanceTo                  INT         = NULL 
      , @ArrearsFrom                INT         = NULL 
      , @ArrearsTo                  INT         = NULL 
      , @DiaFrom                    INT         = NULL 
      , @DiaTo                      INT         = NULL 
      , @DaysNoPaymentReceivedFrom  INT         = NULL 
      , @DaysNoPaymentReceivedTo    INT         = NULL 
      





SELECT  PrimaryStatus	              = ISNULL(PrimaryStatus, '')
      , Start_Date	                = ISNULL(REPLACE(CONVERT( VARCHAR(50), StartDate, 105), '-', '/'), '')
      , Agreement_Number	          = ISNULL(AgreementNumber, '')
      , IntroducerName	            = ISNULL(IntroducerName, '')
      , Introductory_Source	        = ISNULL(Source, '')
      , CustomerName	              = '"' + ISNULL(CustomerName, '') + '"'
      , MainProduct	                = ISNULL(MainProduct, '')
      , Advance_Total	              = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Advance_Total)), '')
      , Advance_Average	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Advance_Total)), '')             -- Not an average
      , DocumentFee	                = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), DocumentFee)), '')
      , MonthlyInterest	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), MonthlyInterest)), '')
      , textbox255	                = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), InterestBilled)), '')            -- Name wrong: InterestBilled
      , InterestWaived	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), InterestWaived)), '')
      , Adjustments	                = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Adjustments)), '')
      , FeesBilled	                = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Fees)), '')
      , Age1	                      = ISNULL(CONVERT( VARCHAR(5),  CONVERT( DECIMAL(3,0),  Age)), '')
      , Age_Average	                = ISNULL(CONVERT( VARCHAR(5),  CONVERT( DECIMAL(3,0),  Age)), '')                       -- Not an avareage
      , Instalment_Total	          = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Instalment_Total)), '')
      , APR	                        = ISNULL(CONVERT( VARCHAR(10), CONVERT( DECIMAL(18,2), APR)), '')
      , NonFeeBalance_Outstanding	  = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Balance_NonFee)), '')
      , Balance_NonFee	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Balance_NonFee)), '')            -- Not an average named (avg) in the ui
      , CapitalBalance	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), CapitalBalance_Finance)), '')
      , InterestBalance	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), InterestBalance_Finance)), '')
      , Arrears_non_fee	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Arrears_NonFee)), '')
      , DaysInArrears	              = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), DaysInArrears)), '')             -- Posible rounding
      , Arrears_NonFee	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Arrears_NonFee)), '')            -- Not an average named (avg) in the ui
      , Balance_Fee	                = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Balance_Fee)), '')
      , AmountPaid_Finance	        = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), AmountPaid_Finance)), '')
      , AmountPaid_Fees	            = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), AmountPaid_Fee)), '')
      , AmountPaid_Warranty	        = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), AmountPaid_Warranty)), '')
      , AmountPaid_Insurance	      = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), AmountPaid_Insurance)), '')
      , FirstDueDate	              = ISNULL(REPLACE(CONVERT( VARCHAR(50), FirstDueDate, 105), '-', '/'), '')
      , NextDueDate	                = ISNULL(REPLACE(CONVERT( VARCHAR(50), NextPaymentDate, 105), '-', '/'), '')
      , PreviousDueDate	            = ISNULL(REPLACE(CONVERT( VARCHAR(50), PreviousDueDate, 105), '-', '/'), '')
      , PreviousDueAmount	          = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), PreviousDueAmount)), '')
      , LastPaymentDateReceived	    = ISNULL(REPLACE(CONVERT( VARCHAR(50), LastPaymentReceivedDate, 105), '-', '/'), '')
      , LastPaymentAmountReceived	  = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), LastPaymentAmountReceived)), '')
      , FinalDueDate	              = ISNULL(REPLACE(CONVERT( VARCHAR(50), FinalDueDate, 105), '-', '/'), '')
      , CreateDate	                = ISNULL(REPLACE(CONVERT( VARCHAR(50), CreateDate, 105), '-', '/'), '')
      , LiveDate	                  = ISNULL(REPLACE(CONVERT( VARCHAR(50), LiveDate, 105), '-', '/'), '')
      , CompletedDate	              = ISNULL(REPLACE(CONVERT( VARCHAR(50), CompletedDate, 105), '-', '/'), '')
      , SecondaryStatus	            = ISNULL(SecondaryStatus, '')
      , RecoveryAgent	              = ISNULL(RecoveryAgent , '')
      , DateToRecoveries	          = ISNULL(REPLACE(CONVERT( VARCHAR(50), RecoveriesDate, 105), '-', '/'), '')
      , CapitalAtTransfer	          = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Recoveries_CapitalBalance_Finance)), '')
      , InterestAtTransfer	        = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Recoveries_InterestBalance)), '')
      , FeeBalanceAtTransfer	      = ISNULL(CONVERT( VARCHAR(20), CONVERT( DECIMAL(18,2), Recoveries_TotBalance_Fee)), '')
      , External_Application_Id	    = ISNULL(ExternalApplicationReference, '')
      , External_Customer_Reference = ISNULL(ExternalCustomerReference, '')
FROM    vwSSAS_AppSummary
WHERE PrimaryStatus IN ( SELECT Name FROM @PrimaryStatus )
  AND ( '(All)' IN (@SecondaryStatus) 
        OR SecondaryStatus IN (@SecondaryStatus))
  AND ( '(All)' IN (@Introducer) 
        OR IntroducerName IN (@Introducer))
  AND ( '(All)' IN (@Source) 
        OR Source in (@Source ))
  AND ( '(All)' IN (@Product) 
        OR MainProduct in (@Product ))
  AND ( @StartDateFrom IS NULL 
        OR StartDate >= @StartDateFrom)
  AND ( @StartDateTo IS NULL 
        OR StartDate <= @StartDateTo)
  AND ( @FirstDueDateFrom IS NULL 
        OR FirstDueDate>= @FirstDueDateFrom)
  AND ( @FirstDueDateTo IS NULL 
        OR FirstDueDate <= @FirstDueDateTo)
  AND ( @PrevDueDateFrom IS NULL 
        OR PreviousDueDate>= @PrevDueDateFrom)
  AND ( @PrevDueDateTo IS NULL 
        OR PreviousDueDate <= @PrevDueDateTo)
  AND ( @NextDueDateFrom IS NULL 
        OR NextPaymentDate>= @NextDueDateFrom)
  AND ( @NextDueDateTo IS NULL 
        OR NextPaymentDate <= @NextDueDateTo)
  AND ( @CompletedDateFrom IS NULL 
        OR CompletedDate >= @CompletedDateFrom)
  AND ( @CompletedDateTo IS NULL 
        OR CompletedDate <= @CompletedDateTo)
  AND ( @BalanceFrom IS NULL 
        OR Balance_Total >= @BalanceFrom)
  AND ( @BalanceTo IS NULL 
        OR Balance_Total <= @BalanceTo)
  AND ( @ArrearsFrom IS NULL 
        OR Arrears_Total >= @ArrearsFrom)
  AND ( @ArrearsTo IS NULL 
        OR Arrears_Total <= @ArrearsTo)
  AND ( @DiaFrom IS NULL 
        OR DaysInArrears >= @DiaFrom OR DaysInArrears < 0) 
  AND ( @DiaTo IS NULL 
        OR DaysInArrears <= @DiaTo)
  AND ( @DaysNoPaymentReceivedFrom IS NULL 
        OR DaysNoPaymentsReceived >= @DaysNoPaymentReceivedFrom) 
  AND ( @DaysNoPaymentReceivedTo IS NULL 
        OR DaysNoPaymentsReceived <= @DaysNoPaymentReceivedTo)
ORDER BY PrimaryStatus, StartDate, ApplicationId
