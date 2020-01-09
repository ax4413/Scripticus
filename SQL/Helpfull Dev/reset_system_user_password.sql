update  systemuser 
   set  userpassword = '5BDCD3C0D4D24AE3E71B3B452A024C6324C7E4BB' -- support
      , Passwordlockeddate = null
      , InvalidLogonAttempts = 0
      , PasswordLastChangedDate = GetDate()+9999
      , IsPasswordResetRequired = 0
where username = 'support';