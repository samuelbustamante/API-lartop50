auth = require("../auth/auth")
keys_auth = require("../auth/keys")
keys_clusters = require("../clusters/keys")

# REDIS
redis = require("redis")
client = redis.createClient()
client['Multi'] = client.multi()

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

		client.HGETALL keys_auth.profile(user), (error, profile) ->
			# ERROR
			if error
				res.end('internal error', 500)

			client.SMEMBERS keys_clusters.user_projects(user), (error, members) ->

				cmds = []

				for member in members
					cmds.push(['HGETALL', keys_clusters.project_description(member)])

				client.multi(cmds).exec (error, projects) ->

					if(isEmpty(projects))
						projects = null

					res.render('index', { profile: profile, centers: projects })
