var redis = require("redis");
var auth = require("../auth/auth");

var client = redis.createClient(), multi;

exports.create = function(req, res) {
	auth.is_authenticated(req, function(user) {
		if(user) {
			var data = req.body.data;

			client.INCR('lartop50:clusters', function(err, id) {
				client.HMSET('lartop50:cluster:' + id + ':description', data, function(err) {
					client.SADD('lartop50:uid:' + user + ':clusters', id, function(err) {
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
	var id = req.params.cluster;

	client.HGETALL('lartop50:cluster:' + id + ':description', function(err, description) {
		client.SMEMBERS('lartop50:cluster:' + id + ':components', function(err, components) {
			var i, cmds = [];

			for(i in components) {
				cmds.push(['HGETALL', 'lartop50:component:' + components[i] + ':description']);
			}

			client.multi(cmds).exec(function(err, replies) {
				res.json({ description: description, components: replies });
			});
		});
	});
};
