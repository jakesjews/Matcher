_ = require('lodash')

exports.filterResults = (users, uid, callback) ->
  await getSelf(users, uid, defer(err, me))
  await getInterests(me, defer(err, selfInterests))
  await filterUnwanted(users, me, defer(err, users))

  await
    for user in users
      filterUser user, me, selfInterests, defer()

  results = _.sortBy(users, (user) -> -user.percent)
  callback(null, results)

filterUser = (user, me, selfInterests, autocb) ->
  user.percent = 0

  await calculateInterests(user, selfInterests, defer())
  await calculateRelationship(user, defer())
  await calculateFriends(user, defer())

  if me.birthday_date? and user.birthday_date?
    await calculateAge(user, me.birthday_date, defer())

  if user.percent > 100 then user.percent = 100
  if user.percent < 0 then user.percent = 0

# Splits a users interests from a comma separated string into an array
getInterests = (user, callback) ->
  interests = user.interests.toLowerCase().replace(/\s+/g, '').split(',')
  callback(null, interests)

# Returns the user matching the requestors uid
getSelf = (users, uid, callback) ->
  results = _.find(users, (user) -> user.uid == uid)
  callback(null, results)

filterUnwanted = (users, me, callback) ->
  # Remove the requestors profile from the list
  users = _.without(users, me)

  # Get a list of all users with the same last name as the
  # requestor and remove them from the list
  sameLastName = _.filter(users, (u) ->
    u.last_name.toLowerCase() == me.last_name.toLowerCase())
  users = _.difference(users, sameLastName)

  callback(null, users)

# For every interest that is also an interest of the requestor add 25%
calculateInterests = (user, selfInterests, autocb) ->
  await getInterests(user, defer(err, interests))
  matchCount = _.intersection(selfInterests, interests).length
  user.percent += matchCount * 25

# Add 20% if the user is single
calculateRelationship = (user, autocb) ->
  status = user.relationship_status.toLowerCase()
  relationships = ['married', 'engaged', 'in a relationship']
  inRelationship = _.include(relationships, status)

  if inRelationship
    user.percent -= 15
  else
    user.percent += 15

# Add 0.7% for each mutual friend
calculateFriends = (user, autocb) ->
  user.percent += (user.mutual_friend_count * 0.1)

calculateAge = (user, myAge, autocb) ->
  if myAge.getFullYear?
    myYear = myAge.getFullYear()
    userYear = user.birthday_date.getFullYear()
    user.percent -= (myYear - userYear).abs()
