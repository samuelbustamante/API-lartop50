var redis = require("redis");
var client = redis.createClient();

exports.show = function(req, res) {

	// VALIDATE
	req.assert('activate').len(32, 32);
	req.assert('activate').isAlphanumeric();

	var errors = req.validationErrors(true);

	if(errors) {
		res.json({ error: errors }, 500);	
		return;
	}

	var key = req.params.activate;

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
