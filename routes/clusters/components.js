var redis = require("redis");
var client = redis.createClient(), multi;

exports.create = function(req, res) {
	var cluster = req.body.cluster;
	var data = req.body.data;

	client.INCR('components', function(err, id) {
		client.HMSET('component:' + id + ':description', data, function(err) {
			client.SADD('cluster:' + cluster + ':components', id, function(err) {
				res.json('OK');
			});
		});
	});
};

exports.show = function(req, res) {
	var id = req.params.component;

	client.HGETALL('component:' + id + ':description', function(err, data) {
		res.json(data);
	});
};
