use master;
go

if db_id(N'Test') is not null
begin
  drop database [Test];
end;
go

create database [Test];
go

use [Test];
go

create schema [Schema];
go

create procedure [Schema].[HandleModuleFailure]
  @schema sysname,
  @module sysname
with execute as caller
as
begin
  declare @errorNumber int = error_number();
  declare @errorSeverity int = error_severity();
  declare @errorState int = error_state();
  declare @errorProcedure nvarchar(126) = isnull(error_procedure(), N'<Unknown>');
  declare @errorLine int = isnull(error_line(), 0);
  declare @errorMessage nvarchar(2048) = isnull(error_message(), N'');

  raiserror (N'Error: Module [%s].[%s] unexpectedly failed with error number %d, severity %d, state %d, at [%s], line %d with the message "%s".',
             16, 0,
             @schema,
             @module,
             @errorNumber,
             @errorSeverity,
             @errorState,
             @errorProcedure,
             @errorLine,
             @errorMessage)
            with log;
end;
go

ALTER PROCEDURE [Schema].[TestErrorHandling]
  @parameterError bit,
  @workError      bit
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Test for parameter errors.
	IF @parameterError = 1
	BEGIN
		RAISERROR(N'Parameter error.', 16, 0);
		RETURN -1;  -- Argument error code.
	END
	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @schema SYSNAME = SCHEMA_NAME();;
			DECLARE @module SYSNAME = OBJECT_NAME(@@PROCID);	
			DECLARE @hasOuterTransaction BIT = CASE WHEN @@TRANCOUNT > 0 THEN 1 ELSE 0 END;
			DECLARE @rollbackPoint NCHAR(32) = REPLACE(CONVERT(NCHAR(36), NEWID()), N'-', N'');

			IF @hasOuterTransaction = 1
			BEGIN
				SAVE TRANSACTION @rollbackPoint;
			END
			ELSE
			BEGIN
				BEGIN TRANSACTION @rollbackPoint;
			END;
			--END IF
			
			-- DO SOME WORK HERE.
			IF @workError = 1
			-- DO SOME WORK HERE.
			BEGIN
				RAISERROR(N'Work error.', 16, 0);
			END;
			--END IF
			
			IF @hasOuterTransaction = 0
			BEGIN
				COMMIT TRANSACTION;
			END;
			--END IF
		END TRY
		BEGIN CATCH
			IF XACT_STATE() = 1
			BEGIN
				ROLLBACK TRANSACTION @rollbackPoint;
			END;

			EXECUTE [Schema].[HandleModuleFailure] @schema, @module;

			RETURN -ERROR_NUMBER();
		END CATCH;
	END;
	--END IF
END;
GO

create table [Schema].[Table]
(
  [Id] int         identity not null primary key,
  [ParameterError] bit not null,
  [WorkError]      bit not null
);
go

create trigger [Schema].[Trigger] on [Schema].[Table]
  for insert
as
begin
  -- Test for errors.
  if exists (select * from inserted as I where I.[ParameterError] = 1)
  begin
    rollback transaction;

    raiserror(N'Parameter error.', 16, 0);

    return;
  end
  else
  begin
    begin try
      -- Do some work.
      if exists (select * from inserted as I where I.[WorkError] = 1)
      begin
        raiserror(N'Work error.', 16, 0);
      end;
    end try
    begin catch
      rollback transaction;
       
      execute [Schema].[HandleModuleFailure]
        @schema = N'Schema',
        @module = N'TestErrorHandling';

      return;
    end catch;
  end;
end;
go

-- Tests
-- Stored procedures
print N'Stored procedure tests.'
print N'-----------------------';
print N'';

print N'No outer transaction, no try-catch, no errors.';

declare @result int;

execute @result = [Schema].[TestErrorHandling]
  @parameterError = 0,
  @workError = 0;

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, no try-catch, parameter error.';

declare @result int;

execute @result = [Schema].[TestErrorHandling]
  @parameterError = 1,
  @workError = 0;

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, no try-catch, work error.';

declare @result int;

execute @result = [Schema].[TestErrorHandling]
  @parameterError = 0,
  @workError = 1;

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, no try-catch, no errors.';

declare @result int;

