module.exports =

	app: "lartop50"


	#        --> ...      -->  ...       -->  ...     --> LINPACK     --> ...
	#       /            /              /            /               /
	#  USER ---> PROJECT ---> CLUSTERS ---> CLUSTER ---> COMPONENTS ---> COMPONENT
	#       \            \              \                            \
	#        --> ...      -->  ...       -->  ...                     --> ...


	# PROJECTS

	project_key: (app = this.app) ->
		"#{app}:project"

	project_description: (id, app = this.app) ->
		"#{app}:project:#{id}:description"

	project_clusters: (id, app = this.app) ->
		"#{app}:project:#{id}:clusters"

	user_projects: (uid, app = this.app) ->
		"#{app}:uid:#{uid}:projects"

	# CLUSTERS

	cluster_key: (app = this.app) ->
		"#{app}:cluster"

	cluster_description: (id, app = this.app) ->
		"#{app}:cluster:#{id}:description"

	cluster_components: (id, app = this.app) ->
		"#{app}:cluster:#{id}:components"

	cluster_linpack: (id, app = this.app) ->
		"#{app}:cluster:#{id}:linpack"

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
