
/**
 * Module dependencies.
 */

var express = require('express');
var Resource = require('express-resource');
var Validator = require('express-validator');
var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.set('view options', { layout: false });
  app.use(express.bodyParser());
  app.use(Validator);
  app.use(express.cookieParser());
  app.use(express.session({ secret: 'SECRET' }));
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// AUTH
app.resource('api/auth/login',    require('./routes/auth/login'));
app.resource('api/auth/register', require('./routes/auth/register'));
app.resource('api/auth/activate', require('./routes/auth/activate'));
app.resource('api/auth/profiles', require('./routes/auth/profiles'));

// USER
app.resource('/api/user/sites/', require('./routes/clusters/projects'));
app.resource('/api/user/machines/', require('./routes/clusters/clusters'));
app.resource('/api/user/linpacks/', require('./routes/clusters/linpacks'));
app.resource('/api/user/components/', require('./routes/clusters/components'));

app.listen(3001, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
