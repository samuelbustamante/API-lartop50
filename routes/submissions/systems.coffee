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
		req.assert("name", "Este campo es requerido.").notEmpty()
		req.assert("status", "Este campo es requerido.").notEmpty()
		req.assert("area", "Este campo es requerido.").notEmpty()
		req.assert("description", "Este campo es requerido.").notEmpty()
		req.assert("vendor", "Este campo es requerido.").notEmpty()
		req.assert("installation", "Este campo es requerido.").notEmpty()
		req.assert("installation", "Este campo es de tipo entero.").isInt()
		req.assert("installation", "Este campo es de longitud 4.").len(4)

		# CENTER
		req.assert("center", "Este campo es requerido.").notEmpty()
		req.assert("center", "Este campo es de tipo entero").isInt()

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

			# ENCODE HTML
			req.sanitize("name").xss()
			req.sanitize("name").entityEncode()
			req.sanitize("status").xss()
			req.sanitize("status").entityEncode()
			req.sanitize("area").xss()
			req.sanitize("area").entityEncode()
			req.sanitize("description").xss()
			req.sanitize("description").entityEncode()
			req.sanitize("vendor").xss()
			req.sanitize("vendor").entityEncode()

			# VALID PARAMETERS
			center = req.body.center
			data =
				id: id
				name: req.body.name
				status: req.body.status
				area: req.body.area
				description: req.body.description
				vendor: req.body.vendor
				installation: req.body.installation

			redis.client.HMSET keys.system_description(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				redis.client.SADD keys.center_systems(center), id, (error) ->
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

		redis.client.SISMEMBER keys.user_systems(user), system, (error, member) ->
			# NOT THE OWNER
			if not member
				res.json({ message: "system not found" }, 404)
				return

			redis.client.HGETALL keys.system_description(system), (error, description) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				# NOT SYSTEM
				if not description
					res.json({ message: "system not found" }, 404)
					return

				redis.client.SMEMBERS keys.system_components(system), (error, components) ->

					cmds = []

					for component in components
						cmds.push(['HGETALL', keys.component_description(component)])

					redis.client.multi(cmds).exec (error, replies) ->
						if error
							res.json({ message: "internal error" }, 500)
							return

						redis.client.GET keys.system_linpack(system), (error, id) ->
							if error
								res.json({ message: "internal error" }, 500)
								return

							redis.client.HGETALL keys.linpack_description(id), (error, linpack) ->
								if error
									res.json({ message: "internal error" }, 500)
									return

								data =
									description: description
									components: replies
									linpack: linpack

								res.json({ message: "success", data: data }, 200)
