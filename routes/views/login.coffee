redis = require("redis")
auth = require("../auth/auth")
Recaptcha = require('recaptcha').Recaptcha

PUBLIC_KEY  = ''
PRIVATE_KEY = ''

client = redis.createClient()

exports.index = (req, res) ->
	auth.is_authenticated req, (user) ->

		if user
			res.redirect('/')
			return

		recaptcha = new Recaptcha(PUBLIC_KEY, PRIVATE_KEY)

		res.render('login', { recaptcha_form: recaptcha.toHTML() })
