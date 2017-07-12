
/*
Here we got a list of DBs from one of the devs.  They want us to do any number of things to it.
- Take them offline.
- Turn into an IN stmt for a query.

SET OFFLINE
Do it is 2 passes
1st - Search for: ^
	- Replace with: ALTER DATABASE 
2nd - Search for $
	- Replace with SET OFFLINE\nGO

Doing it in a single pass is even cooler.  We'll come back and cover that later.
Search for: ^{(:a*_*:a*)}
Replace with: ALTER DATABASE \1 SET OFFLINE\nGO

CREATE and 'IN' STMT
1st - Search for: ^
	- Replace with: ' 
2nd - Search for $
	- Replace with: ',

Again, doing it in a single pass is cool.
Search for: ^{(:a*_*:a*)}
Replace with: '\1',
*/

HouseHold
CPAM
Recipe
ITBookworm
Evidence
ReportServer
ReportServerTempDB
WSS_Config
WSS_AdminContent
WSS_Content
TfsVersionControl
TfsActivityLogging
TfsBuild
TfsIntegration
TfsWorkItemTracking
TfsWorkItemTrackingAttachments
TfsWarehouse
NinjaReporting
CPAMdev
Minion
BF3
BF1
DB2
BF2
MidnightSQL
ReindexTest