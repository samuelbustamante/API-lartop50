var md5 = require('MD5');
var redis = require("redis");
var client = redis.createClient();
var nodemailer = require("nodemailer");

var SMTPtransport = nodemailer.createTransport("SMTP", {
    host: "smtp.gmail.com", // HOSTNAME
    secureConnection: true, // SSL
    port: 465, // PORT SMTP
    auth: {
        user: "gmail.user@gmail.com",
        pass: "userpass"
    }
});

exports.create = function(req, res) {
	var email = req.body.email;
	var pass = req.body.pass;

	// CHECK INCOMPLETE DATA
	if(!(email && pass)) {
		res.json({ error: 'incomplete data' });
	}

	// CHECK EXIXTING EMAIL
	client.GET('user:' + email + ':id', function(err, id) {
		if(id) {
			res.json({ error: 'existing email' });
		} else {
			client.INCR('user', function(err, id) {
				if(err) {
					res.json({ error: 'id not generated' });
				} else {
					//REGISTER USER
					client.SET('user:' + email + ':id', id, function(err) {
						if(err) {
							res.json({ error: 'email unsaved' });
						} else {
							client.SET('uid:' + id + ':pass', md5(pass), function(err) {
								if(err) {
									res.json({ error: 'pass unsaved' });
								} else {
									client.SET('uid:' + id + ':activated', false, function(err) {
										if(err) {
											res.json('ERROR')
										} else {
											// GENERATE KEY
											var key = md5(Date() + email);
											client.SET('key:' + key + ':uid', id, function(err) {
												if(err) {
													res.json({ error: 'ERROR' });
												} else {
													var mailOptions = {
														from: "Sender Name <sender@example.com>",
														to: "reciver@example.com",
														subject: "Hello",
														text: "Hello world",
														html: "<b>Hello world</b>"
													}
													// SEND EMAIL
													SMTPtransport.sendMail(mailOptions, function(err){
														if(err){
															res.json({ error: 'not send email' });
														} else {
															res.json({ key: key });
														}
													});
												}
											});
										}
									});
								}
							});
						}
					});
				}
			});
		}
	});
};
