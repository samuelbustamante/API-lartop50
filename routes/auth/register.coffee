md5 = require("MD5")
keys = require("./keys")
redis = require("redis")
server_email = require("./email")
Recaptcha = require('recaptcha').Recaptcha

PUBLIC_KEY  = ''
PRIVATE_KEY = ''

client = redis.createClient()

exports.create = (req, res) ->

	req.assert("name").notEmpty()
	req.assert("email").isEmail()
	req.assert("password").notEmpty()
	req.assert("organization").notEmpty()

	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS
	email = req.body.email
	password = req.body.password
	profile =
		name:	req.body.name
		organization: req.body.organization

	# DATA RECAPTCHA
	data_recaptcha =
		remoteip:  req.connection.remoteAddress
		challenge: req.body.recaptcha_challenge_field
		response:  req.body.recaptcha_response_field

	# VALIDATE RECAPTCHA
	recaptcha = new Recaptcha(PUBLIC_KEY, PRIVATE_KEY, data_recaptcha)

	recaptcha.verify (success, error_code) ->
		if !success
			res.json({ message: "invalid recapcha", code: error_code }, 400)

	# CHECK EXISTING EMAIL
	client.GET keys.user(email), (error, uid) ->
		# EMAIL IS ALREADY IN USE
		if uid
			res.json({ message: "email is already in use" }, 410)
			return

		client.INCR keys.key(), (error, uid) ->
			# ERROR
			if error
				res.json({ message: "internal error" }, 500)
				return

			# REGISTER USER
			client.SET keys.user(email), uid, (error) ->
				if error
					res.json({ message: "internal error" }, 500)
					return

				client.SET keys.password(uid), md5(password), (error) ->
					if error
						res.json({ message: "internal error" }, 500)
						return

					client.HMSET keys.profile(uid), profile, (error) ->
					# ERROR
						if error
							res.json({ message: "internal error" }, 500)
							return

						client.SET keys.active(uid), false, (error) ->
							# ERROR
							if error
								res.json({ message: "internal error" }, 500)
								return

							# GENERATE KEY
							key = md5(Date() + email)

							client.SET keys.activate(key), uid, (error) ->
								if error
									res.json({ message: "internal error" }, 500)
								else
									res.json({message: "successful registration"}, 200)

								# SEND EMAIL
								server_email.send_activate_key email, key, (error) ->
									console.log(key)

