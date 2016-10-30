# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot elo <playerName> [mode] - finds player elo optionally filtered by mode
bungie = require('./lib/services/bungie').bungie
gg = require('./lib/services/gg').gg
Carnage = require('./lib/types').Carnage
PvPStats = require('./lib/types').PvPStats

module.exports = (robot) ->
  robot.respond /(\S*) (\S*)/i, (res) ->
    process(res)

  robot.hear /(\S*) (\S*)/i, (res) ->
    process(res)

  process = (res) ->
    command = res.match[1].toLowerCase()
    displayName = res.match[2]

    switch command
      when 'report' then reportLast(res, displayName)
      when 'elo' then reportElos(res, displayName)
      when 'pvp' then reportPvPStats(displayName)
      when 'accept' then accept(res, res.message.room, res.message.user.name, displayName)
      when 'challenge' then challenge(res, res.message.room, res.message.user.name, displayName)

  challenge = (res, team, challenger, challenged) ->
    res.send "#{challenger} of #{team} challenged #{challenged}"
    robot.messageRoom "##{challenged}", "#{challenger} challenged #{challenged}"

  accept = (res, team, challenged, challenger) ->
    res.send "#{challenged} of #{team} accepted #{challenger}'s challenge"
    robot.messageRoom "#{team}", "#{challenged} accepted #{challenger}"

  reportElos = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      if membershipId > 0
        gg.getElos(membershipId)
        .then (elos) ->
          res.send "#{displayName} elo - #{elos}"
      else
        res.send "can't find user #{displayName}"

  reportPvPStats = (displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.accountStats(2, membershipId)
    .then (accountStats) ->
      alltime = accountStats.mergedAllCharacters.results.allPvP.allTime
      console.log new PvPStats(alltime).toString()

  reportLast = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.accountInfo(2, membershipId)
    .then (account) ->
      characterId = account.characters[0].characterBase.characterId
      membershipId = account.membershipId
      membershipType = account.membershipType
      bungie.lastPvpReport(membershipType, membershipId, characterId)
    .then (response) ->
      carnage = new Carnage(response.activities, response.definitions)
      res.send carnage.toString()