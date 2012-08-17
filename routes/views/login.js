// Generated by CoffeeScript 1.3.3
(function() {
  var PRIVATE_KEY, PUBLIC_KEY, Recaptcha, auth, client, redis;

  redis = require("redis");

  auth = require("../auth/auth");

  Recaptcha = require('recaptcha').Recaptcha;

  PUBLIC_KEY = '';

  PRIVATE_KEY = '';

  client = redis.createClient();

  exports.index = function(req, res) {
    return auth.is_authenticated(req, function(user) {
      var recaptcha;
      if (user) {
        res.redirect('/');
        return;
      }
      recaptcha = new Recaptcha(PUBLIC_KEY, PRIVATE_KEY);
      return res.render('login', {
        recaptcha_form: recaptcha.toHTML()
      });
    });
  };

}).call(this);