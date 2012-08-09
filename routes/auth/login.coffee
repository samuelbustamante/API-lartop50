md5 = require("MD5")
auth = require("./auth")
keys = require("./keys")
redis = require("redis")

client = redis.createClient()

exports.create = (req, res) ->

	# VALIDATORS
	req.assert("email").isEmail()
	req.assert("password").notEmpty()

	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS
	email = req.body.email
	password = req.body.password

	client.GET keys.user(email), (error, uid) ->
		# ERROR
		if error
			res.json({ message: "internal error" }, 500)
			return
		# USER NOT FOUND
		if not uid
			res.json({ message: "user not found" }, 404)
			return

		client.GET keys.active(uid), (error, active) ->
			# ERROR
			if error
				res.json({ message: "internal error" }, 500)
				return
			# USER NOT ACTIVE
			if active isnt "true"
				res.json({ message: "user not active" }, 404)
				return

			client.GET keys.password(uid), (error, realpass) ->
				# ERROR
				if error
					res.json({ message: "internal error" }, 500)
					return
				# CHECK PASSWORDS
				if md5(password) is realpass
					# ACTIVE SESSION
					auth.login(req, uid)
					res.json({ message: "successful login" }, 200)
				else
					res.json({ message: "invalid password" }, 404)
