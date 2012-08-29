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

		#VALIDATORS
		req.assert("benchmark_date", "Este campo es requerido.").notEmpty()
		req.assert("benchmark_date", "Este campo es una fecha.").isDate()
		req.assert("cores", "Este campo es requerido.").notEmpty()
		req.assert("cores", "Este campo es un entero.").isInt()
		req.assert("gpu_cores", "Este campo es requerido.").notEmpty()
		req.assert("gpu_cores", "Este campo es un entero.").isInt()
		req.assert("rmax", "Este campo es requerido.").notEmpty()
		req.assert("rmax", "Este campo es de tipo decimal.").isDecimal()
		req.assert("rpeak", "Este campo es requerido.").notEmpty()
		req.assert("rpeak", "Este campo es de tipo decimal.").isDecimal()
		req.assert("nmax", "Este campo es requerido.").notEmpty()
		req.assert("nmax", "este campo es de tipo decimal.").isDecimal()
		req.assert("nhalf", "Este campo es requerido.").notEmpty()
		req.assert("nhalf", "Este campo es de tipo decimal.").isDecimal()
		req.assert("compiler_name", "Este campo es requerido.").notEmpty()
		req.assert("compiler_options", "Este campo es requerido.").notEmpty()
		req.assert("math_library", "Este campo es requerido.").notEmpty()
		req.assert("mpi_library", "Este campo es requerido.").notEmpty()
		req.assert("hpl_input", "Este campo es requerido.").notEmpty()
		req.assert("hpl_output", "Este campo es requerido.").notEmpty()
		# ID SYSTEM
		req.assert("system", "Este campo es requerido.").notEmpty()
		req.assert("system", "Este campo es de tipo entero.").isInt()

		# VALIDATE PARAMETERS
		errors = req.validationErrors()

		# INVALID PARAMETERS
		if errors
			res.json({ message: "invalid parameters", errors: errors }, 400)
			return

		# SYSTEM
		system = req.body.system

		redis.client.EXISTS keys.system_linpack(system), (error,  exist)->
			if error
				res.json({ message: "internal error" }, 500)
				return

			if exist
				res.json({ message: "linpack already been created"}, 403)
				return

			redis.client.INCR keys.linpack_key, (error, id) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				# VALID ENCODE HTML
				req.sanitize("compiler_name").xss()
				req.sanitize("compiler_name").entityEncode()
				req.sanitize("compiler_options").xss()
				req.sanitize("compiler_options").entityEncode()
				req.sanitize("math_library").xss()
				req.sanitize("math_library").entityEncode()
				req.sanitize("mpi_library").xss()
				req.sanitize("mpi_library").entityEncode()
				req.sanitize("hpl_input").xss()
				req.sanitize("hpl_input").entityEncode()
				req.sanitize("hpl_output").xss()
				req.sanitize("hpl_output").entityEncode()

				# VALID PARAMETERS
				data =
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

				redis.client.HMSET keys.linpack_description(id), data, (error) ->
					if error
						res.json({ message: "internal error" }, 500)
						return

					redis.client.SET keys.system_linpack(system), id, (error) ->
						if error
							res.json({ message: "internal error" }, 500)
						else
							res.json({ message: "linpack created successful", data: data }, 200)
	
########## SHOW ##########
	
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

	redis.client.HGETALL keys.linpack_description(linpack), (error, data) ->
		if error
			res.json({ message: "internal error" }, 500)

		# LINPACK NOT FOUND
		if not data
			res.json({ message: "linpack not found" }, 404)
		else
			res.json(data, 200)
