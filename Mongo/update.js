
//https://docs.mongodb.com/manual/reference/method/db.collection.update/

db.ServiceRegistry.update(
  { "Name": "IdentityServerClientService2" },
  {
    $set: { 
        "Name" : "IdentityServerClientService" 
    }
  }
)