-- ==========================================================================================
-- http://dpatrickcaldwell.blogspot.co.uk/2009/05/converting-decimal-to-hexadecimal-with.html
-- ==========================================================================================

CREATE FUNCTION ConvertToBase
(
    @value AS BIGINT,
    @base AS INT
) RETURNS VARCHAR(MAX) AS BEGIN

    -- some variables
    DECLARE @characters CHAR(36),
            @result VARCHAR(MAX);

    -- the encoding string and the default result
    SELECT @characters = '0123456789abcdefghijklmnopqrstuvwxyz',
           @result = '';

    -- make sure it's something we can encode.  you can't have
    -- base 1, but if we extended the length of our @character
    -- string, we could have greater than base 36
    IF @value < 0 OR @base < 2 OR @base > 36 RETURN NULL;

    -- until the value is completely converted, get the modulus
    -- of the value and prepend it to the result string.  then
    -- devide the value by the base and truncate the remainder
    WHILE @value > 0
        SELECT @result = SUBSTRING(@characters, @value % @base + 1, 1) + @result,
               @value = @value / @base;

    -- return our results
    RETURN @result;

END


select dbo.ConvertToBase(75,2) 