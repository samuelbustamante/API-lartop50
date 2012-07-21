var redis = require("redis");
var auth = require("../auth/auth");

var client = redis.createClient(), multi;

exports.create = function(req, res) {
	auth.is_authenticated(req, function(user) {
		if(user) {
			var cluster = req.body.cluster;
			var data = req.body.data;

			client.INCR('components', function(err, id) {
				client.HMSET('component:' + id + ':description', data, function(err) {
					client.SADD('cluster:' + cluster + ':components', id, function(err) {
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
	var id = req.params.component;

	client.HGETALL('component:' + id + ':description', function(err, data) {
		res.json(data);
	});
};
