var md5 = require('MD5');
var redis = require("redis");
var client = redis.createClient();
var nodemailer = require("nodemailer");

var SMTPtransport = nodemailer.createTransport("SMTP", {
    host: "smtp.gmail.com", // HOSTNAME
    secureConnection: true, // SSL
    port: 465, // PORT SMTP
    auth: {
        user: "user@gmail.com",
        pass: "pass"
    }
});

exports.create = function(req, res) {
	var name = req.body.name;
	var company = req.body.company;
	var email = req.body.email;
	var pass = req.body.pass;

	// CHECK INCOMPLETE DATA
	if(!(name && company && email && pass)) {
		res.json({ error: 'incomplete data' });
		return; // CHECK !!
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
									// PROFILE OBJECT
									var profile = {
										name: name,
										company: compay
									};
									client.HMSET('uid:' + id + ':profile', profile, function(err) {
										if(err) {
											res.json({ error: 'profile unsaved' });
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
																from: "Name <user@gmail.com>",
																to: "to@gmail.com",
																subject: "KEY activate",
																text: key,
																html: '<p>' + key + '</p>'
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
		}
	});
};
