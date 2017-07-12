
-- ===  Yes we can do that but there is a better way
SELECT  @@VERSION


-- ===  Build a temp table that we can insert into and use computed columns
CREATE TABLE #CheckVersion (
    version nvarchar(128),
    common_version AS SUBSTRING(version, 1, CHARINDEX('.', version) + 1 ),
    major AS PARSENAME(CONVERT(VARCHAR(32), version), 4),
    minor AS PARSENAME(CONVERT(VARCHAR(32), version), 3),
    build AS PARSENAME(CONVERT(varchar(32), version), 2),
    revision AS PARSENAME(CONVERT(VARCHAR(32), version), 1)
);

INSERT INTO #CheckVersion (version)
    SELECT CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)) ;

SELECT * FROM #CheckVersion