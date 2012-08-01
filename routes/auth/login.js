// Generated by CoffeeScript 1.3.3
(function() {
  var auth, client, keys, md5, redis, validate;

  md5 = require("MD5");

  auth = require("./auth");

  keys = require("./keys");

  redis = require("redis");

  validate = require("../validate/validate");

  client = redis.createClient();

  exports.create = function(req, res) {
    var data, options;
    options = [["email", "email"], ["password", "password"]];
    data = validate.validate(options, req.body);
    if (!data) {
      res.json({
        message: "invalid parameters"
      }, 400);
      return;
    }
    return client.GET(keys.user(data.email), function(error, uid) {
      if (error) {
        res.json({
          message: "internal error"
        }, 500);
        return;
      }
      if (!uid) {
        res.json({
          message: "user not found"
        }, 404);
        return;
      }
      return client.GET(keys.active(uid), function(error, active) {
        if (error) {
          res.json({
            message: "internal error"
          }, 500);
          return;
        }
        if (active !== "true") {
          res.json({
            message: "user not active"
          }, 404);
          return;
        }
        return client.GET(keys.password(uid), function(error, realpass) {
          if (error) {
            res.json({
              message: "internal error"
            }, 500);
            return;
          }
          if (md5(data.password) === realpass) {
            auth.login(req, uid);
            return res.json({
              message: "successful login"
            }, 200);
          } else {
            return res.json({
              message: "invalid password"
            }, 404);
          }
        });
      });
    });
  };

}).call(this);
