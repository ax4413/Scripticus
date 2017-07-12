/*
Downloaded files often have too many spaces in them.
Remove the extra blank lines:

Search for: ^:Wh     -- :Wh is the ssms version of all whitespace.
Replace with:       --don't put anything in this field.

*/


ALTER PROCEDURE [dbo].[CounterDataGet]


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


			AND (


					CD.CounterDateTime >= @StartDateTime


				)





			AND	(	


					CD.CounterDateTime <= @EndDateTime


				)








    --ORDER BY CounterDateTime ,CounterName


             OPTION(RECOMPILE);


END