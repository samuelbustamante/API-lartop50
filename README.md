#API lartop50

## REST API Resources

	POST /login          => parameters: (email, pass)
	POST /register       => parameters: (name, company, email, pass)
	GET  /activate/:key  =>
	GET  /profiles       => returns all active user profiles.
	POST /clusters       => pameters: (data[name], data[url], ...)
	GET  /clusters/:id   => returns the description with all its components.
	POST /components     => parameters: (cluster, data[name], data[n_nodes], ...)
	GET  /components/:id => returns the description.

## REDIS DATABASE SCHEMA

	user:<email> (uid) => user id
	uid:<uid>:pass (string) => password (MD5)
	uid:<uid>:profile (hash) => user profile
	users:active (set) => set uid
	key:<key>:uid (id) => user id

	<email> -> email user
	<uid>   -> user id
	<key>   -> key activate count
