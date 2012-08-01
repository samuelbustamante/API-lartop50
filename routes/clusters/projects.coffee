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
		req.assert("segment").notEmpty()
		req.assert("description").notEmpty()
		req.assert("url").isUrl()
		req.assert("country").notEmpty()
		req.assert("state").notEmpty()
		req.assert("city").notEmpty()
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
		req.sanitize("description").xss() # !!! VERIFICAR !!!

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

		client.INCR keys.project_key(), (error, id) ->
			if error
				res.json({ message: "internal error" }, 500)
				return

			client.HMSET keys.project_description(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				client.SADD keys.user_projects(user), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
					else
						res.json({ message: "project created successful" }, 200)


exports.show = (req, res) ->

	req.assert("project").isInt()

	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS
	project = req.params.project

	client.HGETALL keys.project_description(project), (error, description) ->
		if error
			res.json({ message: "internal error" }, 500)
			return

		# PROJECT NOT FOUND
		if not description
			res.json({ message: "project not found" }, 404)
		else
			res.json(description, 200)
