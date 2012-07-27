# GET home page.

exports.index = (req, res) ->
  res.render('index', title: 'Matcher')

exports.query = (req, res) ->
  res.send(req.body)