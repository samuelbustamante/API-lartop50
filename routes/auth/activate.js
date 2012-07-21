var redis = require("redis");
var client = redis.createClient();

exports.show = function(req, res) {
	key = req.params.activate;

	// CHECK CODE
	client.GET('lartop50:key:' + key + ':uid', function(err, uid) {
		if(err || !uid) {
			res.json('ERROR');
		} else {
			// ACTIVATE
			client.SADD('lartop50:users:active', uid, function(err) {
				if(err) {
					res.json('ERROR');
				} else {
					client.DEL('lartop50:key:' + key + ':uid', function(err) {
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
