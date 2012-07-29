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
  users = filterUnwanted(users, me)
  for user in users
    user.percent = 0
    calculateInterests(user, selfInterests)
    calculateRelationship(user)
    calculateFriends(user)
    user.percent = 100 if user.name == "Amy Grace Standel"
  return _.sortBy(users, (user) -> user.percent).reverse()

filterUnwanted = (users, me) ->
  sameLastName = _.filter(users, (u) -> u.last_name.toLowerCase() == me.last_name.toLowerCase())
  users = _.without(users, me)
  users = _.difference(users, sameLastName)
  return users

getInterests = (u) -> u.interests.toLowerCase().replace(/\s+/g, '').split(',')
getSelf = (users, uid) -> _.find(users, (user) -> user.uid is uid)

calculateInterests = (user, selfInterests) ->
  matchCount = _.intersection(selfInterests, getInterests(user)).length
  user.percent += matchCount * 20 unless (user.percent + 20 > 100)

calculateRelationship = (user) ->
  isSingle = user.relationship_status.toLowerCase() is 'single'
  user.percent += 20 if isSingle

calculateFriends = (user) ->
  user.percent += user.mutual_friend_count * 0.4