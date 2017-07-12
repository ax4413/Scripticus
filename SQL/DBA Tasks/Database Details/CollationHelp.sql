
/* get the collation of a specified database */
DECLARE @DBName varchar(150) = 'OECentral2008';
SELECT DATABASEPROPERTYEX(@DBName, 'Collation') SQLCollation;

/* Function to provide further infomation on databse collation */
SELECT * FROM fn_helpcollations()