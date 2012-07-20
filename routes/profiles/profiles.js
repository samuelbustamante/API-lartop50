var redis = require("redis");
var client = redis.createClient(), multi;

exports.index = function(req, res) {
	client.SMEMBERS('users:active', function(err, members) {
		if(err) {
			res.json('ERROR');
		} else {
			var i, cmds = [];

			for(i in members) {
				cmds.push(['HGETALL', 'uid:' + members[i] + ':profile']);
			}
			client.multi(cmds).exec(function(err, replies) {
				if(err) {
					res.json('ERROR');
				} else {
					res.json(replies);
				}
			});
		}
	});
};
