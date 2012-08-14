redis = require("redis")
auth = require("../auth/auth")
keys = require("../auth/keys")

client = redis.createClient()
client['Multi'] = client.multi()

exports.index = (req, res) ->

	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			res.json({ message: "not authenticated" }, 401)
			return

		client.HGETALL keys.profile(user), (error, profile) ->

			if error
				res.json({ message: "internal error" }, 500)
				return

			res.json(profile, 200)
