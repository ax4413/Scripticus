--====================================================================================================
-- Methods to split a CSV
--====================================================================================================

-- Method 1
	DECLARE @SplitString VARCHAR(1000)
    SELECT @SplitString ='1,4,77,88,4546,234,2,3,54,87,9,6,4,36,6,9,9,6,4,4,68,9,0,5,3,2,'
     
    SELECT SUBSTRING(',' + @SplitString + ',', Number + 1,
		CHARINDEX(',', ',' + @SplitString + ',', Number + 1) - Number -1)AS VALUE
    FROM master..spt_values
	where type = 'P'
    and Number <= LEN(',' + @SplitString + ',') - 1
    AND SUBSTRING(',' + @SplitString + ',', Number, 1) = ','
    GO

-- Method 2 -- same as m1 but with a defined number table
	CREATE TABLE NumberPivot (NumberID INT PRIMARY KEY)
	GO

	INSERT INTO NumberPivot
	SELECT number 
	FROM master..spt_values
	WHERE type = 'P'
   	GO

	DECLARE @SplitString VARCHAR(1000)
    SELECT @SplitString ='1,4,77,88,4546,234,2,3,54,87,9,6,4,36,6,9,9,6,4,4,68,9,0,5,3,2,'
     
    SELECT SUBSTRING(',' + @SplitString + ',', NumberID + 1,
		CHARINDEX(',', ',' + @SplitString + ',', NumberID + 1) - NumberID -1)AS VALUE
    FROM NumberPivot
    WHERE NumberID <= LEN(',' + @SplitString + ',') - 1
		AND SUBSTRING(',' + @SplitString + ',', NumberID, 1) = ','
    GO

-- method 3 A distinct list can be retrieved by supplying the DISTINCT key word