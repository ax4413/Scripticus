DECLARE @str VARCHAR(8000)
SELECT  @str = 'ab_123ce234fe0'

DECLARE @KeepValues AS VARCHAR(50)
    SET @KeepValues = '%[^0-9]%'

WHILE PATINDEX(@KeepValues, @Str) > 0
  SET @Str = STUFF(@Str, PATINDEX(@KeepValues, @Str), 1, '')

SELECT @str