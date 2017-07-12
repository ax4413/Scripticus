-- =================================================================================================
-- DBCC Commands
-- MSDN Link:  http://msdn.microsoft.com/en-us/library/ms188796.aspx
-- =================================================================================================



-- ===  Show a list of all dbcc commands  ==========================================================
DBCC HELP ('?');

-- ===  Get help on a command ======================================================================
DBCC HELP ('CheckDB');



-- === 	Show statistsic detaild for a Schema.Table for a given Index	==============================
DBCC SHOW_STATISTICS ('schema.table', 'indexName')


-- === 	Displays fragmentation information for the data and indexes of the specified table or view.
DBCC SHOWCONTIG ('schema.table', 'indexName') WITH TABLERESULTS


-- ===  Perform a defragmentation of indexes of the specified table or view.  ======================
DBCC INDEXDEFRAG ('AdventureWorks', 'schema.table', 'indexName')


-- ===  Show log usage	============================================================================
DBCC SQLPERF(LOGSPACE);


-- === 	Show user options	==========================================================================
DBCC USEROPTIONS


-- ===  Check for bad constraints   ================================================================
DBCC CHECKCONSTRAINTS('schema.table') WITH ALL_CONSTRAINTS, NO_INFOMSGS, ALL_ERRORMSGS


-- ===  Check the current db for corruption and return the results as table   ======================
DBCC CHECKDB WITH NO_INFOMSGS, ALL_ERRORMSGS, TABLERESULTS


-- ===  Fix AdventureWorks of corruption this should be your last resort  ==========================
DBCC CHECKDB ( 'AdventureWorks', REPAIR_ALLOW_DATA_LOSS ) WITH NO_INFOMSGS, ALL_ERRORMSGS, TABLERESULTS


-- ===  Read page 1 ,10 from db 18 with display staus 2. This reuires TRACE FLAG 3604 to be set ====
DBCC PAGE(18,1,10,2)


-- === Check what the status of trace flag x is ====================================================
DBCC TRACESTATUS (3604, -1);

-- ===  Turn on trace flag x
DBCC TRACEON(3604)

-- DBCC PAGE

-- ===  Turn off trace flag x
DBCC TRACEOFF(3604)


-- ===  See what the session properties are   ======================================================
DBCC useroptions