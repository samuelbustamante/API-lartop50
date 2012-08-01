md5 = require("MD5")
auth = require("./auth")
keys = require("./keys")
redis = require("redis")
validate = require("../validate/validate")

client = redis.createClient()

exports.create = (req, res) ->

	options = [
		["email", "email"]
		["password", "password"]
	]

	data = validate.validate(options, req.body)

	if !data
		res.json({ message: "invalid parameters" }, 400)
		return

	client.GET keys.user(data.email), (error, uid) ->
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
				if md5(data.password) is realpass
					# ACTIVE SESSION
					auth.login(req, uid)
					res.json({ message: "successful login" }, 200)
				else
					res.json({ message: "invalid password" }, 404)
