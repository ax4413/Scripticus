-- xp_readerrorlog
--
-- Running xp_readerrorlog without any parameters returns the current SQL Server error log (ERRORLOG).
--
-- Paramater 1:		The first parameter specifies which log to return the default is “0”:
-- Paramater 2:		The second parameter is used to specify  which log type to review.
-- 					      The default is 1 the SQL Server database engine, but you can specify a 2
--                for the SQL Server agent. Anything larger than a 2 here will return an invalid
--                parameter
-- Paramater 3:   The 3rd parameter is used to specify a search strings.
-- Paramater 4:   The 4th parameter is used to specify a search strings.
-- Paramater 5:   Date range from
-- Paramater 6:   Date range to
-- Paramater 7:   Sort order 'DESC'


-- === Where is my error log located on disk. Theis cmd will tell you
EXEC xp_readerrorlog 0, 1, N'Logging SQL Server messages in file'
GO


-- ===	What port is this instance listening on
xp_readerrorlog 0, 1, N'Server is listening on'
GO


-- ===  Search within the current (0) error log for records that contain the text
-- ===  "server" and "process id"
xp_readerrorlog 5, 1, N'server', N'process ID'
GO


-- ===  Search within the 5th error log for records that contain the text
-- ===  "server" and "process id"
xp_readerrorlog 5, 1, N'server', N'process ID'
GO


-- ===  Search within the current sql agent log for records that contain the text
-- ===  "server" and "process id"
xp_readerrorlog 0, 2, N'server', N'process ID'
GO


-- ===  Search by date
EXEC xp_ReadErrorLog 0, 1, Null, Null, '2015-12-01 16:00:00', '2015-12-01 17:00:00'
GO


-- === Sort Order
EXEC xp_ReadErrorLog 0, 1, Null, Null, NULL, NULL, 'DESC'
GO