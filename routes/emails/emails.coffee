nodemailer = require("nodemailer")

SMTPtransport = nodemailer.createTransport "SMTP",
	host: "smtp.gmail.com"
	secureConnection: true
	port: 465
	auth:
		user: ""
		pass: ""

module.exports =

	send: (to, subject, text, html, callback) ->

		mailOptions =
			from: ""
			to: to
			subject: subject
			text: text,
			html: html

		SMTPtransport.sendMail mailOptions, (error) ->
			if error then callback(error) else callback(null)
