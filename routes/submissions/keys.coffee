module.exports =

	app: "lartop50"


	#        --> ...      -->  ...     -->  ...   --> LINPACK     --> ...
	#       /            /            /          /               /
	#  USER ---> CENTER ---> SYSTEMS ---> SYSTEM ---> COMPONENTS ---> COMPONENT
	#       \            \            \                          \
	#        --> ...      -->  ...     -->  ...                   --> ...


	# CENTERS

	center_key: (app = this.app) ->
		"#{app}:center"

	center_description: (id, app = this.app) ->
		"#{app}:center:#{id}:description"

	center_systems: (id, app = this.app) ->
		"#{app}:center:#{id}:systems"

	user_centers: (uid, app = this.app) ->
		"#{app}:uid:#{uid}:centers"

	# SYSTEMS

	system_key: (app = this.app) ->
		"#{app}:system"

	system_description: (id, app = this.app) ->
		"#{app}:system:#{id}:description"

	system_components: (id, app = this.app) ->
		"#{app}:system:#{id}:components"

	system_linpack: (id, app = this.app) ->
		"#{app}:system:#{id}:linpack"

	user_systems: (uid, app = this.app) ->
		"#{app}:uid:#{uid}:systems"

	# COMPONENTS

	component_key: (app = this.app) ->
		"#{app}:component"

	component_description: (id, app = this.app) ->
		"#{app}:component:#{id}:"

	# LINPACKS

	linpack_key: (app = this.app) ->
		"#{app}:linpack"

	linpack_description: (id, app = this.app) ->
		"#{app}:linpack:#{id}"
