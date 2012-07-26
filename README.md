#API lartop50

## REST API Resources

	POST /auth/login <=   email (required, valid email)
                         pass  (required, length 6 to 64)

	POST /auth/register  <= name    (required, not null)
                           company (requires, not null)
                           email   (required, valid email)
                           pass    (required, length 6 to 64)

	GET  /auth/activate/:key => active user account.

	GET /profiles  => returns all active user profiles.

	PUT /profiles  <= data[name]     (required, not null)
                     data[company]  (required, not null)
                     data[web]      (not required, valid url)
                     data[twitter]  (not required, valid url)
                     data[facebook] (not required, valid url)
                     ...

	POST /clusters <= data[name]
                     data[acronym]
                     data[url]
                     data[segment]
                     data[description]
                     data[city]
                     data[country]
                     data[state]

	GET  /clusters/:id   => returns the description with all its components.

	POST /clusters/components <= cluster (id cluster)
                                data[name]
                                data[model]
                                data[vendor]

                                data[nodes]

                                data[processor_name]
                                data[processor_model]
                                data[processor_socket]
                                data[processor_cores]
                                data[processor_speed]

                                data[accelerator_name]
                                data[accelerator_model]
                                data[accelerator_number]
                                data[accelerator_cores]
                                data[accelerator_speed]

                                data[power_kW]

                                data[primary_operatingsystem]
                                data[primary_interconecton]

                                data[memory_node]

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
