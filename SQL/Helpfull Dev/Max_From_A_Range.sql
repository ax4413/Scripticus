-- ===  Example 1: With Variables
    DECLARE @Int1 INT = 1, 
            @Int2 INT = 3, 
            @Int3 INT = 5;
    
    SELECT  MAX(v)
    FROM    ( VALUES (@Int1), (@Int2), (@Int3) ) AS value(v);
GO


-- ===  Example 2: With Static Values
    SELECT  MAX(v)
    FROM    ( VALUES (1),(5),(3) ) AS value(v);
GO


-- ===  Example 3: With Columns
    CREATE TABLE #SampleTable ( 
        ID INT PRIMARY KEY ,
        Int1 INT,
        Int2 INT,
        Int3 INT 
    );

    INSERT INTO #SampleTable (ID, Int1, Int2, Int3)
        VALUES (1, 1, 2, 3);
    INSERT INTO #SampleTable (ID, Int1, Int2, Int3)
        VALUES (2, 3, 2, 1);
    INSERT INTO #SampleTable (ID, Int1, Int2, Int3)
        VALUES (3, 7, 3, 2);

    -- Query to select maximum value
    SELECT  ID,
            ( SELECT MAX(v) 
              FROM   ( VALUES (Int1), (Int2), (Int3) ) AS value(v) 
            ) AS MaxValue
    FROM    #SampleTable;

    IF OBJECT_ID('tempdb..#SampleTable') IS NOT NULL
        DROP TABLE #SampleTable 
GO