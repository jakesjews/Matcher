appId = "310030915760398"
server = "//localhost:3000"

#appId = "188082917990051"
#server = "//matcher.azurewebsites.net"

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

  loggedIn = (response) ->
    if response.authResponse
      # user has auth'd your app and is logged into Facebook
      FB.api "/me", (me) ->
        document.getElementById("auth-displayname").innerHTML = me.name if me.name
        window.token = response.authResponse.accessToken
        window.uid = me.id
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
    FB.login(loggedIn, scope: 'friends_relationships, friends_birthday, user_interests, friends_interests')

  document.getElementById("auth-logoutlink").addEventListener "click", ->
    FB.logout()

query = """
        SELECT uid, name, last_name, interests, relationship_status, profile_url, pic_square FROM user
        WHERE
          uid = me()
          or
          (
            birthday_date > '07/01/1994'
            AND
            sex = 'female'
            AND
            uid IN (SELECT uid2 FROM friend WHERE uid1 = me())
          )
        """

queryFacebook = () ->
  # Only run if there is a stored authentication token
  if window.token && window.uid
    uri = encodeURI("https://graph.facebook.com/fql?q=#{query}&access_token=#{window.token}")
    $.getJSON uri, (results) =>
      $.post "#{server}/user/#{window.uid}", results, fillTable

fillTable = (users) ->
  $('#results').empty();
  for user in users
    $("#results").append """
      <tr>
        <td>#{user.name}</td>
        <td>#{user.percent}%</td>
        <td>#{if user.relationship_status != 'null' then user.relationship_status else "N/A"}</td>
        <td><a href='#{user.profile_url}'><img src=#{user.pic_square}/j></a></td>
      </tr>"
    """

$ ->
  $("#btnSearch").click -> queryFacebook()
