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

  
  
// Use a js date object. (cast the local date to a UTC date)
var utcStartTime = new Date(new Date('November 05, 2018 11:00:00').toISOString());
var utcEndTime   = new Date(new Date("November 05, 2018 11:30:00").toISOString());

db.getCollection('LogEntityV1').find( {
    $and : [
        { "CreatedDateTime" : { $gt  : utcStartTime } }
      , { "CreatedDateTime" : { $lte : utcEndTime } }
      , { "LogCategory" : 1 } // Audit = 1, Warning = 2, History = 3, Error = 4
      //, { "ExceptionMessage" : /.*Failure calling SatisfyCheckistCondition*/ }
      //, {"_id" : "e002d735-8865-426d-9d79-c13eaac106c2"}
    ]}
    // projection
    , { "_id" : 0 ,
        "CreatedDateTime" : 1,
        "SourceMachine":1,
        "LogCategory":1,
        "Message":1,
        "MessageExtended":1,
        "ExceptionMessage":1,
        "StackTrace":1 
    }  
).sort({CreatedDateTime : -1 })




// Group by date and count instances ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

var utcStartTime = new Date(new Date('November 01, 2018 11:00:00').toISOString());
var utcEndTime   = new Date(new Date("November 31, 2018 11:30:00").toISOString());

db.getCollection('LogEntityV1').aggregate( [
    { $match: { $and : [ { "CreatedDateTime" : { $gte : utcStartTime } }
                       , { "CreatedDateTime" : { $lt  : utcEndTime } } ] } } ,
    { "$group": { "_id": {  "year":       { "$year":       "$CreatedDateTime" } ,
                            "month":      { "$month":      "$CreatedDateTime" } ,
                            "dayOfMonth": { "$dayOfMonth": "$CreatedDateTime" } } ,
                "count": { "$sum": 1 } } }
] )



