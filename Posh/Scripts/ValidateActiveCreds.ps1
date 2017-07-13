# http://www.powershellmagazine.com/2015/09/04/pstip-validate-active-directory-credentials/

  # add type to allow validating credentials
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
  # Create the Domain Context for authentication
$ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
  # We specify Negotiate as the Context option as it takes care of choosing the
  # best authentication mechanism i.e. Kerberos or NTLM (non-domain joined machines).
$ContextOptions = [System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate


  # Let’s create the instance of the PrinicipalContext class by using one of the
  # Constructor . Note this requires a DC name to be passed. Don’t worry if you
  # don’t know the DC name, we can easily use the $env:USERDNSDOMAIN environment
  # variable and it takes care of it.
$PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ContextType, $env:USERDNSDOMAIN)


  # We use the second method definition now to validate the user credential,
  # and we can store the user credentials in a credential object (for ease) here.
$Cred = Get-Credential
$PrincipalContext.ValidateCredentials($cred.UserName, $cred.GetNetworkCredential().password, $ContextOptions)