begin transaction;
  execute @result = [Schema].[TestErrorHandling]
    @parameterError = 0,
    @workError = 0;
commit transaction;

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, no try-catch, parameter error.';

declare @result int;

begin transaction;
  execute @result = [Schema].[TestErrorHandling]
    @parameterError = 1,
    @workError = 0;
commit transaction;

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, no try-catch, work error.';

declare @result int;

begin transaction;
  execute @result = [Schema].[TestErrorHandling]
    @parameterError = 0,
    @workError = 1;
commit transaction;

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, try-catch, no errors.';

declare @result int;

begin try
  execute @result = [Schema].[TestErrorHandling]
    @parameterError = 0,
    @workError = 0;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, try-catch, parameter error.';

declare @result int;

begin try
  execute @result = [Schema].[TestErrorHandling]
    @parameterError = 1,
    @workError = 0;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, try-catch, work error.';

declare @result int;

begin try
  execute @result = [Schema].[TestErrorHandling]
    @parameterError = 0,
    @workError = 1;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, try-catch, no errors.';

declare @result int;

begin try
  begin transaction;
    execute @result = [Schema].[TestErrorHandling]
      @parameterError = 0,
      @workError = 0;
  commit transaction;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, try-catch, parameter error.';

declare @result int;

begin try
  begin transaction;
    execute @result = [Schema].[TestErrorHandling]
      @parameterError = 1,
      @workError = 0;
  commit transaction;
end try
begin catch
  print N'Catch: ' + error_message();

  rollback transaction;
end catch

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, try-catch, work error.';

declare @result int;

begin try
  begin transaction;
    execute @result = [Schema].[TestErrorHandling]
      @parameterError = 0,
      @workError = 1;
  commit transaction;
end try
begin catch
  print N'Catch: ' + error_message();

  rollback transaction;
end catch

print N'Result: ' + isnull(convert(nvarchar(10), @result), N'null') + N'; Transaction count: ' + convert(nvarchar(10), @@trancount);
go

-- Triggers
print N'';
print N'Trigger tests.'
print N'--------------';
print N'';

print N'No outer transaction, no try-catch, no errors.';

insert into [Schema].[Table] ([ParameterError], [WorkError])
  values (0, 0);

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go


print N'';
print N'No outer transaction, no try-catch, parameter error.';

insert into [Schema].[Table] ([ParameterError], [WorkError])
  values (1, 0);

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, no try-catch, work error.';

insert into [Schema].[Table] ([ParameterError], [WorkError])
  values (0, 1);

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, no try-catch, no errors.';

begin transaction;
  insert into [Schema].[Table] ([ParameterError], [WorkError])
    values (0, 0);
commit transaction;

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, no try-catch, parameter error.';

begin transaction;
  insert into [Schema].[Table] ([ParameterError], [WorkError])
    values (1, 0);
commit transaction;

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, no try-catch, work error.';

begin transaction;
  insert into [Schema].[Table] ([ParameterError], [WorkError])
    values (0, 1);
commit transaction;

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, try-catch, no errors.';

begin try
  insert into [Schema].[Table] ([ParameterError], [WorkError])
    values (0, 0);
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, try-catch, parameter error.';

begin try
  insert into [Schema].[Table] ([ParameterError], [WorkError])
    values (1, 0);
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'No outer transaction, try-catch, work error.';

begin try
  insert into [Schema].[Table] ([ParameterError], [WorkError])
    values (0, 1);
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, try-catch, no errors.';

begin try
  begin transaction;
    insert into [Schema].[Table] ([ParameterError], [WorkError])
      values (0, 0);
  commit transaction;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, try-catch, parameter error.';

declare @result int;

begin try
  begin transaction;
    insert into [Schema].[Table] ([ParameterError], [WorkError])
      values (1, 0);
  commit transaction;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go

print N'';
print N'Outer transaction, try-catch, work error.';

declare @result int;

begin try
  begin transaction;
    insert into [Schema].[Table] ([ParameterError], [WorkError])
      values (0, 1);
  commit transaction;
end try
begin catch
  print N'Catch: ' + error_message();
end catch

print N'Transaction count: ' + convert(nvarchar(10), @@trancount);
go
