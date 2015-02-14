// Include the CoffeeScript interpreter so that .coffee files will work
var coffee = require('iced-coffee-script/register');

// Include our application file
var app = require('./app.coffee');

// Start the server
app.application.listen(process.env.PORT || 3000);
