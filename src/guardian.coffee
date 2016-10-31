# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot elo <playerName> [mode] - finds player elo optionally filtered by mode
#   hubot chart <playerName> <mode> - shows the k/d, elo chart for the last 5 days of mode
bungie = require('./lib/services/bungie').bungie
gg = require('./lib/services/gg').gg
findMode = require('./lib/consts').findMode

Carnage = require('./lib/types').Carnage
PvPStats = require('./lib/types').PvPStats
Character = require('./lib/types').Character

module.exports = (robot) ->
  robot.respond /(\S*) (\S*)/i, (res) ->
    process(res)

  robot.hear /(\S*) (\S*)/i, (res) ->
    process(res)

  robot.hear /chart (\S+)\s+(\S+)/i, (res) ->
    displayName = res.match[1]
    modeDef = findMode(res.match[2])

    bungie.id(displayName)
    .then (membershipId) ->
      gg.charts(membershipId, modeDef[0])
    .then (charts) ->
      chartOut = "#{displayName} #{modeDef[1]} elo / kd chart\n"
      for chart in charts
        chartOut += "#{formatDate(chart[0])} - #{chart[1]} #{chart[2].toFixed(2)}\n"
      res.send chartOut

  process = (res) ->
    command = res.match[1].toLowerCase()
    displayName = res.match[2]

    switch command
      when 'report' then reportLast(res, displayName)
      when 'elo' then reportElos(res, displayName)
      when 'pvp' then reportPvPStats(res, displayName)
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
        gg.elos(membershipId)
        .then (elos) ->
          res.send "#{displayName} elo - #{elos}"
      else
        res.send "can't find user #{displayName}"

  reportPvPStats = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.accountStats(2, membershipId)
      .then (accountStats) ->
        alltime = accountStats.mergedAllCharacters.results.allPvP.allTime
        res.send displayName + " - " + new PvPStats(alltime).toString()
        cfilter = (character) -> !character.deleted && character.results.allPvP.allTime
        for character in accountStats.characters.filter cfilter
          do (character) ->
            bungie.character(2, membershipId, character.characterId)
            .then (characterInfo) ->
              res.send new Character(characterInfo.characterBase) + " - " + new PvPStats(character.results.allPvP.allTime)

  reportLast = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.account(2, membershipId)
    .then (account) ->
      characterId = account.characters[0].characterBase.characterId
      membershipId = account.membershipId
      membershipType = account.membershipType
      bungie.activityHistory(membershipType, membershipId, characterId)
    .then (response) ->
      carnage = new Carnage(response.activities, response.definitions)
      res.send carnage.toString()

  formatDate = (millis) ->
    new Date(millis).toDateString().substring(4)