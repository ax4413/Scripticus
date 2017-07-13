Utility scripts for setting up a GDFC environment.
Large chunks could be used for other environments.

See [greendeal.md](greendeal.md) for how to set up a Greendeal environment.

BuildUtils.psm1 

- Invoke-Build
- Invoke-EnsureNugetV2Feed (because some packages aren't in the now default v3)

IISUtils.psm1

- Get-SitePath
- Get-AppPoolPath

IOUtils.psm1

- Invoke-EnsureFolderExists

VSUtils.psm1

- Invoke-RepointIISUrl
- Invoke-RepointProject