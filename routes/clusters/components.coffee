redis = require("redis")
keys = require("./keys")
auth = require("../auth/auth")
validate = require("../validate/validate")

client = redis.createClient()

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json(401)
			return

		options = [
			["cluster", "integer"]
			["name", "char"]
			["model", "char"]
			["vendor", "char"]
			["nodes", "integer"]
			["processor_name", "char"]
			["processor_model", "char"]
			["processor_socket", "char"]
			["processor_cores", "integer"]
			["processor_speed", "char"]
			["accelerator_name", "char"]
			["accelerator_model", "char"]
			["accelerator_number", "integer"]
			["accelerator_cores", "integer"]
			["accelerator_speed", "char"]
			["primary_operatingsystem", "char"]
			["primary_interconecton", "char"]
			["memory_node", "integer"] # IN MB
		]

		data = validate.validate(options, req.body)

		# INVALID DATA
		if not data
			res.json(400)
			return

		cluster = data.cluster

		delete data.cluster

		client.INCR keys.component_key, (error, id) ->

			if error
				res.json(500)
				return

			client.HMSET keys.component(id), data, (error) ->

				if error
					res.json(500)
					return

				client.SADD keys.components(cluster), id, (error) ->
					if error
						res.json(500)
					else
						res.json(200)


exports.show = (req, res) ->

	options = [
		["component", "integer"]
	]

	data = validate.validate(options, req.params)

	if not data
		res.json(400)
		return

	client.HGETALL keys.component(data.component), (error, data) ->
		if error
			res.json(500)
		else
			res.json(data)
