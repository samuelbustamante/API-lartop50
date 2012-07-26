var md5 = require('MD5');
var redis = require("redis");
var client = redis.createClient();

exports.create = function(req, res) {

	// VALIDATE
	req.assert('email').isEmail();
	req.assert('pass').len(6, 64);

	var errors = req.validationErrors(true);

	if(errors) {
		res.json({ error: errors }, 500);	
		return;
	}

	var email = req.body.email;
	var pass = req.body.pass;

	//CHECK
	client.GET('lartop50:user:' + email + ':id', function(err, id) {
		if(err || !id) {
			res.json('ERROR');
		} else {
			client.SISMEMBER('lartop50:users:active', id, function(err, member) {
				if(err || !member) {
					res.json('ERROR');
				} else {
					client.GET('lartop50:uid:' + id + ':pass', function(err, realpass) {
						if(md5(pass) === realpass) {
							// REVISE
							req.session.auth.id = id;
							res.json('OK');
						} else {
							res.json('ERROR');
						}
					});
				}
			});
		}
	});
};
