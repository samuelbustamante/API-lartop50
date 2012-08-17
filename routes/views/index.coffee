auth = require("../auth/auth")
redis = require("../redis/client")
keys_auth = require("../auth/keys")
keys_submissions = require("../submissions/keys")

# AUXILIARY
isEmpty = (obj) ->
	response = true
	for i in obj
		response = false
	response

exports.index = (req, res) ->
	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.redirect('/ingresar')
			return

		redis.client.HGETALL keys_auth.profile(user), (error, profile) ->
			# ERROR
			if error
				res.end('internal error', 500)

			redis.client.SMEMBERS keys_submissions.user_centers(user), (error, members) ->

				cmds = []

				for member in members
					cmds.push(['HGETALL', keys_submissions.center_description(member)])

				redis.client.multi(cmds).exec (error, projects) ->

					if(isEmpty(projects))
						projects = null

					res.render('index', { profile: profile, centers: projects })
