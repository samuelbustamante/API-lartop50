var redis = require("redis");
var client = redis.createClient();

exports.show = function(req, res) {
	key = req.params.activate;

	// CHECK CODE
	client.GET('key:' + key + ':uid', function(err, uid) {
		if(err || !uid) {
			res.json('ERROR');
		} else {
			// ACTIVATE
			client.SADD('users:active', uid, function(err) {
				if(err) {
					res.json('ERROR');
				} else {
					client.DEL('key:' + key + ':uid', function(err) {
						if(err) {
							console.log('key is not deleted');
						}
						res.json('OK');
					});
				}
			});
		}
	});
};
