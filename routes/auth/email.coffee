emails =  require("../emails/emails")

module.exports =

	send_activate_key: (to, key, callback) ->

		subject = "Email de Activación"
		text = key
		html = "<p>" + key + "</p>"

		emails.send to, subject, text, html, (error) ->
			if error then callback(error)	else callback(null)
