--DROP PROCEDURE  GetErrorInfoString
--DROP PROCEDURE  GetErrorInfo
--DROP PROCEDURE ERRORHANDELINGTEST

CREATE PROCEDURE GetErrorInfo
AS
SELECT
	DB_NAME() AS DatabaseName
    ,ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
GO


CREATE PROCEDURE GetErrorInfoString(@msg varchar(500) OUTPUT, @severity int OUTPUT, @state int OUTPUT)
AS
SELECT @msg = 'DB Name: '  + DB_NAME() + 
', Sproc Name: ' + ERROR_PROCEDURE() +
		', Err No: ' + CAST(ERROR_NUMBER() AS VARCHAR(5)) + 
		', Err Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(5)) +
		', Err State: ' + CAST(ERROR_STATE() AS VARCHAR(5)) + 
		', Err Line: ' + CAST(ERROR_LINE() AS VARCHAR(5)) +
		', Err Msg: ' + ERROR_MESSAGE()
		, @severity = ERROR_SEVERITY()
		, @state = ERROR_STATE()

--SELECT @msg = 'ERROR_LINE', @severity=15, @state = 15
GO

--CREATE PROCEDURE DeleteMe
--AS
--	delete Product where ProductID ='C440CDA0-ACBE-48FB-AC6D-9659175DB1CD'
--GO

CREATE PROCEDURE ErrorHandelingTest
AS

DECLARE @ErrMsg VARCHAR(500);
DECLARE @ErrSeverity INT;
DECLARE @State INT;

-- SET XACT_ABORT ON will cause the transaction to be uncommittable
-- when the constraint violation occurs. 
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;
        -- A FOREIGN KEY constraint exists on this table. This 
        -- statement will generate a constraint violation error.
        EXEC DeleteMe

    -- If the DELETE statement succeeds, commit the transaction.
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Execute error retrieval routine.
    EXECUTE GetErrorInfoString @ErrMsg OUTPUT, @ErrSeverity OUTPUT, @State OUTPUT
		-- Test XACT_STATE:
        -- If 1, the transaction is committable.
        -- If -1, the transaction is uncommittable and should 
        --     be rolled back.
        -- XACT_STATE = 0 means that there is no transaction and
        --     a commit or rollback operation would generate an error.
		
    -- Test whether the transaction is uncommittable.
    IF (XACT_STATE()) = -1
    BEGIN
        PRINT
            N'The transaction is in an uncommittable state. ' +
            'Rolling back transaction.'
        
            
        ROLLBACK TRANSACTION;
        RAISERROR(@ErrMsg, @ErrSeverity, @State)
    END;

    -- Test whether the transaction is committable.
    IF (XACT_STATE()) = 1
    BEGIN
        PRINT
            N'The transaction is committable. ' +
            'Committing transaction.'
        COMMIT TRANSACTION;   
    END;
END CATCH;
GO

gO


EXEC ErrorHandelingTest