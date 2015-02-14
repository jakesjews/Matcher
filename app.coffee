express = require('express')
bodyParser = require('body-parser')
morgan = require('morgan')
errorHandler = require('errorhandler')
methodOverride = require('method-override')
serveStatic = require('serve-static')
routes = require('./routes')
http = require('http')
path = require('path')
calculations = require('./calculations')
assets = require('connect-assets')
compiler = require('./iced-compiler')

app = express()

port = process.env.PORT || 3000

app.set('port', port)
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
# app.use assets()
app.use assets(
  src: "#{__dirname}/assets",
  jsCompilers:
    coffee: compiler
)
app.use(bodyParser.json())
app.use(methodOverride())
app.use(require('stylus').middleware(__dirname + '/public'))
app.use(serveStatic(path.join(__dirname, 'public')))
app.use(morgan('combined'))
app.use(errorHandler())

app.get '/', routes.index
app.post '/', routes.index

app.post "/user/:uid", (req, res) ->
  uid = parseInt(req.params.uid)
  users = req.body.data
  await calculations.filterResults(users, uid, defer(err, users))
  res.send(users)

exports.application = http.createServer(app)
