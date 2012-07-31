module.exports =

	app: "lartop50"

	key: (app = this.app) ->
		"#{app}:user"

	user: (email, app = this.app) ->
		"#{app}:user:#{email}"

	password: (id, app = this.app) ->
		"#{app}:uid:#{id}:password"

	profile: (id, app = this.app) ->
		"#{app}:uid:#{id}:profile"

	active: (id, app = this.app) ->
		"#{app}:uid:#{id}:active"

	activate: (key, app = this.app) ->
		"#{app}:key:#{key}"
