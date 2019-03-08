db.getCollection('LogEntityV1')
  .find( { }, 
         { SourceProcess: 1,  
           CreatedDateTime: 1, 
           Message: 1,  
           ExceptionMessage: 1, 
           _id: 0 } )
  .sort( { 'CreatedDateTime':-1} )