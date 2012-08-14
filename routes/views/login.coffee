redis = require("redis")
auth = require("../auth/auth")

client = redis.createClient()

exports.index = (req, res) ->
	auth.is_authenticated req, (user) ->

		if user
			res.redirect('/')
			return

		res.render('login')
