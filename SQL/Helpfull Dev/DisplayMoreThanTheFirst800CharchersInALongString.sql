--===================================================================
--      Display varchar(8000)+ &NVarchar(8000)+
--	   Only the first 8000 chars are displayed in SSMS use this
--	   method to split the spring up and return it in chunks.
--	   A tally table is required
--===================================================================

--===== Declare a couple of long string variables of two different datatypes
DECLARE @LongString  VARCHAR(MAX),
        @NLongString NVARCHAR(MAX)
;

--===== Fill each string with 10,000 GUIDs followed by a space
     -- for a total of 369999 (+1 trailing space) characters.
 SELECT @LongString = (SELECT CAST(NEWID() AS CHAR(36)) + ' '
                          FROM dbo.Tally t
                         WHERE t.N BETWEEN 1 AND 10000
                           FOR XML PATH('')),
        @NLongString = @LongString
;

--===== Just confirming the length of the strings here
 SELECT LEN(@LongString), LEN(@NLongString)
;

--===== Let's solve the problem with a little control over the width
     -- of the returned data.  This could easily be converted into
     -- an inline Table Valued Function.
DECLARE @Width INT;
SELECT @Width = 8000;

--===== Show that the solution works on VARCHAR(MAX)
 SELECT StartPosition = (t.N-1)*@Width+1,
        SliceData     = SUBSTRING(@LongString,(t.N-1)*@Width+1,@Width)
   FROM dbo.Tally t
  WHERE t.N BETWEEN 1 AND LEN(@LongString)/@Width+1
;

--===== Show that the solution works on NVARCHAR(MAX)
 SELECT StartPosition = (t.N-1)*@Width+1,
        SliceData     = SUBSTRING(@NLongString,(t.N-1)*@Width+1,@Width)
   FROM dbo.Tally t
  WHERE t.N BETWEEN 1 AND LEN(@NLongString)/@Width+1
;