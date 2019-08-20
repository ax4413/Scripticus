use [OakbrookMainPRD]

-- === event notification
SELECT  *
      , casted_message_body = CASE message_type_name WHEN 'X' 
                                THEN CAST(message_body AS NVARCHAR(MAX)) 
                                ELSE message_body 
                              END 
FROM    [TrackingNotificationQueue] WITH(NOLOCK)



-- ===  Our messages 
SELECT  *
      , casted_message_body = CASE message_type_name WHEN 'X' 
                                THEN CAST(message_body AS NVARCHAR(MAX)) 
                                ELSE message_body 
                              END 
FROM    [TrackingRequestQueue] WITH(NOLOCK)



-- ===  ?
SELECT  *
      , casted_message_body = CASE message_type_name WHEN 'X' 
                                THEN CAST(message_body AS NVARCHAR(MAX)) 
                                ELSE message_body 
                              END 
FROM    [TrackingResponseQueue] WITH(NOLOCK)



-- ===  System queues
SELECT  count(*)
FROM  [dbo].[EventNotificationErrorsQueue] WITH(NOLOCK)

SELECT  count(*)
FROM [dbo].[QueryNotificationErrorsQueue] WITH(NOLOCK)

SELECT  count(*)
FROM [dbo].[ServiceBrokerQueue] WITH(NOLOCK)


﻿<EVENT_INSTANCE>
  <EventType>QUEUE_ACTIVATION</EventType>
  <PostTime>2016-09-08T10:01:06.363</PostTime>
  <SPID>30</SPID>
  <ServerName>505249-SSCLUPR\PROD</ServerName>
  <LoginName>sa</LoginName>
  <UserName>dbo</UserName>
  <DatabaseName>OakbrookMainPRD</DatabaseName>
  <SchemaName>dbo</SchemaName>
  <ObjectName>TrackingRequestQueue</ObjectName>
  <ObjectType>QUEUE</ObjectType>
</EVENT_INSTANCE>