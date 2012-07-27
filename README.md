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

	PUT /profiles  <= name     (required, not null)
                     company  (required, not null)
                     web      (not required, valid url)
                     twitter  (not required, valid url)
                     facebook (not required, valid url)

	POST /clusters <= name
                     acronym
                     url
                     segment
                     description
                     city
                     country
                     state

	GET  /clusters/:id   => returns the description with all its components.

	POST /clusters/components <= cluster (id cluster)
                                name
                                model
                                vendor
                                nodes
                                processor_name
                                processor_model
                                processor_socket
                                processor_cores
                                processor_speed
                                accelerator_name
                                accelerator_model
                                accelerator_number
                                accelerator_cores
                                accelerator_speed
                                primary_operatingsystem
                                primary_interconecton
                                memory_node

	GET  /clusters/components/:id => returns the description.

	POST /clusters/limpacks <= cluster (id cluster)
                              benchmark_date
                              cores
                              gpu_cores
                              rmax
                              rpeak
                              nmax
                              nhalf
                              compiler_name
                              compiler_options
                              math_library
                              mpi_library
                              hpl_input
                              hpl_output



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
