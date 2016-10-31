# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot pvp <playerName> - shows historical k/d/a stats for player and non deleted characters
#   hubot precision <playerName> - shows historical weapon kill/precision stats for player
#   hubot elo <playerName> [mode] - finds player elo optionally filtered by mode
#   hubot report <playerName> - shows last pvp activity stats for player
#   hubot chart <playerName> <mode> - shows the player k/d, elo chart for the last 5 days of mode
#   hubot challenge <clan> - (WIP) if clan is any of the 4 dml clans this will send a message to said clan channel that you have challenged them
#   hubot accept <clan> - (WIP) if clan is any of the 4 dml clans this will send a message to said clan channel that you accepted said challenge
bungie = require('./lib/services/bungie').bungie
gg = require('./lib/services/gg').gg
groups = require('./lib/consts').groups
findMode = require('./lib/consts').findMode

Carnage = require('./lib/types').Carnage
PvPStats = require('./lib/types').PvPStats
Character = require('./lib/types').Character

module.exports = (robot) ->
  robot.respond /(\S*)\s+(\S*)\s*(\S*)/i, (res) ->
    process(res)

  robot.hear /(\S*)\s+(\S*)\s*(\S*)/i, (res) ->
    process(res)

  process = (res) ->
    command = res.match[1].toLowerCase()
    displayName = res.match[2]
    modeDef = findMode(res.match[3])

    switch command
      when 'report' then reportLast(res, displayName)
      when 'elo' then reportElos(res, displayName, modeDef)
      when 'pvp' then reportPvPStats(res, displayName)
      when 'precision' then reportPrecision(res, displayName)
      when 'accept' then accept(res, res.message.room, res.message.user.name, displayName)
      when 'challenge' then challenge(res, res.message.room, res.message.user.name, displayName)
      when 'chart' then reportCharts(res, displayName, modeDef)

  reportCharts = (res, displayName, modeDef) ->
    bungie.id(displayName)
    .then (membershipId) ->
      gg.charts(membershipId, modeDef[0])
    .then (charts) ->
      chartOut = "#{displayName} #{modeDef[1]} elo / kd chart\n"
      for chart in charts
        chartOut += "#{formatDate(chart[0])} - #{chart[1]} #{chart[2].toFixed(2)}\n"
      res.send chartOut

  challenge = (res, team, challenger, challenged) ->
    res.send "#{challenger} of #{team} challenged #{challenged}"
    robot.messageRoom "##{challenged}", "#{challenger} challenged #{challenged}"

  accept = (res, team, challenged, challenger) ->
    res.send "#{challenged} of #{team} accepted #{challenger}'s challenge"
    robot.messageRoom "##{team}", "#{challenged} accepted #{challenger}"

  reportElos = (res, displayName, modeDef) ->
    bungie.id(displayName)
    .then (membershipId) ->
      if membershipId > 0
        gg.elos(membershipId, modeDef[0])
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

  reportPrecision = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.accountStats(2, membershipId, groups.Weapons)
    .then (response) ->
      allWeaponStats = response.mergedAllCharacters.results.allPvP.allTime
      weaponsCollector = {}
      for statType, stats of allWeaponStats
        do (statType, stats) ->
          if /^weapon/.test statType
            weaponType = statType.substr(statType.lastIndexOf('Kills') + 5)
            addWeaponStats(weaponsCollector, weaponType, stats)

      weaponStats = Object.keys(weaponsCollector).map((key) -> weaponsCollector[key])
      weaponStats = weaponStats.filter((stats) -> stats.length > 2 && parseInt(stats[3]) > 0).sort((a, b) -> parseInt(a[3]) - parseInt(b[3]))
      
      weaponStatsOut = ['WeaponType\t(Kills, PrecisionKills, Precision %)']
      for weaponStat in weaponStats by -1
        weaponStatsOut.push formatWeapon(weaponStat)
      res.send weaponStatsOut.join('\n')

  addWeaponStats = (weaponsCollector, weaponType, stats) ->
    if not weaponsCollector[weaponType]?
      weaponsCollector[weaponType] = [weaponType]

    statIndex = switch
      when /^weaponPrecision/.test stats.statId then 2
      when /^weaponKillsPrecision/.test stats.statId then 3
      else 1

    weaponsCollector[weaponType][statIndex] = stats.basic.displayValue

  formatDate = (millis) ->
    new Date(millis).toDateString().substring(4)

  formatWeapon = (weaponStats) ->
    weaponStats[0] + Array(16 - weaponStats[0].length).join(' ') + weaponStats[1] + '\t' + weaponStats[2] + '\t' + weaponStats[3]
