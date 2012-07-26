var redis = require("redis");
var auth = require("../auth/auth");

var client = redis.createClient(), multi;

exports.update = function(req, res) {
	auth.is_authenticated(req, function(user) {
		if(user) {
			var data = req.body.data;

			client.HMSET('lartop50:uid:' + user + ':profile', data, function(err) {
				if(err) {
					res.json({ error: 'not saved' });
				} else {
					res.json({ sucess: 'ok' });
				}
			});
		} else {
			res.json({ error: 'not authenticated' });
		}
	});
};

exports.index = function(req, res) {
	client.SMEMBERS('lartop50:users:active', function(err, members) {
		if(err) {
			res.json('ERROR');
		} else {
			var i, cmds = [];

			for(i in members) {
				cmds.push(['HGETALL', 'lartop50:uid:' + members[i] + ':profile']);
			}
			client.multi(cmds).exec(function(err, replies) {
				if(err) {
					res.json({ error: 'not results' });
				} else {
					res.json(replies);
				}
			});
		}
	});
};
