var utcStartTime = new Date(new Date('June 12, 2019 10:30:00').toISOString());
var utcEndTime   = new Date(new Date("June 12, 2019 11:00:00").toISOString());

db.getCollection('LogEntityV1').find( {
    $and : [
        { "CreatedDateTime"  : { $gt  : utcStartTime } }
      , { "CreatedDateTime"  : { $lte : utcEndTime } }
      , { "LogCategory"      : 1 }                                       // Audit = 1, Warning = 2, History = 3, Error = 4
      //, { "ExceptionMessage" : /.*The EXECUTE permission*/ }           // case sensitive LIKE (select * from x where ex like '*foo*')
      //, { "ExceptionMessage" : { $not: /.*The EXECUTE permission*/ } } // case sensitive NOT LIKE (select * from x where ex not like '*foo*')
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