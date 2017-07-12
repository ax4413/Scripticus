USE AdventureWorks2012

SELECT 	s.SalesOrderID
			, s.SalesOrderDetailID
			, s.OrderQty
			, [FstValue] 									= FIRST_VALUE(SalesOrderDetailID)
																			OVER (	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID
																							ROWS BETWEEN UNBOUNDED PRECEDING
																							AND UNBOUNDED FOLLOWING  )

			, [LstValue] 									=	LAST_VALUE(SalesOrderDetailID)
																			OVER (	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID
																							ROWS BETWEEN UNBOUNDED PRECEDING
																							AND UNBOUNDED FOLLOWING  )

			, [Lag] 											= LAG(SalesOrderDetailID)
																			OVER (	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID  )

			, [Lead] 											= LEAD(SalesOrderDetailID)
																			OVER (	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID  )

			, [RunningTotal] 							= SUM(OrderQty)
																			OVER (	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID
																							ROWS BETWEEN UNBOUNDED PRECEDING
																							AND CURRENT ROW  )

			, [PreviousRunningTotal-V1] = SUM(s.OrderQty)
																			OVER (	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID  ) - s.OrderQty

			, [PreviousRunningTotal-V2] = SUM(OrderQty)
																			OVER ( 	PARTITION BY SalesOrderID
																							ORDER BY SalesOrderDetailID
																							ROWS BETWEEN UNBOUNDED PRECEDING
																							AND 1 PRECEDING  )
FROM 		Sales.SalesOrderDetail s
WHERE 	SalesOrderID IN (43670, 43669, 43667, 43663)
ORDER BY s.SalesOrderID
			, s.SalesOrderDetailID
			, s.OrderQty