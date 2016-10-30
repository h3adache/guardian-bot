# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot elo <playerName> [mode] - finds player elo optionally filtered by mode
bungie = require('./lib/services/bungie').bungie
gg = require('./lib/services/gg').gg
Carnage = require('./lib/types').Carnage

module.exports = (robot) ->
  robot.respond /(\S*) (\S*)/i, (res) ->
    process(res)

  robot.hear /(\S*) (\S*)/i, (res) ->
    process(res)

  process = (res) ->
    command = res.match[1].toLowerCase()
    displayName = res.match[2]

    switch command
      when 'carnage' then showLastPvPActivityStats(res, displayName)
      when 'elo' then showElos(res, displayName)
      when 'pvp' then showPvpStats(displayName)
      when 'accept' then accept(res, res.message.room, res.message.user.name, displayName)
      when 'challenge' then challenge(res, res.message.room, res.message.user.name, displayName)

  challenge = (res, team, challenger, challenged) ->
    res.send "#{challenger} of #{team} challenged #{challenged}"
    robot.messageRoom "##{challenged}", "#{challenger} challenged #{challenged}"

  accept = (res, team, challenged, challenger) ->
    res.send "#{challenged} of #{team} accepted #{challenger}'s challenge"
    robot.messageRoom "#{team}", "#{challenged} accepted #{challenger}"

  showElos = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      if membershipId > 0
        gg.getElos(membershipId)
      else
        res.send "can't find user #{displayName}"
    .then (elos) ->
      res.send "#{displayName} elo - #{elos}"

  showPvpStats = (displayName) ->
    console.log "get pvp stats for #{displayName}"

  showLastPvPActivityStats = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.accountInfo(2, membershipId)
    .then (account) ->
      characterId = account.characters[0].characterBase.characterId
      membershipId = account.membershipId
      membershipType = account.membershipType
      bungie.lastPvpReport(membershipType, membershipId, characterId)
    .then (response) ->
      definitions = response.definitions
      lastActivity = response.activities[0]
      activityDetails = lastActivity.activityDetails
      activityDef = definitions.activities[activityDetails.referenceId]
      activityType = definitions.activityTypes[activityDetails.activityTypeHashOverride]
      activityValues = lastActivity.values
      carnage = new Carnage(activityValues)
      res.send "#{activityType.activityTypeName} (#{activityDef.activityName}) - #{carnage.toString()}"