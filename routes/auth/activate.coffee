keys = require("./keys")
redis = require("redis")
validate = require("../validate/validate")

client = redis.createClient()

exports.show = (req, res) ->

	options = [
		['activate', 'md5']
	]

	data = validate.validate(options, req.params)

	if not data
		res.json({}, 400)
		return

	client.GET keys.activate(data.activate), (error, uid) ->
		# ERROR
		if error
			res.json({}, 500)
			return

		# KEY NOT FOUND
		if not uid
			res.json({}, 404)
			return

		client.SET keys.active(uid), true, (error) ->
			# ERROR
			if error
				res.json({}, 500)
				return

			client.DEL keys.activate(data.activate), (error) ->
				# ERROR
				if error
					res.json({}, 500)
				# DELETE ACTIVATE KEY
				res.json({}, 200)
