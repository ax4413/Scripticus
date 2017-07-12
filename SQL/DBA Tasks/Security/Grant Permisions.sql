-- ===  See which permisions you have
SELECT  name,
        has_perms_by_name(name, 'OBJECT', 'EXECUTE') as has_execute,
        has_perms_by_name(name, 'OBJECT', 'VIEW DEFINITION') as has_view_definition
FROM    sys.procedures


-- ===  See which permisions the user ReportsSTG has
EXECUTE AS user = 'ReportsSTG'
    SELECT SUSER_NAME(), USER_NAME();
    SELECT  name,
            has_perms_by_name(name, 'OBJECT', 'EXECUTE') as has_execute,
            has_perms_by_name(name, 'OBJECT', 'VIEW DEFINITION') as has_view_definition
    FROM    sys.procedures
REVERT;


-- ===  Grant the missing execute permisions to user ReportsSTG
GRANT EXECUTE ON OBJECT::dbo.usp_invoicingPoints
    TO ReportsSTG;
GO