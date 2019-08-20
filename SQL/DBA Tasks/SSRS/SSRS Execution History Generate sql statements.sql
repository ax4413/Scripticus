DECLARE @Id INT = 1

; WITH SqlText AS (
    SELECT  [Param1]  = CASE WHEN LTRIM(RTRIM(Param1)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param1,  CHARINDEX('=',  Param1)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param1,  LEN(Param1) - CHARINDEX('=',  Param1)))),  CHAR(39)) END
          , [Param2]  = CASE WHEN LTRIM(RTRIM(Param2)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param2,  CHARINDEX('=',  Param2)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param2,  LEN(Param2) - CHARINDEX('=',  Param2)))),  CHAR(39)) END
          , [Param3]  = CASE WHEN LTRIM(RTRIM(Param3)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param3,  CHARINDEX('=',  Param3)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param3,  LEN(Param3) - CHARINDEX('=',  Param3)))),  CHAR(39)) END
          , [Param4]  = CASE WHEN LTRIM(RTRIM(Param4)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param4,  CHARINDEX('=',  Param4)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param4,  LEN(Param4) - CHARINDEX('=',  Param4)))),  CHAR(39)) END
          , [Param5]  = CASE WHEN LTRIM(RTRIM(Param5)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param5,  CHARINDEX('=',  Param5)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param5,  LEN(Param5) - CHARINDEX('=',  Param5)))),  CHAR(39)) END
          , [Param6]  = CASE WHEN LTRIM(RTRIM(Param6)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param6,  CHARINDEX('=',  Param6)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param6,  LEN(Param6) - CHARINDEX('=',  Param6)))),  CHAR(39)) END
          , [Param7]  = CASE WHEN LTRIM(RTRIM(Param7)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param7,  CHARINDEX('=',  Param7)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param7,  LEN(Param7) - CHARINDEX('=',  Param7)))),  CHAR(39)) END
          , [Param8]  = CASE WHEN LTRIM(RTRIM(Param8)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param8,  CHARINDEX('=',  Param8)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param8,  LEN(Param8) - CHARINDEX('=',  Param8)))),  CHAR(39)) END
          , [Param9]  = CASE WHEN LTRIM(RTRIM(Param9)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param9,  CHARINDEX('=',  Param9)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param9,  LEN(Param9) - CHARINDEX('=',  Param9)))),  CHAR(39)) END
          , [Param10] = CASE WHEN LTRIM(RTRIM(Param10)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param10,  CHARINDEX('=',  Param10)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param10,  LEN(Param10) - CHARINDEX('=',  Param10)))),  CHAR(39)) END
          , [Param11] = CASE WHEN LTRIM(RTRIM(Param11)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param11,  CHARINDEX('=',  Param11)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param11,  LEN(Param11) - CHARINDEX('=',  Param11)))),  CHAR(39)) END
          , [Param12] = CASE WHEN LTRIM(RTRIM(Param12)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param12,  CHARINDEX('=',  Param12)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param12,  LEN(Param12) - CHARINDEX('=',  Param12)))),  CHAR(39)) END
          , [Param13] = CASE WHEN LTRIM(RTRIM(Param13)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param13,  CHARINDEX('=',  Param13)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param13,  LEN(Param13) - CHARINDEX('=',  Param13)))),  CHAR(39)) END
          , [Param14] = CASE WHEN LTRIM(RTRIM(Param14)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param14,  CHARINDEX('=',  Param14)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param14,  LEN(Param14) - CHARINDEX('=',  Param14)))),  CHAR(39)) END
          , [Param15] = CASE WHEN LTRIM(RTRIM(Param15)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param15,  CHARINDEX('=',  Param15)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param15,  LEN(Param15) - CHARINDEX('=',  Param15)))),  CHAR(39)) END
          , [Param16] = CASE WHEN LTRIM(RTRIM(Param16)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param16,  CHARINDEX('=',  Param16)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param16,  LEN(Param16) - CHARINDEX('=',  Param16)))),  CHAR(39)) END
          , [Param17] = CASE WHEN LTRIM(RTRIM(Param17)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param17,  CHARINDEX('=',  Param17)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param17,  LEN(Param17) - CHARINDEX('=',  Param17)))),  CHAR(39)) END
          , [Param18] = CASE WHEN LTRIM(RTRIM(Param18)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param18,  CHARINDEX('=',  Param18)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param18,  LEN(Param18) - CHARINDEX('=',  Param18)))),  CHAR(39)) END
          , [Param19] = CASE WHEN LTRIM(RTRIM(Param19)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param19,  CHARINDEX('=',  Param19)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param19,  LEN(Param19) - CHARINDEX('=',  Param19)))),  CHAR(39)) END
          , [Param20] = CASE WHEN LTRIM(RTRIM(Param20)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param20,  CHARINDEX('=',  Param20)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param20,  LEN(Param20) - CHARINDEX('=',  Param20)))),  CHAR(39)) END
          , [Param21] = CASE WHEN LTRIM(RTRIM(Param21)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param21,  CHARINDEX('=',  Param21)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param21,  LEN(Param21) - CHARINDEX('=',  Param21)))),  CHAR(39)) END
          , [Param22] = CASE WHEN LTRIM(RTRIM(Param22)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param22,  CHARINDEX('=',  Param22)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param22,  LEN(Param22) - CHARINDEX('=',  Param22)))),  CHAR(39)) END
          , [Param23] = CASE WHEN LTRIM(RTRIM(Param23)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param23,  CHARINDEX('=',  Param23)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param23,  LEN(Param23) - CHARINDEX('=',  Param23)))),  CHAR(39)) END
          , [Param24] = CASE WHEN LTRIM(RTRIM(Param24)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param24,  CHARINDEX('=',  Param24)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param24,  LEN(Param24) - CHARINDEX('=',  Param24)))),  CHAR(39)) END
          , [Param25] = CASE WHEN LTRIM(RTRIM(Param25)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param25,  CHARINDEX('=',  Param25)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param25,  LEN(Param25) - CHARINDEX('=',  Param25)))),  CHAR(39)) END
          , [Param26] = CASE WHEN LTRIM(RTRIM(Param26)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param26,  CHARINDEX('=',  Param26)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param26,  LEN(Param26) - CHARINDEX('=',  Param26)))),  CHAR(39)) END
          , [Param27] = CASE WHEN LTRIM(RTRIM(Param27)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param27,  CHARINDEX('=',  Param27)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param27,  LEN(Param27) - CHARINDEX('=',  Param27)))),  CHAR(39)) END
          , [Param28] = CASE WHEN LTRIM(RTRIM(Param28)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param28,  CHARINDEX('=',  Param28)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param28,  LEN(Param28) - CHARINDEX('=',  Param28)))),  CHAR(39)) END
          , [Param29] = CASE WHEN LTRIM(RTRIM(Param29)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param29,  CHARINDEX('=',  Param29)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param29,  LEN(Param29) - CHARINDEX('=',  Param29)))),  CHAR(39)) END
          , [Param30] = CASE WHEN LTRIM(RTRIM(Param30)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param30,  CHARINDEX('=',  Param30)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param30,  LEN(Param30) - CHARINDEX('=',  Param30)))),  CHAR(39)) END
          , [Param31] = CASE WHEN LTRIM(RTRIM(Param31)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param31,  CHARINDEX('=',  Param31)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param31,  LEN(Param31) - CHARINDEX('=',  Param31)))),  CHAR(39)) END
          , [Param32] = CASE WHEN LTRIM(RTRIM(Param32)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param32,  CHARINDEX('=',  Param32)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param32,  LEN(Param32) - CHARINDEX('=',  Param32)))),  CHAR(39)) END
          , [Param33] = CASE WHEN LTRIM(RTRIM(Param33)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param33,  CHARINDEX('=',  Param33)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param33,  LEN(Param33) - CHARINDEX('=',  Param33)))),  CHAR(39)) END
          , [Param34] = CASE WHEN LTRIM(RTRIM(Param34)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param34,  CHARINDEX('=',  Param34)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param34,  LEN(Param34) - CHARINDEX('=',  Param34)))),  CHAR(39)) END
          , [Param35] = CASE WHEN LTRIM(RTRIM(Param35)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param35,  CHARINDEX('=',  Param35)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param35,  LEN(Param35) - CHARINDEX('=',  Param35)))),  CHAR(39)) END
          , [Param36] = CASE WHEN LTRIM(RTRIM(Param36)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param36,  CHARINDEX('=',  Param36)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param36,  LEN(Param36) - CHARINDEX('=',  Param36)))),  CHAR(39)) END
          , [Param37] = CASE WHEN LTRIM(RTRIM(Param37)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param37,  CHARINDEX('=',  Param37)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param37,  LEN(Param37) - CHARINDEX('=',  Param37)))),  CHAR(39)) END
          , [Param38] = CASE WHEN LTRIM(RTRIM(Param38)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param38,  CHARINDEX('=',  Param38)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param38,  LEN(Param38) - CHARINDEX('=',  Param38)))),  CHAR(39)) END
          , [Param39] = CASE WHEN LTRIM(RTRIM(Param39)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param39,  CHARINDEX('=',  Param39)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param39,  LEN(Param39) - CHARINDEX('=',  Param39)))),  CHAR(39)) END
          , [Param40] = CASE WHEN LTRIM(RTRIM(Param40)) <> '-' 
                          THEN  '@'   + LTRIM(RTRIM(LEFT(Param40,  CHARINDEX('=',  Param40)-1)))
                              + ' = ' + QUOTENAME(LTRIM(RTRIM(RIGHT(Param40,  LEN(Param40) - CHARINDEX('=',  Param40)))),  CHAR(39)) END
    FROM    #ReportHistory
    WHERE   id = @Id
)


