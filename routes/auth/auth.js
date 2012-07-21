module.exports = {

	is_authenticated: function (req, callback) {
		if(req.session.auth) {
			callback(req.session.auth.id);
		} else {
			callback(null);
		}
	}

}
