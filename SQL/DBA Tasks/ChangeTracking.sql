--  ADD CHANGE TRACKING TO THE DB
ALTER DATABASE @DBName SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON)


-- ADD CHANGE TRACKING TO EACH TABLE 
DECLARE @SQL VARCHAR(MAX)  

SELECT @SQL = STUFF(        
(        
      SELECT DISTINCT ' ALTER TABLE [' + NAME + '] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);'    
      FROM(    
            SELECT NAME
            FROM SYS.TABLES T
            JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC ON TC.TABLE_NAME = T.NAME
            JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE C ON C.TABLE_NAME = TC.TABLE_NAME AND C.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
            WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
            ) J       
      FOR XML PATH('')        
      ), 1, 1, '');    
      
EXEC(@SQL)
-----------------------------------------------------------------------------------------------------------------------------------

-- REMOVE CHANGE TRACKING FROM EACH TABLE 
DECLARE @SQL VARCHAR(MAX)  

SELECT @SQL = STUFF(        
(        
       SELECT ' ALTER TABLE [' + NAME + '] DISABLE CHANGE_TRACKING ;'    
       FROM(    
              SELECT NAME
              FROM SYS.TABLES T
              JOIN SYS.CHANGE_TRACKING_TABLES TT ON TT.OBJECT_ID = T.OBJECT_ID
              ) J    
              ORDER BY NAME    
       FOR XML PATH('')        
       ), 1, 1, '');    
       
EXEC(@SQL)  


-- REMOVE CHANGE TRACKING FROM THE DB
ALTER DATABASE @DBName SET CHANGE_TRACKING = OFF