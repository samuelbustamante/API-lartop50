// Generated by CoffeeScript 1.3.3
(function() {
  var auth, client, keys, redis;

  redis = require("redis");

  keys = require("./keys");

  auth = require("../auth/auth");

  client = redis.createClient();

  client['Multi'] = client.multi();

  exports.create = function(req, res) {
    return auth.is_authenticated(req, function(user) {
      var data, errors;
      if (!user) {
        res.json({
          message: "not authenticated"
        }, 401);
        return;
      }
      req.assert("name").notEmpty();
      req.assert("acronym").notEmpty();
      req.assert("segment").notEmpty();
      req.assert("country").notEmpty();
      req.assert("city").notEmpty();
      req.assert("url").isUrl();
      req.assert("description").notEmpty();
      errors = req.validationErrors();
      if (errors) {
        res.json({
          message: "invalid parameters",
          errors: errors
        }, 400);
        return;
      }
      req.sanitize("description").xss();
      data = {
        name: req.body.name,
        acronym: req.body.acronym,
        segment: req.body.segment,
        country: req.body.country,
        city: req.body.city,
        url: req.body.url,
        description: req.body.description
      };
      return client.INCR(keys.project_key(), function(error, id) {
        if (error) {
          res.json({
            message: "internal error"
          }, 500);
          return;
        }
        return client.HMSET(keys.project_description(id), data, function(error) {
          if (error) {
            res.json({
              message: "internal error"
            }, 500);
            return;
          }
          return client.SADD(keys.user_projects(user), id, function(error) {
            if (error) {
              return res.json({
                message: "internal error"
              }, 500);
            } else {
              return res.json({
                message: "project created successful",
                data: data
              }, 200);
            }
          });
        });
      });
    });
  };

  exports.show = function(req, res) {
    var errors, project;
    req.assert("project").isInt();
    errors = req.validationErrors();
    if (errors) {
      res.json({
        message: "invalid parameters",
        errors: errors
      }, 400);
      return;
    }
    project = req.params.project;
    return client.HGETALL(keys.project_description(project), function(error, description) {
      if (error) {
        res.json({
          message: "internal error"
        }, 500);
        return;
      }
      if (!description) {
        return res.json({
          message: "project not found"
        }, 404);
      } else {
        return res.json(description, 200);
      }
    });
  };

}).call(this);
