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
		req.assert("status").notEmpty()
		req.assert("area").notEmpty()
		req.assert("description").notEmpty()
		req.assert("vendor").notEmpty()
		req.assert("initiation").isDate()
		# ID CENTER
		req.assert("center").isInt()

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		redis.client.INCR keys.system_key(), (error, id) ->
			if error
				res.json({ message: "internal error" }, 500)
				return

			# VALID PARAMETERS
			system = req.body.system
			data =
				id: id
				name: req.body.name
				status: req.body.status
				area: req.body.area
				description: req.body.description
				vendor: req.body.vendor
				initiation: req.body.initiation

			redis.client.HMSET keys.system_description(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				redis.client.SADD keys.system_centers(system), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
						return

					redis.client.SADD keys.user_systems(user), id, (error) ->
						if error
							res.json({ message: "internal error" }, 500)
						else
							res.json({ message: "system created successful" , data: data}, 200)


########## SHOW ##########

exports.show = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		# VALIDATORS
		req.assert("system").isInt()

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid system", errors: errors }, 400)
			return

		# VALID PARAMETERS
		system = req.params.system

		redis.client.SISMEMBER keys.user_systems(user), center, (error, member) ->
			# NOT THE OWNER
			if not member
				res.json({ message: "center not found" }, 404)
				return

			redis.client.HGETALL keys.system_description(system), (error, description) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				# NOT SYSTEM
				if not description
					res.json({ message: "system not found" }, 404)
					return
				else
					res.json(description, 200)

				redis.client.SMEMBERS keys.system_components(system), (error, components) ->

					cmds = []

					for component in components
						cmds.push(['HGETALL', keys.component_description(component)])

					redis.client.multi(cmds).exec (error, replies) ->
						if error
							res.json({ message: "internal error" }, 500)
							return

						data =
							description: description
							components: replies

						res.json({ message: "success", data: data }, 200)
