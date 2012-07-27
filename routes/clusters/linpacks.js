var redis = require("redis");
var auth = require("../auth/auth");

var client = redis.createClient(), multi;

exports.create = function(req, res) {
	auth.is_authenticated(req, function(user) {
		if(user) {
			var cluster = req.body.cluster;
			var data = req.body.data;

			client.INCR('lartop50:linpack', function(err, id) {
				client.HMSET('lartop50:linpack:' + id, data, function(err) {
					client.APPEND('lartop50:cluster:' + cluster + ':linpack', id, function(err) {
						res.json('OK');
					});
				});
			});
		} else {
			res.json({ error: 'not authenticated' });
		}
	});
};

exports.show = function(req, res) {
	var id = req.params.linpack;

	client.HGETALL('lartop50:linpack:' + id, function(err, data) {
		res.json(data);
	});
};
