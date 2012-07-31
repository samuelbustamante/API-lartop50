// Generated by CoffeeScript 1.3.3
(function() {

  module.exports = {
    app: "lartop50",
    key: function(app) {
      if (app == null) {
        app = this.app;
      }
      return "" + app + ":user";
    },
    user: function(email, app) {
      if (app == null) {
        app = this.app;
      }
      return "" + app + ":user:" + email;
    },
    password: function(id, app) {
      if (app == null) {
        app = this.app;
      }
      return "" + app + ":uid:" + id + ":password";
    },
    profile: function(id, app) {
      if (app == null) {
        app = this.app;
      }
      return "" + app + ":uid:" + id + ":profile";
    },
    active: function(id, app) {
      if (app == null) {
        app = this.app;
      }
      return "" + app + ":uid:" + id + ":active";
    },
    activate: function(key, app) {
      if (app == null) {
        app = this.app;
      }
      return "" + app + ":key:" + key;
    }
  };

}).call(this);
