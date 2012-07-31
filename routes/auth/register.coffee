md5 = require("MD5")
keys = require("./keys")
redis = require("redis")
email = require("./email")
validate = require("../validate/validate")

client = redis.createClient()

exports.create = (req, res) ->

	options = [
		["email", "email"]
		["password", "password"]
		["name", "char"]
		["organization", "char"]
	]

	data = validate.validate(options, req.body)

	if !data
		res.json({ message: "datos inválidos." }, 400)
		return

	# CHECK EXISTING EMAIL
	client.GET keys.user(data.email), (error, uid) ->
		# EMAIL IS ALREADY IN USE
		if uid
			res.json({ message: "correo electrónico en uso." }, 410)
			return

		client.INCR keys.key(), (error, uid) ->
			# ERROR
			if error
				res.json({}, 500)
				return

			# REGISTER USER
			client.SET keys.user(data.email), uid, (error) ->
				if error
					res.json({}, 500)
					return

				client.SET keys.password(uid), md5(data.password), (error) ->
					if error
						res.json({}, 500)
						return

					profile =
						name: data.name
						organization: data.organization

					client.HMSET keys.profile(uid), profile, (error) ->
					# ERROR
						if error
							res.json({}, 500)
							return

						client.SET keys.active(uid), false, (error) ->
							# ERROR
							if error
								res.json({}, 500)
								return

							# GENERATE KEY
							key = md5(Date() + data.email)

							client.SET keys.activate(key), uid, (error) ->
								if error
									res.json({}, 500)
									return

								# SEND EMAIL
								email.send_activate_key data.email, key, (error) ->
									# EMAIL NOT SEND
									if error
										res.json({}, 500)
										console.log(error)
									# EMAIL SEND
									else
										res.json({message: "registración exitosa."}, 200)
