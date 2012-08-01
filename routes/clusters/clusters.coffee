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
		req.assert("status").notEmpty()
		req.assert("area").notEmpty()
		req.assert("description").notEmpty()
		req.assert("vendor").notEmpty()
		req.assert("initiation").isDate()
		# ID PROJECT
		req.assert("project").isInt()

		#######################
		#                     #
		# !!! REVIEW DATA !!! #
		#                     #
		#######################

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		# VALID PARAMETERS
		project = req.body.project
		data =
			name: req.body.name
			status: req.body.status
			area: req.body.area
			description: req.body.description
			vendor: req.body.vendor
			initiation: req.body.initiation

		client.INCR keys.cluster_key(), (error, id) ->
			if error
				res.json({ message: "internal error" }, 500)
				return

			client.HMSET keys.cluster_description(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				client.SADD keys.project_clusters(project), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
					else
						res.json({ message: "cluster created successful" }, 200)


exports.show = (req, res) ->

	# VALIDATORS
	req.assert("cluster").isInt()


	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS
	cluster = req.params.cluster

	client.HGETALL keys.cluster_description(cluster), (error, description) ->
		if error
			res.json({ message: "internal error" }, 500)
			return

		# NOT CLUSTER
		if not description
			res.json({ message: "cluster not found" }, 404)
			return
		else
			res.json(description, 200)

		###
		client.SMEMBERS keys.components(data.cluster), (error, components) ->

			cmds = []

			for component in components
				cmds.push(['HGETALL', keys.component(component)])

			client.multi(cmds).exec (error, replies) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				res.json({ description: description, components: replies }, 200)
		###
