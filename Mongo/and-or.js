db.getCollection('LogEntityV1').find( 
    {
        $and  : [
            { "Message"  : { $not : /^System Availability.*/  } } ,
            {
                $or : [
                    { "Message"          : {'$regex': "payment", $options: 'i'} } ,
                    { "MessageExtended"  : {'$regex': "payment", $options: 'i'} } ,
                    { "ExceptionMessage" : {'$regex': "payment", $options: 'i'} }
                ]
            }
        ] 
    } ,
    {   "_id" : 0 ,
        "CreatedDateTime" : 1,
        "SourceMachine":1,
        "LogCategory":1,
        "Message":1,
        "MessageExtended":1,
        "ExceptionMessage":1,
        "StackTrace":1 
    } 
)