-- ===  Mechanisim to add extended properties


-- ===  Add a property to the database
EXEC sp_addextendedproperty 
@name = N'Purpose', 
@VALUE = 'Holds employee, customer, supplier, and order details for the company.';


-- ===  Add a property to a schema
EXECUTE sys.sp_addextendedproperty 
@name = N'Purpose',
@VALUE = N'Holds methods to manage the database.',
    @level0type = N'SCHEMA', 
    @level0name = 'Internal';


-- ===  Add a property to a table
EXECUTE sys.sp_addextendedproperty 
@name = N'Purpose',
@VALUE = N'Holds customer applications.',
    @level0type = N'SCHEMA', 
    @level0name = 'dbo', 
        @level1type = N'Table', 
        @level1name = 'Application';


-- ===  Add a property to a column
EXECUTE sys.sp_addextendedproperty 
@name = N'Purpose',
@VALUE = N'Holds the current primary status.',
    @level0type = N'SCHEMA', 
    @level0name = 'dbo', 
        @level1type = N'Table', 
        @level1name = 'Application',
            @level2type = 'Column', 
            @level2name = 'PrimaryStatusId';


/*
sp_addextendedproperty
    [ @name = ] { 'property_name' }
    [ , [ @VALUE = ] { 'value' } 
        [ , [ @level0type = ] { 'level0_object_type' } 
          , [ @level0name = ] { 'level0_object_name' } 
                [ , [ @level1type = ] { 'level1_object_type' } 
                  , [ @level1name = ] { 'level1_object_name' } 
                        [ , [ @level2type = ] { 'level2_object_type' } 
                          , [ @level2name = ] { 'level2_object_name' } 
                        ] 
                ]
        ] 
    ] 
[;]
*/