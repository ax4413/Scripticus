Create FUNCTION dbo.GetAge (@DOB datetime, @Today Datetime) RETURNS Int
AS
Begin
Declare @Age As Int
Set @Age = Year(@Today) - Year(@DOB)
If Month(@Today) < Month(@DOB)
Set @Age = @Age -1
If Month(@Today) = Month(@DOB) and Day(@Today) < Day(@DOB)
Set @Age = @Age - 1
Return @AGE
End
