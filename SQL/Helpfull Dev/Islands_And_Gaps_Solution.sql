--CREATE TABLE GapsIslands (ID INT NOT NULL, SeqNo INT NOT NULL);
 
--ALTER TABLE dbo.GapsIslands ADD CONSTRAINT pk_GapsIslands PRIMARY KEY (ID, SeqNo);
 

--INSERT INTO dbo.GapsIslands
--SELECT 1, 1 UNION ALL SELECT 1, 2 UNION ALL SELECT 1, 5 UNION ALL SELECT 1, 6
--UNION ALL SELECT 1, 8 UNION ALL SELECT 1, 9 UNION ALL SELECT 1, 10 UNION ALL SELECT 1, 12
--UNION ALL SELECT 1, 20 UNION ALL SELECT 1, 21 UNION ALL SELECT 1, 25 UNION ALL SELECT 1, 26 


--SELECT * FROM dbo.GapsIslands;

 
PRINT '-- ==== Islands Solution #1 from SQL MVP Deep Dives';
WITH StartingPoints AS
(
    SELECT ID, SeqNo, ROW_NUMBER() OVER(ORDER BY SeqNo) AS rownum
    FROM dbo.GapsIslands AS A
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.GapsIslands AS B
        WHERE B.ID = A.ID AND B.SeqNo = A.SeqNo - 1)
),
EndingPoints AS
(
    SELECT ID, SeqNo, ROW_NUMBER() OVER(ORDER BY SeqNo) AS rownum
    FROM dbo.GapsIslands AS A
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.GapsIslands AS B
        WHERE B.ID = A.ID AND B.SeqNo = A.SeqNo + 1)
)
SELECT S.ID, S.SeqNo AS start_range, E.SeqNo AS end_range
FROM StartingPoints AS S
JOIN EndingPoints AS E ON E.ID = S.ID AND E.rownum = S.rownum
;
 

PRINT '-- ==== Islands Solution #3 from SQL MVP Deep Dives';
SELECT ID, StartSeqNo=MIN(SeqNo), EndSeqNo=MAX(SeqNo)
FROM (
    SELECT ID, SeqNo
        ,rn=SeqNo-ROW_NUMBER() OVER (PARTITION BY ID ORDER BY SeqNo)
    FROM dbo.GapsIslands) a
GROUP BY ID, rn
;



PRINT '-- ==== Gaps Solution #1 from SQL MVP Deep Dives';
SELECT ID, StartSeqNo=SeqNo + 1, EndSeqNo=(
    SELECT MIN(B.SeqNo)
    FROM dbo.GapsIslands AS B
    WHERE B.ID = A.ID AND B.SeqNo > A.SeqNo) - 1
FROM dbo.GapsIslands AS A
WHERE NOT EXISTS (
    SELECT *
    FROM dbo.GapsIslands AS B
    WHERE B.ID = A.ID AND B.SeqNo = A.SeqNo + 1) AND
        SeqNo < (SELECT MAX(SeqNo)
                 FROM dbo.GapsIslands B
                 WHERE B.ID = A.ID)
;

 
PRINT '-- ==== Gaps Solution #2 from SQL MVP Deep Dives';
SELECT ID, StartSeqNo=cur + 1, EndSeqNo=nxt - 1
FROM (
    SELECT ID, cur=SeqNo, nxt=(
        SELECT MIN(B.SeqNo)
        FROM dbo.GapsIslands AS B
        WHERE B.ID = A.ID AND B.SeqNo > A.SeqNo)
    FROM dbo.GapsIslands AS A) AS D
WHERE nxt - cur > 1
;

 
PRINT '-- ==== Gaps Solution #3 from SQL MVP Deep Dives';
WITH C AS
(
    SELECT ID, SeqNo, ROW_NUMBER() OVER(PARTITION BY ID ORDER BY SeqNo) AS rownum
    FROM dbo.GapsIslands
)
SELECT Cur.ID, StartSeqNo=Cur.SeqNo + 1, EndSeqNo=Nxt.SeqNo - 1
FROM C AS Cur
JOIN C AS Nxt ON Cur.ID = Nxt.ID AND Nxt.rownum = Cur.rownum + 1
WHERE Nxt.SeqNo - Cur.SeqNo > 1
;