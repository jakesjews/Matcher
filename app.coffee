express = require('express')
routes = require('./routes')
http = require('http')
path = require('path')
_ = require('underscore')

app = express()

app.configure = ->
  app.set('port', process.env.PORT || 3000)
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use require('connect-assets')()
  app.use(express.favicon())
  app.use(express.logger('dev'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.cookieParser('your secret here'))
  app.use(express.session())
  app.use(app.router)
  app.use(require('stylus').middleware(__dirname + '/public'))
  app.use(express.static(path.join(__dirname, 'public')))

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', routes.index

app.post "/user/:uid", (req, res) ->
  uid = req.param("uid")
  users = req.body.data
  users = filterResults(users, uid)
  res.send(users)

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port ${ app.get('port') "

filterResults = (users, uid) ->
  me = getSelf(users, uid)
  selfInterests = getInterests(me)
  users = _.without(users, me)
  for user in users
    user.percent = 20
    calculateInterests(user, selfInterests)
  return _.sortBy(users, (user) -> user.percent).reverse()

getInterests = (u) -> u.interests.replace(/\s+/g, '').split(',')
getSelf = (users, uid) -> _.find(users, (user) -> user.uid is uid)

calculateInterests = (user, selfInterests) ->
  matchCount = _.intersection(selfInterests, getInterests(user)).length
  user.percent += matchCount * 20 unless (user.percent + 20 > 100)
