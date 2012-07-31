redis = require("redis")
keys = require("./keys")
auth = require("../auth/auth")
validate = require("../validate/validate")

client = redis.createClient()

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		if not user
			res.json({}, 401)
			return

		options = [
			["cluster", "integer"]
			["benchmark_date", "datetime"]
			["cores", "integer"]
			["gpu_cores", "integer"]
			["rmax", "char"]
			["rpeak", "char"]
			["nmax", "char"]
			["nhalf", "char"]
			["compiler_name", "char"]
			["compiler_options", "char"]
			["math_library", "char"]
			["mpi_library", "char"]
			["hpl_input", "text"]
			["hpl_output", "text"]
		]

		data = validate.validate(options, req.body)

		if not data
			res.json({}, 400)
			return

		cluster = data.cluster

		delete data.cluster

		client.INCR keys.linpack_key, (error, id) ->
			if error
				res.json({}, 500)
				return

			client.HMSET keys.linpack(id), data, (error) ->
				if error
					res.json({}, 500)
					return

				client.APPEND keys.linpacks(cluster), id, (error) ->
					if error
						res.json({}, 500)
					else
						res.json({}, 200)

exports.show = (req, res) ->

	options = [
		["linpack", "integer"]
	]

	data = validate.validate(options, req.params)

	client.HGETALL keys.linpack(data.linpack), (error, data) ->
		if error
			res.json({}, 500)
		else
			res.json(data, 200)
