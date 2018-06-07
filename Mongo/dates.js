// Simple search 
db.VirginMediaApplicationEntityV1
  .find( { "ApplicationRef":/100000042463006/ } )

 
 
// Simple search with projection
db.VirginMediaApplicationEntityV1
  .find( { "ApplicationRef":/100000042463006/ } ,
	     { "ApplicationRef": 1 } )  
  

  
// Simple search for NOT equal to with projection and sorting
db.getCollection('LogEntityV1')
  .find( { SourceProcess: { $not: { $eq: "Icenet.Service.Soundwave" } } } ,
         { SourceProcess: 1, Message: 1, CreatedDateTime: 1, UpdatedDateTime: 1, _id: 0 } )
  .sort( { CreatedDateTime : -1 } )

  
  
// Use a js date object.
// This is automatically cast to a UTC representation
var d1 = new Date("February 05, 2018 10:00:00");
var d2 = new Date("February 05, 2018 11:00:00");

db.getCollection('LogEntityV1').find( {
    $and : [
        { "CreatedDateTime" : { $gte : d1 } }
      , { "CreatedDateTime" : { $lt  : d2 } }
	  //, {"_id" : "e002d735-8865-426d-9d79-c13eaac106c2"}
      //, { "LogCategory" : 1 } // Audit = 1, Warning = 2, History = 3, Error = 4
      //, { "ExceptionMessage" : /.*Failure calling SatisfyCheckistCondition*/ }
    ]}
    // projection
    , { "_id" : 0 ,
        "CreatedDateTime" : 1,
        "LogCategory":1,
        "Message":1,
        "MessageExtended":1,
        "ExceptionMessage":1        
    }
).sort({CreatedDateTime : -1 })




// Group by date and count instances ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var d1 = new Date("January 01, 2016 00:00:00");
var d2 = new Date("January 02, 2017 00:00:00");

db.getCollection('LogEntityV1').aggregate( [
    { $match: { $and : [ { "CreatedDateTime" : { $gte : d1 } }
                       , { "CreatedDateTime" : { $lt  : d2 } } ] } } ,
    { "$group": { "_id": {  "year":       { "$year":       "$CreatedDateTime" } ,
                            "month":      { "$month":      "$CreatedDateTime" } ,
                            "dayOfMonth": { "$dayOfMonth": "$CreatedDateTime" } } ,
                "count": { "$sum": 1 } } }
] )



