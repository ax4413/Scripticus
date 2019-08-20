
// the $options: i makes this a case insensitive search
// select * from ConfigurationEntityV1 where id like 'useteststubs' 
db.getCollection('ConfigurationEntityV1').find({"_id" : {'$regex': "useteststubs", $options: 'i'}})


// uses a negative look ahead to perfom a NOT LIKE
// select * from ConfigurationEntityV1 where id not like 'useteststubs' 
db.getCollection('ConfigurationEntityV1').find( { "_id": { '$regex': "^((?!useteststubs).)*$", $options: 'i' } } )

// this options works better for NOT LIKE
// note this is case sensitive,  but can better used with other predicates in an AND clause
db.getCollection('ConfigurationEntityV1').find( { "_id": { $not : /^\\IceNet\\Services.*/ } } )



// the _id searched for is iframe2\default but mongo stores it as iframe2\\default (escaping the backslash)
// and to use regex to query it we need to escape the double backslash thus '\\\\'
// select * from ConfigurationEntityV1 where id like iframe2\\Default
db.getCollection('ConfigurationEntityV1').find({"_id" : {'$regex': "iframe2\\\\Default", $options: 'i'}})
