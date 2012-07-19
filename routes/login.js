var md5 = require('MD5');
var redis = require("redis");
var client = redis.createClient();

exports.create = function(req, res) {
	var email = req.body.email;
	var pass = req.body.pass;

	//CHECK
	client.GET('user:' + email + ':id', function(err, id) {
		if(err || !id) {
			res.json('ERROR');
		} else {
			client.GET('uid:' + id + ':activated', function(err, activated) {
				if(err || (activated == "false")) {
					res.json('ERROR');
				} else {
					client.GET('uid:' + id + ':pass', function(err, realpass) {
						if(md5(pass) === realpass) {
							// REVISE
							req.session.auth = id;
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
