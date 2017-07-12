DECLARE @ip VARCHAR (8000) = 'My Name is Pinal Dave';

WITH cteSplit AS (
    SELECT  SUBSTRING (@ip, t.N, CHARINDEX (' ', @ip + ' ', t.N) - t.n  ) AS [value], 
            t.n 
    FROM    ph.tally t
    WHERE   t.N <= LEN (@ip)
            AND SUBSTRING (' ' + @ip, t.n, 1) = ' '
)
SELECT * FROM cteSplit /*

SELECT  STUFF ((SELECT ' ' + value
                FROM    cteSplit
                ORDER BY n DESC
                FOR XML path (''), TYPE).value ('.', 'varchar (8000)'), 1, 1, '')
--*/