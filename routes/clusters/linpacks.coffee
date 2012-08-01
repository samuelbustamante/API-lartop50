redis = require("redis")
keys = require("./keys")
auth = require("../auth/auth")

client = redis.createClient()

exports.create = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		#VALIDATORS
		req.assert("title").notEmpty()
		req.assert("benchmark_date").isDate()
		req.assert("cores").isInt()
		req.assert("gpu_cores").isInt()
		req.assert("rmax").isFloat()
		req.assert("rpeak").isFloat()
		req.assert("nmax").isInt()
		req.assert("nhalf").isInt()
		req.assert("compiler_name").notEmpty()
		req.assert("compiler_options").notEmpty()
		req.assert("math_library").notEmpty()
		req.assert("mpi_library").notEmpty()
		req.assert("hpl_input").notEmpty()
		req.assert("hpl_output").notEmpty()
		# ID CLUSTER
		req.assert("cluster").isInt()

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
		cluster = req.body.cluster
		data =
			title: req.body.title
			benchmark_date: req.body.benchmark_date
			cores: req.body.cores
			gpu_cores: req.body.gpu_cores
			rmax: req.body.rmax
			rpeak: req.body.rpeak
			nmax: req.body.nmax
			nhalf: req.body.nhalf
			compiler_name: req.body.compiler_name
			compiler_options: req.body.compiler_options
			math_library: req.body.math_library
			mpi_library : req.body.mpi_library
			hpl_input : req.body.hpl_input
			hpl_output : req.body.hpl_output

		client.INCR keys.linpack_key, (error, id) ->
			if error
				res.json({ message: "internal error" }, 500)
				return

			client.HMSET keys.linpack_description(id), data, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				client.SET keys.cluster_linpack(cluster), id, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
					else
						res.json({ message: "linpack created successful" }, 200)

exports.show = (req, res) ->

	req.assert("linpack").isInt()

	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS
	linpack = req.params.linpack

	client.HGETALL keys.linpack_description(linpack), (error, data) ->
		if error
			res.json({ message: "internal error" }, 500)

		# LINPACK NOT FOUND
		if not data
			res.json({ message: "linpack not found" }, 404)
		else
			res.json(data, 200)