SELECT 'EXEC FOO '  + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param1  IS NULL THEN '' ELSE Param1  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param2  IS NULL THEN '' ELSE Param2  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param3  IS NULL THEN '' ELSE Param3  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param6  IS NULL THEN '' ELSE Param6  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param4  IS NULL THEN '' ELSE Param4  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param6  IS NULL THEN '' ELSE Param6  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param7  IS NULL THEN '' ELSE Param7  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param8  IS NULL THEN '' ELSE Param8  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param9  IS NULL THEN '' ELSE Param9  + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param10 IS NULL THEN '' ELSE Param10 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param11 IS NULL THEN '' ELSE Param11 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param12 IS NULL THEN '' ELSE Param12 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param13 IS NULL THEN '' ELSE Param13 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param14 IS NULL THEN '' ELSE Param14 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param16 IS NULL THEN '' ELSE Param16 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param16 IS NULL THEN '' ELSE Param16 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param17 IS NULL THEN '' ELSE Param17 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param18 IS NULL THEN '' ELSE Param18 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param19 IS NULL THEN '' ELSE Param19 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param20 IS NULL THEN '' ELSE Param20 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param21 IS NULL THEN '' ELSE Param21 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param22 IS NULL THEN '' ELSE Param22 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param23 IS NULL THEN '' ELSE Param23 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param24 IS NULL THEN '' ELSE Param24 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param26 IS NULL THEN '' ELSE Param26 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param26 IS NULL THEN '' ELSE Param26 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param27 IS NULL THEN '' ELSE Param27 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param28 IS NULL THEN '' ELSE Param28 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param29 IS NULL THEN '' ELSE Param29 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param30 IS NULL THEN '' ELSE Param30 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param31 IS NULL THEN '' ELSE Param31 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param32 IS NULL THEN '' ELSE Param32 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param33 IS NULL THEN '' ELSE Param33 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param34 IS NULL THEN '' ELSE Param34 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param36 IS NULL THEN '' ELSE Param36 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param36 IS NULL THEN '' ELSE Param36 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param37 IS NULL THEN '' ELSE Param37 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param38 IS NULL THEN '' ELSE Param38 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param39 IS NULL THEN '' ELSE Param39 + ', ' END
                    + CHAR(13) + CHAR(10) + CHAR(9) + CASE WHEN Param40 IS NULL THEN '' ELSE Param40 + ', ' END
FROM SqlText