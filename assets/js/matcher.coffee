#appId = "310030915760398"
#server = "//localhost:3000"

appId = "188082917990051"
server = "//matcher.azurewebsites.net"

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
        window.token = response.authResponse.accessToken
        window.uid = me.id
        window.sex = me.sex
        queryFacebook()

  # listen for and handle auth.statusChange events
  FB.Event.subscribe "auth.statusChange", loggedIn

$ ->
  $("#btnSearch").click -> queryFacebook()
  $('.nav-tabs').button()

getSex = () ->
  selected = $("#gender .active")
  selected.html().toLowerCase()

query = () -> """
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

queryFacebook = () ->
  # Only run if there is a stored authentication token
  if window.token && window.uid
    uri = encodeURI("https://graph.facebook.com/fql?q=#{query()}&access_token=#{window.token}")
    $.getJSON uri, (results) =>
      $.post "#{server}/user/#{window.uid}", results, fillTable

fillTable = (users) ->
  $('#results').empty();
  for user in users
    $("#results").append """
      <tr>
        <td>#{user.name}</td>
        <td>#{user.percent.toFixed(2)}%</td>
        <td>#{if user.relationship_status != 'null' then user.relationship_status else "N/A"}</td>
        <td><a href='#{user.profile_url}'><img src=#{user.pic}></a></td>
      </tr>"
    """
