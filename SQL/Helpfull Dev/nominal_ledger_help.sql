
-- ====	Execution History	============================================

SELECT	eh.ExecutionHistoryId, et.Description, eh.StartTime, eh.EndTime, CASE ehd.IsError WHEN 1 THEN 1 ELSE 0 END AS IsError, ehd.Message
FROM	internal.ExecutionHistory eh
		INNER JOIN internal.ExecutionType et on et.ExecutionTypeId = eh.ExecutionTypeId
		LEFT OUTER JOIN internal.ExecutionHistoryDetail ehd on ehd.ExecutionHistoryId = eh.ExecutionHistoryId
WHERE	eh.StartTime > '20191111'
--AND		ehd.IsError = 1
ORDER BY eh.ExecutionHistoryId DESC, ehd.ExecutionHistoryDetailId DESC



-- ====	Process Date	================================================

SELECT * FROM base.Systemparameter WHERE ParameterName = 'ProcessDate'

SELECT base.GetProcessDate(GETDATE())



-- ====	Initial / Incremental Load	====================================

SELECT * FROM internal.cdc_states

SELECT * FROM base.Application ORDER BY 1 DESC

SELECT	ft.financialtransactionid, ft.postingdate, ft.valuedate, tt.description, *
		FROM base.FinancialTransaction ft
		INNER JOIN base.transactiontype  tt ON tt.transactiontypeid = ft.transactionTypeid
ORDER BY 1 DESC



-- ==== Config	========================================================

SELECT * FROM nominal.NominalStatus
SELECT * FROM nominal.PaymentGroup


SELECT	[AccountingTreatmentId]  = cat.AccountingTreatmentId, 
	    [PeriodEndAccrual]       = cat.PeriodEndAccrual, 
		[FinancialProduct]       = bfp.Description, 
		[IncomeMethodId]	     = cat.IncomeMethod,
		[IncomeMethod]           = bim.Description, 
		[CapitaInterestMethodId] = cat.CapitalInterestMethod,
		[CapitaInterestMethod]   = bcim.Description 
FROM	config.AccountingTreatment cat
		LEFT OUTER JOIN base.FinancialProduct bfp 
						ON bfp.FinancialProductId = cat.FinancialProductID
		LEFT OUTER JOIN base.List bim 
						ON bim.ListId = cat.IncomeMethod
		LEFT OUTER JOIN base.List bcim 
						ON bcim.ListId = cat.CapitalInterestMethod
;


SELECT	cna.NominalAccountId,
		cna.Description,
		cna.Code,
		NominalCategoryId              = cna.Category,
		NominalCategory	               = bl.Description, 
		NominalCategoryListDescription = bld.Description
FROM	config.NominalAccount cna 
		LEFT OUTER JOIN base.list bl 
						ON bl.ListId = cna.Category
		LEFT OUTER JOIN base.ListDescription bld
						ON bld.ListDescriptionId = bl.ListDescriptionId
;


SELECT	cnda.NominalDataItemId,
		cnda.Sequence,
		NominalItem                = bl.Description,
		NominalItemListDescription = bld.Description
FROM	config.NominalDataItem cnda
		INNER JOIN base.list bl 
				ON bl.ListId = cnda.NominalItem
		INNER JOIN base.ListDescription bld
				ON bld.ListDescriptionId = bl.ListDescriptionId
;


; WITH x AS (
	SELECT	NominalAccountId   = cna.NominalAccountId,
			NominalAccount     = cna.Description,
			NominalAccountCode = cna.Code,
			NominalCategoryId  = cna.Category,
			NominalCategory	   = bl.Description 
	FROM	config.NominalAccount cna 
			INNER JOIN base.list bl 
					   ON bl.ListId = cna.Category
)
SELECT	NominalAccountMappingId = m.NominalAccountMappingId,
		NominalSourceId         = m.NominalSource,
		NominalSource           = blns.Description,
		AccountingEventId       = m.AccountingEvent,
		AccountingEvent         = blae.Description,
		PaymentMethodId         = m.PaymentMethod,
		PaymentMethod           = blpm.Description,
		FinancialProductId      = m.FinancialProductId,
		FinancialProduct        = bfp.Description,
		HostCompanyId           = m.HostCompanyId,
		HostCompany             = '????',
		PrimaryStatusId         = m.PrimaryStatus,
		PrimaryStatus           = blps.Description,
		SecondaryStatusId       = m.SecondaryStatusId, 
		SecondaryStatus         = bss.Description,
		TransactionTypeId       = m.TransactionTypeId,
		TransactionType			= btt.Description,
		DebitAccountId			= m.DebitAccount,
		DebitAccount			= da.NominalAccount,
		DebitCategory			= da.NominalCategory,
		DebitInterestAccountId	= m.DebitAccountInterest,
		DebitInterestAccount	= dai.NominalAccount,
		DebitInterestCategory	= dai.NominalCategory,
		DebitSuspenseAccountId	= m.DebitAccountSuspense,
		DebitSuspenseAccount	= das.NominalAccount,
		DebitSuspenseCategory	= das.NominalCategory,
		CreditAccountId			= m.CreditAccount,
		CreditAccount			= ca.NominalAccount,
		CreditCategory			= ca.NominalCategory,
		CreditInterestAccountId	= m.CreditAccountInterest,
		CreditInterestAccount	= cai.NominalAccount,
		CreditInterestCategory	= cai.NominalCategory,
		CreditSuspenseAccountId	= m.CreditAccountSuspense,
		CreditSuspenseAccount	= cas.NominalAccount,
		CreditSuspenseCategory	= cas.NominalCategory
