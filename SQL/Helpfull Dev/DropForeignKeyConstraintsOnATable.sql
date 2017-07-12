-- =====================================================================================
-- dROP ALL FORIEGN KEY CONSTRAINS ON A TABLE
-- =====================================================================================

select 'ALTER TABLE ' + object_name(fk.parent_object_id) + ' DROP CONSTRAINT ' + fk.name 
from sys.foreign_keys fk 
where OBJECT_NAME(fk.referenced_object_id) = 'PATIENT'
	OR OBJECT_NAME(fk.referenced_object_id) = 'ADDRESS'


truncate table patient
truncate table address


