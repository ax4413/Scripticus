
// search where application ref is not null and not starting with either x or X

//        and at least 1 element in the IcnetApplication array has and property equaling PrimaryStatus status


db.getCollection('VirginMediaApplicationEntityV1')
.find( { 
    
  $and : [
  
         { "ApplicationRef":{$ne:null} }, 
           { "ApplicationRef":{$not:/^x.*/} }, 
           { "ApplicationRef":{$not:/^X.*/} }, 
           { "IceNetApplications" : { $elemMatch : {"PrimaryStatus" : {$eq:1}}}}, 
           { "IceNetApplications" : { $elemMatch : {"SecondaryStatus" : {$eq:2}}}}

          ] 
} )


