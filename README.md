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

	lartop50:user:<email> (uid) => user id
	lartop50:uid:<uid>:pass (string) => password (MD5)
	lartop50:uid:<uid>:profile (hash) => user profile
	lartop50:uid:<uid>:clusters (set) => set of cluster ids
	lartop50:users:active (set) => set of uid
	lartop50:key:<key>:uid (id) => user id
	lartop50:cluster:<id>:description (hash) => description
	lartop50:cluster:<id>:components (set) => set of components ids
	lartop50:component:<id>:description (hash) => description

	<email> -> email user
	<uid>   -> user id
	<key>   -> key activate count
