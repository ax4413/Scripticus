INSERT INTO [Image](ImageData)
  SELECT * FROM OPENROWSET(BULK N'C:\antibiotic_16_hot.png', SINGLE_BLOB) AS BLOB


-- get file size on disk
SELECT MAX(datalength(pic)) AS FileSizeBytes FROM picture
SELECT AVG(datalength(pic)) AS FileSizeBytes FROM picture