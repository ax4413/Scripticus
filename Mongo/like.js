
// the $options: i makes this a case insensitive search
db.getCollection('ConfigurationEntityV1').find({"_id" : {'$regex': "useteststubs", $options: 'i'}})

// the _id searched for is iframe2\default but mongo stores it as iframe2\\default (escaping the backslash)
// and to use regex to query it we need to escape the double backslash thus '\\\\'
db.getCollection('ConfigurationEntityV1').find({"_id" : {'$regex': "iframe2\\\\Default", $options: 'i'}})
