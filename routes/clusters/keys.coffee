module.exports =

	app: "lartop50"

	# CLUSTERS

	cluster_key: (app = this.app) ->
		"#{app}:cluster"

	cluster: (id, app = this.app) ->
		"#{app}:cluster:#{id}:description"

	clusters: (uid, app = this.app) ->
		"#{app}:uid:#{uid}:clusters"

	# COMPONENTS

	component_key: (app = this.app) ->
		"#{app}:component"

	component: (id, app = this.app) ->
		"#{app}:cluster:component:#{id}:"

	components: (id, app = this.app) ->
		"#{app}:cluster:#{id}:components"

	# LINPACKS

	linpack_key: (app = this.app) ->
		"#{app}:linpack"

	linpack: (id, app = this.app) ->
		"#{app}:cluster:linpack:#{id}:"

	linpacks: (id, app = this.app) ->
		"#{app}:cluster:#{id}:linpack"
