keys = require("./keys")
auth = require("../auth/auth")
redis = require("../redis/client")

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		req.assert("system", "Este campo es requerido.").notEmpty()
		req.assert("system", "Este campo es de tipo entero.").isInt()
		# COMPONENT
		req.assert("name", "Este campo es requerido.").notEmpty()
		req.assert("model", "Este campo es requerido.").notEmpty()
		req.assert("vendor", "Este campo es requerido.").notEmpty()
		req.assert("nodes", "Este campo es requerido.").notEmpty()
		req.assert("nodes", "Este campo es de tipo entero.").isInt()
		req.assert("memory_node", "Este campo es requerido.").notEmpty()
		req.assert("memory_node", "Este campo es de tipo entero.").isInt()
		# PROCESSOR
		req.assert("processor_name", "Este campo es requerido.").notEmpty()
		req.assert("processor_model", "Este campo es requerido.").notEmpty()
		req.assert("processor_socket", "Este campo es requerido.").notEmpty()
		req.assert("processor_socket", "Este campo es de tipo entero.").isInt()
		req.assert("processor_cores", "Este campo es requerido.").notEmpty()
		req.assert("processor_cores", "Este campo es de tipo entero.").isInt()
		req.assert("processor_speed", "Este campo es requerido.").notEmpty()
		req.assert("processor_speed", "Este campo es de tipo decimal.").isDecimal()
		# ACCELERATOR
		req.assert("accelerator_name", "Este campo es requerido.").notEmpty()
		req.assert("accelerator_model", "Este campo es requerido.").notEmpty()
		req.assert("accelerator_number", "Este campo es requerido.").notEmpty()
		req.assert("accelerator_number", "Este campo es de tipo entero.").isInt()
		req.assert("accelerator_cores", "Este campo es requerido.").notEmpty()
		req.assert("accelerator_cores", "Este campo es de tipo entero.").isInt()
		req.assert("accelerator_speed", "Este campo es requerido.").notEmpty()
		req.assert("accelerator_speed", "Este campo es de tipo decimal.").isDecimal()
		# POWER
		req.assert("peak_power", "Este campo es requerido.").notEmpty()
		req.assert("peak_power", "Este campo es de tipo decimal.").isDecimal()
		req.assert("measured_power", "Este campo es requerido.").notEmpty()
		req.assert("measured_power", "Este campo es de tipo decimal.").isDecimal()
		# CONFIGURATION
		req.assert("interconection", "Este campo es requerido.").notEmpty()
		req.assert("operating_system", "Este campo es requerido.").notEmpty()


		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		# VALID PARAMETERS

		req.sanitize("name").xss()
		req.sanitize("name").entityEncode()
		req.sanitize("model").xss()
		req.sanitize("model").entityEncode()
		req.sanitize("vendor").xss()
		req.sanitize("vendor").entityEncode()
		req.sanitize("processor_name").xss()
		req.sanitize("processor_name").entityEncode()
		req.sanitize("processor_model").xss()
		req.sanitize("processor_model").entityEncode()
		req.sanitize("accelerator_name").xss()
		req.sanitize("accelerator_name").entityEncode()
		req.sanitize("accelerator_model").xss()
		req.sanitize("accelerator_model").entityEncode()
		req.sanitize("interconection").xss()
		req.sanitize("interconection").entityEncode()
		req.sanitize("operating_system").xss()
		req.sanitize("operating_system").entityEncode()

		system = req.body.system

		data =
			# COMPONENT
			name: req.body.name
			model: req.body.model
			vendor: req.body.vendor
			nodes: req.body.nodes
			memory_node: req.body.memory_node
			# PROCESSOR
			processor_name: req.body.processor_name
			processor_model: req.body.processor_model
			processor_socket: req.body.processor_socket
			processor_cores: req.body.processor_cores
			processor_speed: req.body.processor_speed
			# ACCELERATOR
			accelerator_name: req.body.accelerator_name
			accelerator_model: req.body.accelerator_model
			accelerator_number: req.body.accelerator_number
			accelerator_cores: req.body.accelerator_cores
			accelerator_speed: req.body.accelerator_speed
			# CONFIGURATION
			interconection: req.body.interconection
			operating_system: req.body.operating_system


		redis.client.INCR keys.component_key, (error, id) ->

			if error
				res.json({ message: "internal error" }, 500)
				return

			redis.client.HMSET keys.component_description(id), data, (error) ->

				if error
					res.json({ message: "internal error" }, 500)
					return

				redis.client.SADD keys.system_components(system), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
					else
						res.json({ message: "component created successful", data: data }, 200)


exports.show = (req, res) ->

	req.assert("component").isInt()

	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS

	component = req.params.component

	redis.client.HGETALL keys.component_description(component), (error, data) ->
		# ERROR
		if error
			res.json({ message: "internal error" }, 500)

		# COMPONENT NOT FOUND
		if not data
			res.json({ message: "component not found" }, 404)
		else
			res.json(data, 200)
