/*
Often times a regex session like this will be 
semi-manual.  You can't expect everything to be done in
a single pass or even in a single regex line.  This 
is a good example of just using it to help you with your
everyday tasks like turning a create table into an
insert SP.
Here are the steps we're going to follow:
1. Create the create SP text.
2. Copy the columns as the input params by copying them.
3. Get rid of the [] in the SP params and replace with @.
   It doesn't require regex actually.
4. Now it's time to get rid of the data types. So copy
   The new params under the INSERT line (after you write it)
   And run the following regex.
   Search for: {\@:a+}(:b\[*:a+\]*:b*(\(:z+|:a+\))*)
   Replace with: \1

Explain: the {} captures the specific text.  In this case we're getting the var name.
	\@ -- escapes to find the @.
	:a+ -- one or more chars… this is what we want to capture, the varname.
	:Wh:a+ -- a whitespace followed by any number of chars.  This is the data type we've just included.  You could put :Wh+:a+ if you had more than a single char between the var and the datatype.
	:Wh* -- gets none or more whitespace.  The datatype can be followed by any number of spaces before the ().  So we're testing for that now.  If it's not a datatype that takes anything after it then that's fine.
	(\(:z+\))*)) -- this one is tougher, but it's easy if you break it down.  We'll work our way from inside out.  :z+ is 1 or more numbers.  So we're trying to include the (50) part of varchar.  And since that's going to be enclosed in () then we need to include that and the () needs to be escaped  so that gives us \(:z+\)  
	Now that's got to be grouped together since it will always be inside the ().  So we add another set of () for the grouping.  That gives us (\(:z+\))
	Ok, so now we've included the (50) part of varchar(50), but what if it's an int or a bigint?  Currently, we're requiring it to have the (50) part of the datatype.  So we need to add a conditional part for the entire (50) group.  That gives us (\(:z+\))*
	Finally, we close off the datatype group with the closing ).

*/	

create table dbo.ServersOSDetail
(
[ID] int identity(1,1),
[InstanceID] int,
[ExecutionDateTime] datetime,
[FreePhysicalMemory] bigint,
[FreeSpaceInPagingFiles] bigint,
[FreeVirtualMemory] bigint,
[InstallDate] varchar(50),
[LastBootUpTime] varchar(50),
[MaxNumberOfProcesses] bigint,
[MaxProcessMemorySize] bigint,
[Name] varchar(500),
[NumberOfLicensedUsers] bigint,
[NumberOfProcesses] bigint,
[NumberOfUsers] bigint,
[OSArchitecture] varchar(50),
[OSLanguage] int,
[PAEEnabled] bit,
[SerialNumber] varchar(100),
[ServicePackMajorVersion int,
[ServicePackMinorVersion] int,
[SizeStoredInPagingFiles] bigint,
[Status] varchar(20),
[SystemDirectory] varchar(100),
[SystemDrive] varchar(5),
[TotalSwapSpaceSize] bigint,
[TotalVirtualMemorySize] bigint,
[TotalVisibleMemorySize] bigint,
[Version] varchar(20),
[WindowsDirectory] varchar(50)
)

CREATE PROCEDURE sp1
(

)

AS

INSERT MyTable
SELECT
