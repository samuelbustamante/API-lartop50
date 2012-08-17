keys = require("./keys")
auth = require("../auth/auth")
redis = require("../redis/client")

########## CREATE ##########

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
		req.assert("country").notEmpty()
		req.assert("city").notEmpty()
		req.assert("url").isUrl()
		req.assert("description").notEmpty()

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		# VALID PARAMETERS
		req.sanitize("description").xss() # !!! VERIFICAR !!!

		redis.client.INCR keys.center_key(), (error, id) ->

			data =
				id: id
				name: req.body.name
				acronym: req.body.acronym
				segment: req.body.segment
				country: req.body.country
				city: req.body.city
				url: req.body.url
				description: req.body.description

			if error
				res.json({ message: "internal error" }, 500)
				return

			redis.client.HMSET keys.center_description(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				redis.client.SADD keys.user_centers(user), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
					else
						res.json({ message: "center created successful" , data: data}, 200)

########## SHOW ##########

exports.show = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		# VALIDATORS
		req.assert("center").isInt()

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid id" }, 400)
			return

		# VALID PARAMETERS
		center = req.params.center

		redis.client.SISMEMBER keys.user_centers(user), center, (error, member) ->
			# NOT THE OWNER
			if not member
				res.json({ message: "center not found" }, 404)
				return

			redis.client.HGETALL keys.center_description(center), (error, description) ->
				# ERROR
				if error
					res.json({ message: "internal error" }, 500)
					return

				# PROJECT NOT FOUND
				if not description
					res.json({ message: "center not found" }, 404)
					return

					client.SMEMBERS keys.center_systems(center), (error, systems) ->

						cmds = []

						for system in systems
							cmds.push(['HGETALL', keys.system_description(system)])

						redis.client.multi(cmds).exec (error, replies) ->
							# ERROR
							if error
								res.json({ message: "internal error" }, 500)
							else
								data =
									description: description
									systems: systems

								res.json({ message: "successfull", data: data }, 200)
