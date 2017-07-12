/*
Drop the tables in this table list.
We can do this a couple ways.

1. Just add DROP TABLE to the front of each line.
   That should be fairly easy by this time.
   Search for: ^
   Replace with: DROP TABLE  -- ends with a space.

2. Now, that may not be good enough cause you may want to
   put square brackets around object names so they're
   in the [schema].[table] format.
   Search for: {:a+}\.{:a+}
   Replace with: [\1\].[\2\]

   The problem with this approach is that it doesn't handle
   "_" and probably not numbers either.  
   There are a couple ways you can deal with this.
   You can deal with exceptions manually, or add to the
   current syntax to cover most of the exceptions,
   or you can switch from :a to :i.
   :i is the c++ identifier and is shorthand for the expression ([a-zA-Z_$][a-zA-Z0-9_$]*).
   This search can take a few more seconds though.
3. Of course you can always combine these steps to do it all in one pass.
   Search for: {:i+}\.{:i+}
   Replace with: DROP TABLE [\1].[\2]\nGO 
   I even added a GO just to be complete.

**** A good deal of this can actually be done w/o regex.
	 If you Alt+select dbo you can replace it with
	 "DROP TABLE dbo". Of course if you still want the 
	 [] then you're back in the same boat you were in
	 at the beginning at 001-Alt.sql.
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
