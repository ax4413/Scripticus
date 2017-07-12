/*
I broke this out as a separate example but it's the
same situation as before.
Here I'm adding an IF EXISTS clause to make the script
more resiliant, but I'm also showing another way to 
deal with the issue where the table names have different
chars in them.

1. Just add DROP TABLE to the front of each line.
   That should be fairly easy by this time.
   Search for: ^
   Replace with: DROP TABLE  -- ends with a space.

2. Now, that may not be good enough cause you may want to
   put square brackets around object names so they're
   in the [schema].[table] format.
   Search for: {.+}\.{.+}
   Replace with: -- \1.\2\nIf Exists (Select 1 from sys.objects where schema_name(schema_id) = '\1' and name = '\2')\nBEGIN\nDROP TABLE \[\1\].\[\2\];\nEND\nGO\n

   Here, the ".+" is used.  The "." means any single 
   char.  You can use this if you trust all the table names
   and you just want to script to do what it's told and
   not try to be too smart. This method also handles
   spaces in the names as the "." handles all chars
   except line break.
*/

dbo.Event
dbo.ClientDeviceNotification
dbo.ItemE1xtraProperty
dbo.ItemSubItem1
dbo.ClientDevice
dbo.EventInstance
dbo.ItemKeyword
dbo.FriendFinderSessionLocation
dbo.EventLocation
dbo.EventInstanceArchive
dbo.SpreadsheetColumnValue
dbo.Image
dbo.Location
dbo.ClientDeviceLocation
dbo.FriendFinderSession
dbo.LocationItem
dbo.Keyword
dbo._InternalLinks_ItemsToUpdate
dbo._LocationItem_copiedID_createdID
dbo.AppDomainSetting
dbo.EventDayOfWeek
dbo.SurveyResponseSession
dbo.SurveyResponse
dbo.ClientAppFavorite
dbo.SurveyAnswer
dbo._InternalLinks_ItemsUpdateParsed
dbo.SponsorAdInstanceAppDomain
dbo.SurveyQuestion
dbo.DeviceMessage
