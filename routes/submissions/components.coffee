keys = require("./keys")
auth = require("../auth/auth")
redis = require("../redis/client")

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		req.assert("system").notEmpty()
		req.assert("name").notEmpty()
		req.assert("model").notEmpty()
		req.assert("vendor").notEmpty()
		req.assert("nodes").notEmpty()
		req.assert("memory_node").notEmpty()
		req.assert("processor_name").notEmpty()
		req.assert("processor_model").notEmpty()
		req.assert("processor_socket").notEmpty()
		req.assert("processor_cores").notEmpty()
		req.assert("processor_speed").notEmpty()
		req.assert("accelerator_name").notEmpty()
		req.assert("accelerator_model").notEmpty()
		req.assert("accelerator_number").notEmpty()
		req.assert("accelerator_cores").notEmpty()
		req.assert("accelerator_speed").notEmpty()
		req.assert("primary_interconection").notEmpty()
		req.assert("primary_operating_system").notEmpty()


		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		# VALID PARAMETERS

		system = req.body.system

		data =
			name: req.body.name
			model: req.body.model
			vendor: req.body.vendor
			nodes: req.body.nodes
			memory_node: req.body.memory_node

			processor_name: req.body.processor_name
			processor_model: req.body.processor_model
			processor_socket: req.body.processor_socket
			processor_cores: req.body.processor_cores
			processor_speed: req.body.processor_speed

			accelerator_name: req.body.accelerator_name
			accelerator_model: req.body.accelerator_model
			accelerator_number: req.body.accelerator_number
			accelerator_cores: req.body.accelerator_cores
			accelerator_speed: req.body.accelerator_speed

			primary_interconection: req.body.primary_interconection
			primary_operating_system: req.body.primary_operating_system


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
