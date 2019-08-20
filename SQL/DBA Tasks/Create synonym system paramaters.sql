
DECLARE @DocumentDatabase VARCHAR(128) = 'DVVanSYTrunkDocuments'
DECLARE @ExternalDatabase VARCHAR(128) = 'DVVanSYTrunkExternal'
DECLARE @AuditDatabase VARCHAR(128) = 'DVVanSYTrunkAudit'
DECLARE @IcemanDatabase   VARCHAR(128) = ''


-- ===  Create a documents db system paramater
DECLARE @DocumentDatabaseExists INT = 0
SELECT  @DocumentDatabaseExists = COUNT(*) FROM SystemParameter WHERE ParameterName = 'DocumentsDatabase'

IF (@DocumentDatabaseExists = 0) BEGIN
    INSERT INTO SystemParameter(ParameterName, ParameterValue)
        SELECT 'DocumentsDatabase', @DocumentDatabase
END
ELSE IF(@DocumentDatabaseExists = 1) BEGIN
    UPDATE  SystemParameter
       SET  ParameterValue = @DocumentDatabase
     WHERE  ParameterName = 'DocumentsDatabase'
END
ELSE BEGIN
    RAISERROR('There are %i copies of the system parameter DocumentsDatabase.',16,1,@DocumentDatabaseExists)
END


-- ===  Create a external db system paramater        
DECLARE @ExternalDatabaseExists INT = 0
SELECT  @ExternalDatabaseExists = COUNT(*) FROM SystemParameter WHERE ParameterName = 'ExternalDatabase'

IF (@ExternalDatabaseExists = 0) BEGIN
    INSERT INTO SystemParameter(ParameterName, ParameterValue)
        SELECT 'ExternalDatabase', @ExternalDatabase
END
ELSE IF(@ExternalDatabaseExists = 1) BEGIN
    UPDATE  SystemParameter
       SET  ParameterValue = @ExternalDatabase
     WHERE  ParameterName = 'ExternalDatabase'
END
ELSE BEGIN
    RAISERROR('There are %i copies of the system parameter ExternalDatabase.',16,1,@ExternalDatabaseExists)
END


-- ===  Create a external db system paramater        
DECLARE @AuditDatabaseExists INT = 0
SELECT  @AuditDatabaseExists = COUNT(*) FROM SystemParameter WHERE ParameterName = 'AuditDatabase'

IF (@AuditDatabaseExists = 0) BEGIN
    INSERT INTO SystemParameter(ParameterName, ParameterValue)
        SELECT 'AuditDatabase', @ExternalDatabase
END
ELSE IF(@ExternalDatabaseExists = 1) BEGIN
    UPDATE  SystemParameter
       SET  ParameterValue = @AuditDatabase
     WHERE  ParameterName = 'AuditDatabase'
END
ELSE BEGIN
    RAISERROR('There are %i copies of the system parameter AuditDatabase.',16,1,@AuditDatabaseExists)
END


-- ===  Create a iceman db system paramater
DECLARE @IcemanDatabaseExists INT = 0
SELECT  @IcemanDatabaseExists = COUNT(*) FROM SystemParameter WHERE ParameterName = 'IcemanDatabase'

IF (@IcemanDatabaseExists = 0) BEGIN
    INSERT INTO SystemParameter(ParameterName, ParameterValue)
        SELECT 'IcemanDatabase', @IcemanDatabase
END
ELSE IF(@IcemanDatabaseExists = 1) BEGIN
    UPDATE  SystemParameter
       SET  ParameterValue = @IcemanDatabase
     WHERE  ParameterName = 'IcemanDatabase'
END
ELSE BEGIN
    RAISERROR('There are %i copies of the system parameter IcemanDatabase.',16,1,@IcemanDatabaseExists)
END


-- ===  Validation
SELECT  SystemParameterId, ParameterName, ParameterValue 
FROM    SystemParameter
WHERE   ParameterName LIKE '%database%'



-- ===  Create the synonyms
CREATE SYNONYM [dbo].[BankDetailsSYN] FOR [Build_3_8_External]..[iscddata]

CREATE SYNONYM [dbo].[TemplateSYN] FOR [BPFDocumentsDev_TB]..[Template]


