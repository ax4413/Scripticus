/*
Here we're going to turn SP params into PS params for
a SQL call.
*/

CREATE PROCEDURE sp1
(
@InstanceID int,
@ExecutionDateTime datetime,
@FreePhysicalMemory bigint,
@FreeSpaceInPagingFiles bigint,
@FreeVirtualMemory bigint,
@InstallDate varchar(50),
@LastBootUpTime varchar(50),
@MaxNumberOfProcesses bigint,
@MaxProcessMemorySize bigint,
@Name varchar(500),
@NumberOfLicensedUsers bigint,
@NumberOfProcesses bigint,
@NumberOfUsers bigint,
@OSArchitecture varchar(50),
@OSLanguage int,
@PAEEnabled bit,
@SerialNumber varchar(100),
@ServicePackMajorVersion int,
@ServicePackMinorVersion int,
@SizeStoredInPagingFiles bigint,
@Status varchar(20),
@SystemDirectory varchar(100),
@SystemDrive varchar(5),
@TotalSwapSpaceSize bigint,
@TotalVirtualMemorySize bigint,
@TotalVisibleMemorySize bigint,
@Version varchar(20),
@WindowsDirectory varchar(50)
)

AS

INSERT MyTable
SELECT
@InstanceID,
@ExecutionDateTime,
@FreePhysicalMemory,
@FreeSpaceInPagingFiles,
@FreeVirtualMemory,
@InstallDate,
@LastBootUpTime,
@MaxNumberOfProcesses,
@MaxProcessMemorySize,
@Name,
@NumberOfLicensedUsers,
@NumberOfProcesses,
@NumberOfUsers,
@OSArchitecture,
@OSLanguage,
@PAEEnabled,
@SerialNumber,
@ServicePackMajorVersion,
@ServicePackMinorVersion,
@SizeStoredInPagingFiles,
@Status,
@SystemDirectory,
@SystemDrive,
@TotalSwapSpaceSize,
@TotalVirtualMemorySize,
@TotalVisibleMemorySize,
@Version,
@WindowsDirectory