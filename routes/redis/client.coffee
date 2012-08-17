redis = require("redis")

client = redis.createClient()
client['Multi'] = client.multi()

module.exports =
	client: client
