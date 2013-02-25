# appId = "310030915760398"
# server = "//localhost:3000"

appId = "188082917990051"
server = "//facebookmatcher.herokuapp.com"

# Load the SDK Asynchronously
((d) ->
  id = "facebook-jssdk"
  ref = d.getElementsByTagName("script")[0]
  return  if d.getElementById(id)
  js = d.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/en_US/all.js"
  ref.parentNode.insertBefore js, ref
) document
window.fbAsyncInit = ->
  FB.init
    appId: "#{appId}" # App ID
    channelUrl: "#{server}/channel.html" # Channel File
    status: true # check login status
    cookie: true # enable cookies to allow the server to access the session
    xfbml: true # parse XFBML

  # listen for and handle auth.statusChange events
  await FB.Event.subscribe "auth.statusChange", defer(response)

  if response.authResponse
    # user has auth'd your app and is logged into Facebook
    await FB.api "/me", defer(me)
    window.token = response.authResponse.accessToken
    window.uid = me.id
    window.sex = me.sex
    await queryFacebook defer()

User = (user) ->
  this.name = user.name
  this.percent = user.percent.toFixed(2)
  this.relationship_status = if user.name == 'null' then 'N/A' else user.relationship_status
  this.profile_url = user.profile_url
  this.pic = user.pic

viewModel =
  gender: ko.observable('male')
  users: ko.observableArray()

$ =>
  ko.applyBindings(viewModel)
  $("#btnSearch").click ->
    await queryFacebook defer()
  $('.nav-tabs').button()

getSex = () ->
  selected = $("#gender .active")
  selected.html().toLowerCase()

getQuery = () -> """
        SELECT uid, name, last_name, mutual_friend_count, interests,
          relationship_status, profile_url, pic, birthday_date FROM user
        WHERE
          uid = me()
          or
          (
            sex = '#{getSex()}'
            AND
            uid IN (SELECT uid2 FROM friend WHERE uid1 = me())
          )
        LIMIT 100
        """

queryFacebook = (callback) ->
  # Only run if there is a stored authentication token
  if window.token && window.uid
    uri = encodeURI("https://graph.facebook.com/fql?q=#{getQuery()}&access_token=#{window.token}")
    await $.getJSON uri, defer(results)
    await $.post "#{server}/user/#{window.uid}", results, defer(results)
    fillTable(results, callback)

fillTable = (users, autocb) ->
  viewModel.users.removeAll()
  for user in users then do (user) ->
    viewModel.users.push(new User(user))
