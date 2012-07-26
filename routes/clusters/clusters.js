var redis = require("redis");
var auth = require("../auth/auth");

var client = redis.createClient(), multi;

exports.create = function(req, res) {
	auth.is_authenticated(req, function(user) {
		if(user) {

			// VALIDATE
			req.assert('url').isUrl();
			req.assert('name').notEmpty();
			req.assert('acronym').notEmpty();
			req.assert('segment').notEmpty();
			req.assert('description').notEmpty();
			req.assert('city').notEmpty();
			req.assert('state').notEmpty();
			req.assert('country').notEmpty();

			var errors = req.validationErrors(true);

			if(errors) {
				res.json({ error: errors }, 500);	
				return;
			}

			var data = {
				url: req.body.url,
				name: req.body.name,
				acronym: req.body.acronym,
				segmant: req.body.segmant,
				description: req.body.description,
				city: req.body.city,
				state: req.body.state,
				country: req.body.country,
			};

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
	req.assert('cluster').isNumeric();

	var errors = req.validationErrors(true);

	if(errors) {
		res.json({ error: errors }, 500);	
		return;
	}

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
