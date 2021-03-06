// Generated by CoffeeScript 1.3.3
(function() {
  var auth, keys, redis;

  keys = require("./keys");

  auth = require("../auth/auth");

  redis = require("../redis/client");

  exports.create = function(req, res) {
    return auth.is_authenticated(req, function(user) {
      var errors;
      if (!user) {
        res.json({
          message: "not authenticated"
        }, 401);
        return;
      }
      req.assert("name", "Este campo es requerido.").notEmpty();
      req.assert("status", "Este campo es requerido.").notEmpty();
      req.assert("area", "Este campo es requerido.").notEmpty();
      req.assert("description", "Este campo es requerido.").notEmpty();
      req.assert("vendor", "Este campo es requerido.").notEmpty();
      req.assert("installation", "Este campo es requerido.").notEmpty();
      req.assert("installation", "Este campo es de tipo entero.").isInt();
      req.assert("installation", "Este campo es de longitud 4.").len(4);
      req.assert("center", "Este campo es requerido.").notEmpty();
      req.assert("center", "Este campo es de tipo entero").isInt();
      errors = req.validationErrors();
      if (errors) {
        res.json({
          message: "invalid parameters",
          errors: errors
        }, 400);
        return;
      }
      return redis.client.INCR(keys.system_key(), function(error, id) {
        var center, data;
        if (error) {
          res.json({
            message: "internal error"
          }, 500);
          return;
        }
        req.sanitize("name").xss();
        req.sanitize("name").entityEncode();
        req.sanitize("status").xss();
        req.sanitize("status").entityEncode();
        req.sanitize("area").xss();
        req.sanitize("area").entityEncode();
        req.sanitize("description").xss();
        req.sanitize("description").entityEncode();
        req.sanitize("vendor").xss();
        req.sanitize("vendor").entityEncode();
        center = req.body.center;
        data = {
          id: id,
          name: req.body.name,
          status: req.body.status,
          area: req.body.area,
          description: req.body.description,
          vendor: req.body.vendor,
          installation: req.body.installation
        };
        return redis.client.HMSET(keys.system_description(id), data, function(error) {
          if (error) {
            res.json({
              message: "internal error"
            }, 500);
            return;
          }
          return redis.client.SADD(keys.center_systems(center), id, function(error) {
            if (error) {
              res.json({
                message: "internal error"
              }, 500);
              return;
            }
            return redis.client.SADD(keys.user_systems(user), id, function(error) {
              if (error) {
                return res.json({
                  message: "internal error"
                }, 500);
              } else {
                return res.json({
                  message: "system created successful",
                  data: data
                }, 200);
              }
            });
          });
        });
      });
    });
  };

  exports.show = function(req, res) {
    return auth.is_authenticated(req, function(user) {
      var errors, system;
      if (!user) {
        res.json({
          message: "not authenticated"
        }, 401);
        return;
      }
      req.assert("system").isInt();
      errors = req.validationErrors();
      if (errors) {
        res.json({
          message: "invalid system",
          errors: errors
        }, 400);
        return;
      }
      system = req.params.system;
      return redis.client.SISMEMBER(keys.user_systems(user), system, function(error, member) {
        if (!member) {
          res.json({
            message: "system not found"
          }, 404);
          return;
        }
        return redis.client.HGETALL(keys.system_description(system), function(error, description) {
          if (error) {
            res.json({
              message: "internal error"
            }, 500);
            return;
          }
          if (!description) {
            res.json({
              message: "system not found"
            }, 404);
            return;
          }
          return redis.client.SMEMBERS(keys.system_components(system), function(error, components) {
            var cmds, component, _i, _len;
            cmds = [];
            for (_i = 0, _len = components.length; _i < _len; _i++) {
              component = components[_i];
              cmds.push(['HGETALL', keys.component_description(component)]);
            }
            return redis.client.multi(cmds).exec(function(error, replies) {
              if (error) {
                res.json({
                  message: "internal error"
                }, 500);
                return;
              }
              return redis.client.GET(keys.system_linpack(system), function(error, id) {
                if (error) {
                  res.json({
                    message: "internal error"
                  }, 500);
                  return;
                }
                return redis.client.HGETALL(keys.linpack_description(id), function(error, linpack) {
                  var data;
                  if (error) {
                    res.json({
                      message: "internal error"
                    }, 500);
                    return;
                  }
                  data = {
                    description: description,
                    components: replies,
                    linpack: linpack
                  };
                  return res.json({
                    message: "success",
                    data: data
                  }, 200);
                });
              });
            });
          });
        });
      });
    });
  };

}).call(this);
