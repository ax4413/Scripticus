/*
Change all the Create Proc stmts and all its variations,
which could be any number of spaces and 'procedure', or 'proc'.

Search for: CREATE:b+proc(edure)*
Replace with: ALTER PROCEDURE

:b -- any tab or space
+ -- 1 or many occurences.  There will always be at least 1 space here.
(edure) -- these letters are in a group.
* -- 0 or more occurences.

This standardizes the script to make subsequent text manipulations easy.
*/

/****** Object:  StoredProcedure [dbo].[BeginDateGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--BeginDateGet 'CriticalTech20140107' with recompile

CREATE PROC [dbo].[BeginDateGet]
    @CollectionName VARCHAR(1024)
AS 

--Gets the begin date for the collection chart.

DECLARE @ID bigint
SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)


SELECT CAST(CollectionDate AS VARCHAR(10)) AS BeginDate 
FROM Final.CollectionDate
WHERE ID = @ID
GROUP BY CollectionDate
ORDER BY BeginDate --OPTION(MAXDOP 1)



GO

/****** Object:  StoredProcedure [dbo].[BeginTimeGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE		   PROCEDURE [dbo].[BeginTimeGet]
    @CollectionName VARCHAR(1024),
	@BeginDate DATE

AS 

--Gets the begin date for the collection chart.

DECLARE @ID BIGINT
SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)


SELECT DISTINCT LEFT(CollectionTime, 5) AS BeginTime
FROM Final.CollectionDate 
WHERE CollectionDate = @BeginDate
AND ID = @ID
ORDER BY BeginTime OPTION(recompile)

GO

/****** Object:  StoredProcedure [dbo].[CollectionNameGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE       PROC [dbo].[CollectionNameGet]

AS

--Gets all collections so you can choose which one to get
--the counters for.
select DISTINCT DisplayString AS CollectionName
from Final.DisplayToID 
ORDER BY DisplayString
GO

/****** Object:  StoredProcedure [dbo].[CounterClassesGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CounterClassesGet]

@CollectionName VARCHAR(1024)

AS

--Gets all counters for a specific named load.  All loads should be named.
----select DISTINCT CDS.ObjectName
----from counterData CD
----INNER JOIN CounterDetails CDS
----ON CD.CounterID = CDS.CounterID
----INNER JOIN DisplayToID DI
----ON CD.GUID = DI.GUID
----AND DI.DisplayString = @CollectionName
----ORDER BY CDS.ObjectName OPTION(RECOMPILE)


DECLARE @ID BIGINT
SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)

SELECT DISTINCT ObjectName
FROM Final.CounterClass
WHERE ID = @ID
ORDER BY ObjectName

----SELECT DISTINCT CD.GUID, CDS.ObjectName
----INTO CollectionCounterClass
----from counterData CD
----INNER JOIN CounterDetails CDS
----ON CD.CounterID = CDS.CounterID
----INNER JOIN DisplayToID DI
----ON CD.GUID = DI.GUID
------AND DI.DisplayString = @CollectionName
----ORDER BY CD.GUID, CDS.ObjectName
GO

/****** Object:  StoredProcedure [dbo].[CounterDataGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE		PROCEDURE [dbo].[CounterDataGet]
    @CollectionName VARCHAR(1024) ,
    @ClassName VARCHAR(1024) ,
    @Counters VARCHAR(2000),
	@Instance VARCHAR(2000),
	@StartDate date,
	@EndDate DATE,
	@StartTime VARCHAR(20),
	@EndTime VARCHAR(20)
AS 

DECLARE @ID BIGINT,
		@StartDateTime DATETIME,
		@EndDateTime DATETIME

SET @StartDateTime = CAST(@StartDate AS VARCHAR(15)) + ' ' + CAST(@StartTime AS VARCHAR(15));
SET @EndDateTime = CAST(@EndDate AS VARCHAR(15)) + ' ' + CAST(@EndTime AS VARCHAR(15));

SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName);

	-- Comma delimited list split method, source from 
	-- http://www.sql-server-helper.com/functions/comma-delimited-to-table.aspx

	-------Parse the counters so you can look at more than one at a time.
    DECLARE @OutputTable TABLE ( [String] VARCHAR(500) );
    DECLARE @String VARCHAR(500);

IF @Instance = 'NULL'
SET @Instance = NULL

    WHILE LEN(@Counters) > 0
        BEGIN
            SET @String = LEFT(@Counters,
                               ISNULL(NULLIF(CHARINDEX(',', @Counters) - 1, -1),
                                      LEN(@Counters)))
            SET @Counters = SUBSTRING(@Counters,
                                      ISNULL(NULLIF(CHARINDEX(',', @Counters),
                                                    0), LEN(@Counters)) + 1,
                                      LEN(@Counters))

            INSERT  INTO @OutputTable
                    ( [String] )
            VALUES  ( @String )
        END

----------Parse the Instances so you can look at more than one at a time. 
    DECLARE @InstanceTable TABLE ( [String] VARCHAR(500) );
    DECLARE @InstanceString VARCHAR(500);

    WHILE LEN(@Instance) > 0
        BEGIN
            SET @InstanceString = LEFT(@Instance,
                               ISNULL(NULLIF(CHARINDEX(',', @Instance) - 1, -1),
                                      LEN(@Instance)))
            SET @Instance = SUBSTRING(@Instance,
                                      ISNULL(NULLIF(CHARINDEX(',', @Instance),
                                                    0), LEN(@Instance)) + 1,
                                      LEN(@Instance))

            INSERT  INTO @InstanceTable
                    ( [String] )
            VALUES  ( @InstanceString )
        END   


--Gets all counters for a specific named load.  All loads should be named.

IF @Instance IS NOT NULL
BEGIN
    SELECT --DISTINCT
            CDS.ObjectName ,
            CDS.CounterName ,
            CDS.InstanceName ,
            CD.CounterDateTime ,
            CD.CounterValue
    FROM    Final.CounterData CD
            INNER JOIN dbo.CounterDetails CDS 
			ON CD.CounterID = CDS.CounterID
    WHERE   CD.ID = @ID
			AND CDS.ObjectName = @ClassName
            AND CDS.CounterName IN ( SELECT [String]
                                 FROM   @OutputTable )
            AND CDS.InstanceName IN ( SELECT [String]
                                 FROM   @InstanceTable )
			AND (
					CD.CounterDateTime >= @StartDateTime
				)

			AND	(	
					CD.CounterDateTime <= @EndDateTime
				)
			--AND (
			--		CD.CounterDateTime >= CAST(@StartDate AS VARCHAR(15)) + ' ' + CAST(@StartTime AS VARCHAR(15))
			--	)

			--AND	(	
			--		CD.CounterDateTime <= CAST(@EndDate AS VARCHAR(15)) + ' ' + CAST(@EndTime AS VARCHAR(15))
			--	)

    --ORDER BY CounterDateTime ,CounterName 
            OPTION(RECOMPILE);
END

IF @Instance IS NULL
BEGIN
    SELECT --DISTINCT
            CDS.ObjectName ,
            CDS.CounterName ,
            CDS.InstanceName ,
            CD.CounterDateTime ,
            CD.CounterValue
    FROM    Final.CounterData CD
            INNER JOIN dbo.CounterDetails CDS ON CD.CounterID = CDS.CounterID
    WHERE   CD.ID = @ID
			AND CDS.ObjectName = @ClassName
            AND CDS.CounterName IN ( SELECT [String]
                                 FROM   @OutputTable )
            --AND CDS.InstanceName IN ( SELECT [String]
            --                     FROM   @InstanceTable )
			AND (
					CD.CounterDateTime >= @StartDateTime
				)

			AND	(	
					CD.CounterDateTime <= @EndDateTime
				)
			--AND (
			--CD.CounterDateTime >= CAST(@StartDate AS VARCHAR(15)) + ' ' + CAST(@StartTime AS VARCHAR(15))

			--AND		
			--CD.CounterDateTime <= CAST(@EndDate AS VARCHAR(15)) + ' ' + CAST(@EndTime AS VARCHAR(15))

			-- )

    --ORDER BY CounterDateTime ,CounterName
             OPTION(RECOMPILE);
END
GO

/****** Object:  StoredProcedure [dbo].[CounterInstanceGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROC [dbo].[CounterInstanceGet]

    @CollectionName VARCHAR(1024) ,
    @ClassName VARCHAR(1024)

AS 


DECLARE @ID BIGINT

SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)

--Gets all counters for a specific named load.  All loads should be named.

	SELECT 'NULL' AS InstanceName
	UNION
	SELECT InstanceName
	FROM Final.CounterInstance
	 WHERE  ID = @ID
	AND ObjectName = @ClassName
GO

/****** Object:  StoredProcedure [dbo].[CountersGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CountersGet]



@CollectionName VARCHAR(1024),

@ClassName VARCHAR(1024)



AS



DECLARE @ID BIGINT

SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)



--Gets all counters for a specific named load.  All loads should be named.

select [COUNTER] --DISTINCT 
			, MachineName 
FROM Final.Counters C
WHERE ID = @ID
AND ObjectName = @ClassName
ORDER BY [COUNTER]
GO

/****** Object:  StoredProcedure [dbo].[EndDateGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--  EndDateGet 'criticaltech20140107', '2013/12/01'


CREATE PROCEDURE [dbo].[EndDateGet]
    @CollectionName VARCHAR(1024),
	@BeginDate DATE
AS 

DECLARE @ID BIGINT
SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)


SELECT DISTINCT CAST(CollectionDate AS VARCHAR(10)) AS EndDate
FROM Final.CollectionDate
WHERE ID = @ID
AND CollectionDate >= @BeginDate
ORDER BY EndDate



GO

/****** Object:  StoredProcedure [dbo].[EndTimeGet]    Script Date: 3/25/2014 10:46:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[EndTimeGet]
    @CollectionName VARCHAR(1024),
	@EndDate DATE
AS 

DECLARE @ID BIGINT
SET @ID = (SELECT ID FROM Final.DisplayToID
				WHERE DisplayString = @CollectionName)

SELECT DISTINCT LEFT(CollectionTime, 5) AS EndTime
FROM Final.CollectionDate
WHERE ID = @ID
AND CollectionDate = @EndDate
ORDER BY EndTime 

GO


