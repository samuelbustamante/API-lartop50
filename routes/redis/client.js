// Generated by CoffeeScript 1.3.3
(function() {
  var client, redis;

  redis = require("redis");

  client = redis.createClient();

  client['Multi'] = client.multi();

  module.exports = {
    client: client
  };

}).call(this);
