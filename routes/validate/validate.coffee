module.exports =

	validators:

		alpha: (str) ->
			str.match(/^[a-zA-Z]{1, 64}$/)

		numeric: (str) ->
			str.match(/^-?[0-9]{1, 15}$/)

		integer: (str) ->
			this.numeric(str)

		alphanumeric: (str) ->
			str.match(/^[a-zA-Z0-9]{1, 64}$/)

		char: (str) ->
			this.alphanumeric(str)

		text: (str) ->
			str.match(/^[a-zA-Z0-9]{1, 250}$/)

		md5: (str) ->
			str.match(/^[0-9a-z]{32}$/)

		email: (str) ->
			str.match(/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/)

		password: (str) ->
			str.match(/(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{6,12})$/)

	validate: (options, values) ->

		data = {}

		for option in options

			if not values[option[0]]
				return null

			if this.validators[option[1]](values[option[0]])
				data[option[0]] = values[option[0]]
			else
				return null

		return data
