redis = require("redis")
keys = require("./keys")
auth = require("../auth/auth")

client = redis.createClient()
client['Multi'] = client.multi()

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		# VALIDATORS
		req.assert("name").notEmpty()
		req.assert("acronym").notEmpty()
		req.assert("status").notEmpty()
		req.assert("segment").notEmpty()
		req.assert("area").notEmpty()
		req.assert("description").notEmpty()
		req.assert("provider").notEmpty()
		req.assert("initiation").notEmpty()
		req.assert("url").notEmpty().isUrl()
		req.assert("country").notEmpty()
		req.assert("state").notEmpty()
		req.assert("city").notEmpty()

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		# VALID PARAMETERS
		data =
			name: req.body.name
			acronym: req.body.acronym
			status: req.body.status
			segment: req.body.segment
			area: req.body.area
			description: req.body.description
			provider: req.body.provider
			initiation: req.body.initiation
			url: req.body.url
			country: req.body.country
			state: req.body.state
			city: req.body.city

		client.INCR keys.cluster_key(), (error, id) ->
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
