#API lartop50

## REST API Resources

	POST /login          => parameters: (email, pass)
	POST /register       => parameters: (name, company, email, pass)
	GET  /activate/:key  => active user account.
	GET  /profiles       => returns all active user profiles.
	POST /profiles       => parameters: (data[name], data[company], ...)
	POST /clusters       => parameters: (data[name], data[url], ...)
	GET  /clusters/:id   => returns the description with all its components.
	POST /clusters/components     => parameters: (cluster, data[name], data[n_nodes], ...)
	GET  /clusters/components/:id => returns the description.

## REDIS DATABASE SCHEMA

	user:<email> (uid) => user id
	uid:<uid>:pass (string) => password (MD5)
	uid:<uid>:profile (hash) => user profile
	uid:<uid>:clusters (set) => set of cluster ids
	users:active (set) => set of uid
	key:<key>:uid (id) => user id
	cluster:<id>:description (hash) => description
	cluster:<id>:components (set) => set of components ids
	component:<id>:description (hash) => description

	<email> -> email user
	<uid>   -> user id
	<key>   -> key activate count
