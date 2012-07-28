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
    appId: "188082917990051" # App ID
    channelUrl: "//localhost:3000/channel.html" # Channel File
    status: true # check login status
    cookie: true # enable cookies to allow the server to access the session
    xfbml: true # parse XFBML

  loggedIn = (response) ->
    if response.authResponse
      # user has auth'd your app and is logged into Facebook
      FB.api "/me", (me) ->
        document.getElementById("auth-displayname").innerHTML = me.name if me.name
        window.token = response.authResponse.accessToken
        queryFacebook()

        document.getElementById("auth-loggedout").style.display = "none"
        document.getElementById("auth-loggedin").style.display = "block"
    else
      # user has not auth'd your app, or is not logged into Facebook
      document.getElementById("auth-loggedout").style.display = "block"
      document.getElementById("auth-loggedin").style.display = "none"

  # listen for and handle auth.statusChange events
  FB.Event.subscribe "auth.statusChange", loggedIn

  # respond to clicks on the login and logout links
  document.getElementById("auth-loginlink").addEventListener "click", ->
    FB.login(loggedIn, scope: 'friends_relationships, friends_birthday')

  document.getElementById("auth-logoutlink").addEventListener "click", ->
    FB.logout()

query = """
        SELECT name, profile_url, pic_square FROM user
        WHERE
          relationship_status = 'single'
          AND
          birthday_date > '01/01/1990'
          AND
          sex = 'female'
          AND
          uid IN (SELECT uid2 FROM friend WHERE uid1 = me())
        """

queryFacebook = () ->
  # Only run if there is a stored authentication token
  if window.token
    uri = encodeURI("https://graph.facebook.com/fql?q=#{query}&access_token=#{window.token}")
    $.getJSON uri, (results) =>
      $.post "http://localhost:3000/", results, fillTable

fillTable = (users) ->
  $('#results').empty();
  for user in users.data
    $("#results").append """
      <tr>
        <td>#{user.name}</td>
        <td>#{user.percent}%</td>
        <td><a href='#{user.profile_url}'><img src=#{user.pic_square}/j></a></td>
      </tr>"
    """

$ ->
  $("#btnSearch").click -> queryFacebook()
