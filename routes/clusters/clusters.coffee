redis = require("redis")
keys = require("./keys")
auth = require("../auth/auth")
validate = require("../validate/validate")

client = redis.createClient()
client['Multi'] = client.multi()

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		options = [
			["url", "url"]
			["name", "alphanumeric"]
			["acronym", "char"]
			["segment", "char"]
			["description", "text"]
			["city", "char"]
			["state", "char"]
			["country", "char"]
		]

		data = validate.validate(options, req.body)

		# INVALID PARAMETERS
		if not data
			res.json({ message: "invalida parameters" }, 400)
			return

		client.INCR keys.key(), (error, id) ->
			if error
				res.json({ message: "internal error" }, 500)
				return

			client.HMSET keys.cluster(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				client.SADD keys.clusters(user), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
					else
						res.json({ message: "cluster created successful" }, 200)


exports.show = (req, res) ->

	options = [
		["cluster", "integer"]
	]

	data = validate.validate(options, req.params)

	if not data
		res.json({ message: "invalid cluster" }, 400)
		return

	client.HGETALL keys.cluster(data.cluster), (error, description) ->
		if error
			res.json({ message: "internal error" }, 500)
			return

		# NOT CLUSTER
		if not description
			res.json({ message: "cluster not found" }, 404)
			return

		client.SMEMBERS keys.components(data.cluster), (error, components) ->

			cmds = []

			for component in components
				cmds.push(['HGETALL', keys.component(component)])

			client.multi(cmds).exec (error, replies) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				res.json({ description: description, components: replies }, 200)
