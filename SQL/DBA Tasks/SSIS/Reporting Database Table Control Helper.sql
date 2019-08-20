DECLARE @TableControlName VARCHAR(128) = 'Dialler_DCA'


SELECT  tc.*
FROM    TableControl tc
WHERE   (@TableControlName IS NULL OR tc.TableName = @TableControlName)
ORDER BY tc.TableName


SELECT  tc.TableName, tus.*
FROM    TableControl tc
        INNER JOIN TableUpdateSchedule tus
                ON TUS.TableControlId = TC.TableControlId
WHERE   (@TableControlName IS NULL OR tc.TableName = @TableControlName)
ORDER BY tc.TableName


SELECT  tc.TableName
      , tuh.*
      , uh.*
FROM    TableControl tc 
        INNER JOIN TableUpdateHistory tuh
                ON tuh.TableControlId = tc.TableControlId
        INNER JOIN UpdateHistory uh
                ON uh.UpdateHistoryId = tuh.UpdateHistoryid
WHERE   (@TableControlName IS NULL OR tc.TableName = @TableControlName)
ORDER BY tc.TableName, tuh.StartDate DESC, uh.StartDate DESC


SELECT  rc.*
FROM    dbo.ReportControl rc
        INNER JOIN dbo.TableControl tc
                ON tc.TableControlId = rc.TableControlId
WHERE   (@TableControlName IS NULL OR tc.TableName = @TableControlName)


SELECT  rch.*
FROM    dbo.ReportContentHistory rch
        INNER JOIN TableUpdateHistory tuh
                ON tuh.TableUpdateHistoryId = rch.TableUpdateHistoryId
        INNER JOIN TableControl tc 
                ON tuh.TableControlId = tc.TableControlId
WHERE   (@TableControlName IS NULL OR tc.TableName = @TableControlName)
ORDER BY rch.ReportContentHistoryId DESC  