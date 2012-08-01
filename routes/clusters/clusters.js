// Generated by CoffeeScript 1.3.3
(function() {
  var auth, client, keys, redis, validate;

  redis = require("redis");

  keys = require("./keys");

  auth = require("../auth/auth");

  validate = require("../validate/validate");

  client = redis.createClient();

  client['Multi'] = client.multi();

  exports.create = function(req, res) {
    return auth.is_authenticated(req, function(user) {
      var data, options;
      if (!user) {
        res.json({
          message: "not authenticated"
        }, 401);
        return;
      }
      options = [["url", "url"], ["name", "alphanumeric"], ["acronym", "char"], ["segment", "char"], ["description", "text"], ["city", "char"], ["state", "char"], ["country", "char"]];
      data = validate.validate(options, req.body);
      if (!data) {
        res.json({
          message: "invalida parameters"
        }, 400);
        return;
      }
      return client.INCR(keys.key(), function(error, id) {
        if (error) {
          res.json({
            message: "internal error"
          }, 500);
          return;
        }
        return client.HMSET(keys.cluster(id), data, function(error) {
          if (error) {
            res.json({
              message: "internal error"
            }, 500);
            return;
          }
          return client.SADD(keys.clusters(user), id, function(error) {
            if (error) {
              return res.json({
                message: "internal error"
              }, 500);
            } else {
              return res.json({
                message: "cluster created successful"
              }, 200);
            }
          });
        });
      });
    });
  };

  exports.show = function(req, res) {
    var data, options;
    options = [["cluster", "integer"]];
    data = validate.validate(options, req.params);
    if (!data) {
      res.json({
        message: "invalid cluster"
      }, 400);
      return;
    }
    return client.HGETALL(keys.cluster(data.cluster), function(error, description) {
      if (error) {
        res.json({
          message: "internal error"
        }, 500);
        return;
      }
      if (!description) {
        res.json({
          message: "cluster not found"
        }, 404);
        return;
      }
      return client.SMEMBERS(keys.components(data.cluster), function(error, components) {
        var cmds, component, _i, _len;
        cmds = [];
        for (_i = 0, _len = components.length; _i < _len; _i++) {
          component = components[_i];
          cmds.push(['HGETALL', keys.component(component)]);
        }
        return client.multi(cmds).exec(function(error, replies) {
          if (error) {
            res.json({
              message: "internal error"
            }, 500);
            return;
          }
          return res.json({
            description: description,
            components: replies
          }, 200);
        });
      });
    });
  };

}).call(this);
