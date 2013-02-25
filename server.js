if(process.env.NODETIME_ACCOUNT_KEY) {
  require('nodetime').profile({
    accountKey: process.env.NODETIME_ACCOUNT_KEY,
    appName: 'My Application Name' // optional
  });
}

// Include the CoffeeScript interpreter so that .coffee files will work
var coffee = require('iced-coffee-script');

// Include our application file
var app = require('./app.coffee');

// Start the server
app.application.listen(process.env.PORT || 3000);