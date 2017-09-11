# Setting up a greendeal dev environment #

You will need: 

- Powershell 4

Run `./GD_Setup.ps1 –RootPath path\to\folder`
This will:

1. Checkout to the RootPath
1. Create 2 websites with appropriate application pools and applications GreenDealLHS (at lhs.green.local) & GreenDealRHS (at rhs.green.local)
1. Build (ensuring code analysis doesn’t cough over assembly versions and nuget just works™)
1. Repoint the IISUrl in various project files to not blat your current icenet applications when they load.

Once you’ve done all that, you’ll need to (in no particular order)

Add 2 new items to your hosts file:
 
- 127.0.0.1 lhs.green.local
- 127.0.0.1 rhs.green.local

Copy you some databases from the plain DEV ones:

-GreenDealApplicationDEV
-GreenDealDocumentsDEV
-GreenDealMainDEV
-GreenDealMembershipDEV

You’ll need to reset the support password

Open path\to\greendeal\src\Icenet - All Projects.sln

Do a global search for //localhost in *.config By and large it should be obvious which of lhs and rhs you need to repoint to.

Do a global search for ApplicationConfigLocation in *.config and repoint to your path/to/greendeal
 
Probably the easiest way of finding the database connection strings is doing a global search for mrobinson. Repoint as appropriate.
