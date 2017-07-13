Start-Process -FilePath "C:\Program Files (x86)\Robomongo\Robomongo.exe"

Start-Process -FilePath C:\mongodb\bin\mongod.exe

sleep 2

Start-Process -FilePath C:\mongodb\bin\mongo.exe