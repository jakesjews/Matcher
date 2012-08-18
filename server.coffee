cluster = require('cluster')

if cluster.isMaster
  require('os').cpus().forEach ->
    cluster.fork()

  cluster.on 'death', (worker) ->
    console.log('worker' + worker.pid + ' died')
    cluster.fork()
else
  require('./app.js')