auth = require("./auth")

exports.create = (req, res) ->
	
	auth.is_authenticated req, (user) ->

		# NOT AUTHENTICATED
		if not user
			auth.logout(req)
			res.json({ message: "logout successful" }, 200)
		else
			res.json({ message: "not authenticated" }, 401)
