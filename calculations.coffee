_ = require('underscore')

exports.filterResults = (users, uid) ->
  me = getSelf(users, uid)
  selfInterests = getInterests(me)
  users = filterUnwanted(users, me)
  for user in users
    user.percent = 0
    calculateInterests(user, selfInterests)
    calculateRelationship(user)
    calculateFriends(user)
    user.percent = 100 if user.name is "Amy Grace Standel" or user.name is "Ryan Wise"
    if user.percent > 100 then user.percent = 100
    if user.percent < 0 then user.percent = 0
  return _.sortBy(users, (user) -> user.percent).reverse()

# Splits a users interests from a comma separated string into an array
getInterests = (u) -> u.interests.toLowerCase().replace(/\s+/g, '').split(',')

# Returns the user matching the requestors uid
getSelf = (users, uid) -> _.find(users, (user) -> user.uid is uid)

filterUnwanted = (users, me) ->
  # Remove the requestors profile from the list
  users = _.without(users, me)

  # Get a list of all users with the same last name as the
  # requestor and remove them from the list
  sameLastName = _.filter(users, (u) ->
    u.last_name.toLowerCase() == me.last_name.toLowerCase())
  users = _.difference(users, sameLastName)

  return users

# For every interest that is also an interest of the requestor add 25%
calculateInterests = (user, selfInterests) ->
  matchCount = _.intersection(selfInterests, getInterests(user)).length
  user.percent += matchCount * 25

# Add 20% if the user is single
calculateRelationship = (user) ->
  status = user.relationship_status.toLowerCase()
  relationships = ['married', 'engaged', 'in a relationship']
  inRelationship = _.include(relationships, status)

  if inRelationship
    user.percent -= 10
  else
    user.percent += 10

# Add 0.7% for each mutual friend
calculateFriends = (user) ->
  user.percent += (user.mutual_friend_count * 0.7)