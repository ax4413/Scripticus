SELECT * FROM ::fn_trace_getinfo(default)
GO


DECLARE @TraceID int
-- Populate a variable with the trace_id of the current trace
SELECT  @TraceID = TraceID FROM ::fn_trace_getinfo(default) WHERE VALUE = N'c:\temp\trace.trc'
select @TraceID
-- First stop the trace. 
EXEC sp_trace_setstatus @TraceID, 0

-- Close and then delete its definition from SQL Server. 
EXEC sp_trace_setstatus @TraceID, 2

