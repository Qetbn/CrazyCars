// global modules
require('coffee-script');

var express = require('express')
  , log = require('logule')
  , _ = require('underscore')
  , stylus = require('stylus')
  , mongoStore = require('connect-mongodb')
  , io = require('socket.io');

// Global app object
var app = module.exports = express.createServer();

// Database
app.mongoose = require('mongoose');
// Logule
app.log = log;

// Configuration
app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());

  app.set('db-uri', 'mongodb://localhost/crazycars');	
  app.use(express.session({key: 'fhdrtnydrtre', secret: '479tgfrewiutgp34itgfaeup'}));

  app.use(stylus.middleware({
  src: __dirname + '/public',
  }));


  app.use(app.router);
  app.use(express.compiler({src: __dirname + "/public", enable: ["coffeescript"]}));
  app.use(express.static(__dirname + '/public'));
  app.use(require('connect-assets')());
  var db = app.mongoose.connect(process.env.MONGOLAB_URI || app.set('db-uri'));
  function mongoStoreConnectionArgs() {
    return { dbname: db.connections[0].name,
             host: db.connections[0].host,
             port: db.connections[0].port,
             username: db.connections[0].user,
             password: db.connections[0].pass };
  }
  app.use(express.session({
    secret: "hg53hg454h3gf4hgh45tewr",
    store: mongoStore(mongoStoreConnectionArgs())
  }));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Loading global models
models = {};
models.vk_profile = require('./models/vk_profile')(app.mongoose).model;

// Starting sessions
app.get('*', function(req, res, next) {
  global.session = req.session;
  next();
});
app.post('*', function(req, res, next) {
  global.session = req.session;
  next();
});

app.listen(3000, function(){
  log.info("Server listening on port %d in %s mode", app.address().port, app.settings.env);
});

// Loading routes
require('./apps/vk-auth/routes')(app,models);
require('./apps/dash/routes')(app,models);
require('./apps/dash/socket')(app,models,io);
