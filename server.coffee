cluster = require('cluster')

if cluster.isMaster
  require('os').cpus().forEach ->
    cluster.fork()
else
  require('./app.js')