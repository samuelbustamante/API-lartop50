#API lartop50

## REDIS DATABASE SCHEMA

	user:<email> (uid) => user id

	uid:<uid>:pass (string) => password (MD5)
	uid:<uid>:profile (hash) => user profile

	users:active (set) => set uid

	key:<key>:uid (id) => user id

	--

	<email> -> email user
	<uid>   -> user id
	<key>   -> key activate count
