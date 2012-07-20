#API lartop50

## REST API Resources

	POST /login

	Parameters:
		email:
		pass:

	----------------

	POST /register

	Parameters:
		name:
		company:
		email:
		pass:
		
	----------------

	GET /activate/:key

	----------------

	GET /profiles

## REDIS DATABASE SCHEMA

	user:<email> (uid) => user id

	uid:<uid>:pass (string) => password (MD5)
	uid:<uid>:profile (hash) => user profile

	users:active (set) => set uid

	key:<key>:uid (id) => user id

	----------------

	<email> -> email user
	<uid>   -> user id
	<key>   -> key activate count
