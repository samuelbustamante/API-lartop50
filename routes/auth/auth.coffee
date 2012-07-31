module.exports =

	is_authenticated: (req, callback) ->
		if req.session.auth
			callback(req.session.auth.uid)
		else
			callback(null)

	login: (req, uid) ->
		req.session.auth = {}
		req.session.auth.uid = uid

	logout: (req) ->
		delete req.session.auth
