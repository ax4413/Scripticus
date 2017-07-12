DECLARE @startIndex as integer
    SET @startIndex = 20
DECLARE @count as integer
    SET @count = 20

SELECT  *
FROM (  SELECT ROW_NUMBER() OVER (ORDER BY id) rownum, *
        FROM sysobjects  ) ranked
WHERE   rownum BETWEEN @startIndex + 1
  AND   @startIndex + @count
ORDER BY rownum

-- =======================================================================================

WITH bob as(
	SELECT  ROW_NUMBER() over(order by t1.PatientID, t1.ClinicDate, t1.RightLeft) RowNumber,
  	      t1.PatientID, t1.ClinicDate, t1.RightLeft, t1.ImageDateTime, t1.FileName,
          t1.FileSize, t1.BackedUp, t1.FileType, t1.DateOfTest, t2.BranchId,
          t2.BranchName, t2.FTPBasePath, t2.LocalBasePath, t2.ErrorImage,
          t2.ClinicalImageLocalSplitString, t2.FundusImageLocalSplitString,
          t2.ClinicalImageFTPSplitString, t2.FundusImageFTPSplitString, t2.ClinicaDataDBPath,
          t2.F77DataDBPath, t2.Active, t2.FundusDirectory
	FROM    DATAClinicalImageEyeFundus t1
          INNER JOIN BranchImageInfo t2
                  ON t1.BranchID = t2.BranchID
)

SELECT  PatientID, ClinicDate, RightLeft, ImageDateTime,
        [FileName], FileSize, BackedUp, FileType, DateOfTest,
        BranchId, BranchName, FTPBasePath, LocalBasePath, ErrorImage,
        ClinicalImageLocalSplitString, FundusImageLocalSplitString, ClinicalImageFTPSplitString,
        FundusImageFTPSplitString, ClinicaDataDBPath, F77DataDBPath, Active, FundusDirectory
FROM    bob
WHERE   RowNumber between 0
  AND   1000

-- =======================================================================================

SELECT  *
FROM    TableX
ORDER BY FieldX
OFFSET 501 ROWS
FETCH NEXT 100 ROWS ONLY