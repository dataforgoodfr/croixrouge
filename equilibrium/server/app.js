/**
 * Main application file
 */

'use strict';

var http = require("http");
var auth = require("http-auth");
var basic = auth.basic({
  realm: "Private area",
  file: __dirname + "/htpasswd"
});

// Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var express = require('express');
var config = require('./config/environment');
// Setup server
var app = express();
app.use(auth.connect(basic));
var server = http.createServer(app);
require('./config/express')(app);
require('./routes')(app);

// Start server
server.listen(config.port, config.ip, function () {
  console.log('Express server listening on %d, in %s mode', config.port, app.get('env'));
});

// Expose app
exports = module.exports = app;