/*
    Delete dupplicate lens and lens extras from specs lens lens extra.
    This only works if you dont mind which record gets deleted

    1)  Create table of distinct dupplicates plus additional column for dupplicate primary key
    2)  Update the table by joining back to the dupplicates.
        Only one of the dupplicates primary keys can be applied to the distinct table primary key
    3)  Delete from dupplicates based on primary key in distinct table
*/

BEGIN Tran

  CREATE TABLE #distinct(SpecsLensLensExtraID UniqueIdentifier,
                         SpecsLensproductID uniqueidentifier,
                         LensExtraProductID uniqueidentifier);


  INSERT INTO #DISTINCT (SpecsLensproductID, LensExtraProductID)
    SELECT  DISTINCT SpecsLensProductID,
            LensExtraProductID
    FROM    SpecsLensLensExtra slle
    WHERE   slle.LensExtraProductID IN ('07BA64F6-D8BF-480F-8F86-576F125C72B0')
    ORDER BY  pecsLensProductID

  UPDATE  #DISTINCT
     SET  SpecsLensLensExtraID = t2.SpecsLensLensExtraID
    FROM  #DISTINCT t1
          INNER JOIN (  SELECT  *
                        FROM    SpecsLensLensExtra
                        WHERE   LensExtraProductID IN ('07BA64F6-D8BF-480F-8F86-576F125C72B0') ) t2
                  ON t1.SpecsLensproductID = t2.SpecsLensProductID
                  AND t1.LensExtraProductID = t2.LensExtraProductID

  DELETE  SpecsLensLensExtra
  FROM    SpecsLensLensExtra slle
          INNER JOIN #DISTINCT d
                  ON slle.SpecsLensLensExtraID = d.SpecsLensLensExtraID

COMMIT Tran