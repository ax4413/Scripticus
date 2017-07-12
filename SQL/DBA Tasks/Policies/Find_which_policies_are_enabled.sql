-- =================================================================================================
--  Query the metadata to find the Policy, Condition, Target Set informations on our database
--  http://blog.sqlauthority.com/2015/04/15/sql-server-finding-what-policies-are-enabled-on-our-databases/
-- =================================================================================================
SELECT  p.policy_id,
        p.is_enabled,
        p.name AS 'policy_name',
        c.condition_id,
        c.name AS 'condition_name',
        c.expression AS 'condition_expression',
        ts.target_set_id,
        ts.TYPE,
        ts.type_skeleton,
        tsl.condition_id AS 'target_set_condition_id'
FROM    msdb.dbo.syspolicy_policies p
        INNER JOIN msdb.dbo.syspolicy_conditions c
                ON p.condition_id = c.condition_id
        INNER JOIN msdb.dbo.syspolicy_target_sets ts
                ON ts.object_set_id = p.object_set_id
        INNER JOIN msdb.dbo.syspolicy_target_set_levels tsl
                ON ts.target_set_id = tsl.target_set_id
-- WHERE p.is_enabled <> 0 -- Use this to get only enabled Policies on the DB