FROM	config.NominalAccountMapping m
		LEFT OUTER JOIN base.TransactionType btt ON btt.TransactionTypeId = m.TransactionTypeId
		LEFT OUTER JOIN base.List blns ON blns.ListId = m.NominalSource
		LEFT OUTER JOIN base.List blae ON blae.ListId = m.AccountingEvent
		LEFT OUTER JOIN base.List blpm ON blpm.ListId = m.PaymentMethod
		LEFT OUTER JOIN base.List blps ON blps.ListId = m.PrimaryStatus
		LEFT OUTER JOIN base.ApplicationStatus bss on bss.ApplicationStatusid = m.SecondaryStatusId
		LEFT OUTER JOIN base.FinancialProduct bfp ON bfp.FinancialProductId = m.FinancialProductId
		LEFT OUTER JOIN x da  ON m.DebitAccount          = da.NominalAccountId
		LEFT OUTER JOIN x dai ON m.DebitAccountInterest  = dai.NominalAccountId
		LEFT OUTER JOIN x das ON m.DebitAccountSuspense  = das.NominalAccountId
		LEFT OUTER JOIN x ca  ON m.CreditAccount         = ca.NominalAccountId
		LEFT OUTER JOIN x cai ON m.CreditAccountInterest = cai.NominalAccountId
		LEFT OUTER JOIN x cas ON m.CreditAccountSuspense = cas.NominalAccountId
;



-- ==== Nominals	====================================================

SELECT	*
FROM	[working].[ApplicationPaymentFinancialTransaction]
;


SELECT	ft.FinancialTransactionId, ftns.CreateDate, ftns.CreateProcessDate, ns.Description, ft.*
FROM	base.FinancialTransaction ft 
		LEFT OUTER JOIN nominal.FinancialTransactionNominalStatus ftns
					    ON ftns.FinancialTransactionId = ft.FinancialTransactionId
		LEFT OUTER JOIN nominal.NominalStatus ns 
		                ON ns.nominalstatusid = ftns.nominalstatusid
ORDER BY ft.FinancialTransactionId
;


SELECT	ae.AccountingEventId,
		ns.Description         as NominalStatus,
		aens.CreateDate        as NominalStatusCreateDate, 
		aens.CreateProcessDate as NominalStatusCreateProcessDate,  
		ae.ApplicationId, 
		ae.FinancialTransactionId,
		ae.Type                as TypeId, 
		l.Description          as TypeDescription,
		ae.Amount, 
		ae.Capital, 
		ae.Interest, 
		ae.PostingDate, 
		ae.ValueDate, 
		ae.InputParameters, 
		ae.Calculation, 
		ae.CreateDate, 
		ae.CreateProcessDate
FROM	nominal.AccountingEvent ae
		INNER JOIN base.list l on l.ListId = ae.Type
		LEFT OUTER JOIN nominal.AccountingEventNominalStatus aens 
						ON aens.AccountingEventId = ae.AccountingEventId
		LEFT OUTER JOIN nominal.NominalStatus ns 
		                ON ns.NominalStatusId = aens.NominalStatusId
ORDER BY ae.AccountingEventId DESC
;



SELECT	*
FROM	nominal.NominalTransaction
ORDER BY ApplicationId DESC
;


; WITH x AS (
	SELECT	NominalAccountId   = cna.NominalAccountId,
			NominalAccount     = cna.Description,
			NominalAccountCode = cna.Code,
			NominalCategoryId  = cna.Category,
			NominalCategory	   = bl.Description 
	FROM	config.NominalAccount cna 
			INNER JOIN base.list bl 
					   ON bl.ListId = cna.Category
)
SELECT	nnab.NominalAccountBalanceId, nnab.Date, nnab.DebitBalance, nnab.CreditBalance, nnab.CreateDate, nnab.CreateProcessDate, x.NominalAccount, x.NominalCategory
FROM	nominal.NominalAccountBalance nnab
		INNER JOIN x ON x.NominalAccountId = nnab.NominalAccountId
ORDER BY NominalAccountBalanceId DESC
;