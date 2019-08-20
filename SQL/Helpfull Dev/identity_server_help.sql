
/*
  SELECT * FROM Client

  vapi        = 1
  client_cred = 2
  vmtradeup   = 3

  secret      = K7gNU3sdo+OL0wNhqoVWhr3g6s1xYv72ol/pe/Unols=
*/
DECLARE @client INT = 3

SELECT  [Client] = c.Id
      , c.Enabled
      , c.ClientId
      , c.ClientName
      , c.ClientUri
      , c.LogoUri
      , c.RequireConsent
      , c.AllowRememberConsent
      , c.AllowAccessTokensViaBrowser
      , c.Flow
      , [Flow Desc]= CASE c.Flow WHEN 0 THEN 'AuthorizationCode'
                                 WHEN 1 THEN 'Implicit'
                                 WHEN 2 THEN 'Hybrid'
                                 WHEN 3 THEN 'ClientCredentials'
                                 WHEN 4 THEN 'ResourceOwner'
                                 WHEN 5 THEN 'Custom'
                                 WHEN 6 THEN 'AuthorizationCodeWithProofKey'
                                 WHEN 7 THEN 'HybridWithProofKey'
                                 ELSE 'n/a' END
      , c.AllowClientCredentialsOnly
      , c.LogoutUri
      , c.LogoutSessionRequired
      , c.RequireSignOutPrompt
      , c.AllowAccessToAllScopes
      , c.IdentityTokenLifetime
      , c.AccessTokenLifetime
      , c.AuthorizationCodeLifetime
      , c.AbsoluteRefreshTokenLifetime
      , c.SlidingRefreshTokenLifetime
      , c.RefreshTokenUsage
      , c.UpdateAccessTokenOnRefresh
      , c.RefreshTokenExpiration
      , c.AccessTokenType
      , c.EnableLocalLogin
      , c.IncludeJwtId
      , c.AlwaysSendClientClaims
      , c.PrefixClientClaims
      , c.AllowAccessToAllGrantTypes
FROM    Client c
WHERE   ( @client IS NULL OR Id = @client )


SELECT  [Client Secret] = Id, * 
FROM    clientsecret 
WHERE   ( @client IS NULL OR Client_Id = @client )


SELECT  [Client Scope]                            = cs.id
      , [Scope Name]                              = s.Name
      , [Scope Description]                       = s.Description
      , [Scope is Required]                       = s.Required
      , [Scope Emphasize]                         = s.Emphasize
      , [ScopeType]                               = CASE s.Type WHEN 1 THEN 'Identity' WHEN 2 THEN 'Resource' END
      , [Scope Include All Claims]                = s.IncludeAllClaimsForUser
      , [Scope Claim Rule]                        = s.ClaimsRule
      , [Scope Show In Discovery]                 = s.ShowInDiscoveryDocument
      , [Scope Allow Unrestricetd Introsepction]  = s.AllowUnrestrictedIntrospection  
      , [Scope Secret Id]                         = ss.Id 
      , [Scope Secret Type]                       = ss.Type
      , [Scope Secret Value]                      = ss.Value
FROM    ClientScope cs
        INNER JOIN Scope s on s.Id = cs.Scope_Id
        LEFT OUTER JOIN ScopeSecret ss ON ss.Scope_Id = s.Id
WHERE   ( @client IS NULL OR Client_Id = @client )


SELECT  [Client Claim] = id, * 
FROM    ClientClaim 
WHERE   ( @client IS NULL OR Client_Id = @client )


SELECT  [Client Redirect Uri] = id, * 
FROM    ClientRedirectUri
WHERE   ( @client IS NULL OR Client_Id = @client )


SELECT  [Client post Logout Redirect Uri] = id, * 
FROM    ClientPostLogoutRedirectUri
WHERE   ( @client IS NULL OR Client_Id = @client )

SELECT  [Client Cors Origin] = id, * 
FROM    ClientCorsOrigin
WHERE   ( @client IS NULL OR Client_Id = @client )





SELECT  [Scope] = s.Id, *  
FROM    Scope s
        LEFT OUTER JOIN ScopeSecret ss
                ON ss.Scope_Id = s.Id




/*
declare @secret varchar(1000) = 'K7gNU3sdo+OL0wNhqoVWhr3g6s1xYv72ol/pe/Unols='
                                 
update ScopeSecret
  set  Value = @secret
where  value = '{secret}'

update ClientSecret
  set  Value = @secret
where  value = '{secret}'

declare @hostname varchar(1000) = 'http://localhost:3000'

update ClientCorsOrigin
   set Origin = REPLACE(Origin, '{hostname}', @hostname)

update ClientPostLogoutRedirectUri
   set uri = REPLACE(uri, '{hostname}', @hostname)

update ClientRedirectUri
   set uri = REPLACE(uri, '{hostname}', @hostname)
*/