var redis = require("redis");
var client = redis.createClient(), multi;

exports.create = function(req, res) {
	var data = req.body.data;
	var user = req.session.auth.id;

	client.INCR('clusters', function(err, id) {
		client.HMSET('cluster:' + id + ':description', data, function(err) {
			client.SADD('uid:' + user + ':clusters', id, function(err) {
				res.json('OK');
			});
		});
	});
};

exports.show = function(req, res) {
	var id = req.params.cluster;

	client.HGETALL('cluster:' + id + ':description', function(err, description) {
		client.SMEMBERS('cluster:' + id + ':components', function(err, components) {
			var i, cmds = [];

			for(i in components) {
				cmds.push(['HGETALL', 'component:' + components[i] + ':description']);
			}

			client.multi(cmds).exec(function(err, replies) {
				res.json({ description: description, components: replies });
			});
		});
	});
};
