// Include the CoffeeScript interpreter so that .coffee files will work
var coffee = require('iced-coffee-script');

// Include our application file
var app = require('./app.coffee');

// Start the server
app.application.listen(process.env.port || 3000);