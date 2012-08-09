keys = require("./keys")
redis = require("redis")

client = redis.createClient()

exports.create = (req, res) ->

	req.assert("key").is(/^[0-9a-z]{32}$/)

	# VALIDATE PARAMETERS
	errors = req.validationErrors()

	# INVALID PARAMETERS
	if errors
		res.json({ message: "invalid parameters", errors: errors }, 400)
		return

	# VALID PARAMETERS
	key = req.body.key

	client.GET keys.activate(key), (error, uid) ->
		# ERROR
		if error
			res.json({ message: "internal error" }, 500)
			return

		# KEY NOT FOUND
		if not uid
			res.json({ message: "key not found" }, 404)
			return

		client.SET keys.active(uid), true, (error) ->
			# ERROR
			if error
				res.json({ message: "internal error" }, 500)
				return

			client.DEL keys.activate(key), (error) ->
				# ERROR
				if error
					res.json({ message: "internal error" }, 500)
				# DELETE ACTIVATE KEY
				res.json({ message: "activation successful" }, 200)
