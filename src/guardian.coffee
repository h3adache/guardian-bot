# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot pvp <playerName> - shows historical k/d/a stats for player and non deleted characters
#   hubot highscore <playerName> [mode] - shows highest kill game stats in last 200 pvp games for player and non deleted characters
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
_ = require('lodash')._

Carnage = require('./lib/types').Carnage
PvPStats = require('./lib/types').PvPStats

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
      when 'highscore' then reportBest(res, displayName, modeDef)
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
    bungie.member(displayName)
    .bind({})
    .then (member) ->
      this.member = member
      bungie.accountStats(member.membershipType, member.membershipId)
    .then (accountStats) ->
      output = []
      alltime = accountStats.mergedAllCharacters.results.allPvP.allTime
      output.push (displayName + " - " + new PvPStats(alltime).toString())
      cfilter = (character) -> !character.deleted && character.results.allPvP.allTime
      (accountStats.characters.filter cfilter).forEach (characterInfo) =>
        character = this.member.characters[characterInfo.characterId]
        output.push (character + " - " + new PvPStats(characterInfo.results.allPvP.allTime))
      res.send output.join('\n')

  reportLast = (res, displayName) ->
    num = 3
    bungie.member(displayName)
    .then (member) ->
      bungie.activityHistory(member.membershipType, member.membershipId, member.lastCharacter)
    .then (response) ->
      carnage = ["Last #{num} Activity Report for #{displayName}"]
      response.activities[0..num-1].forEach (activity) ->
        carnage.push new Carnage(activity, response.definitions)
      res.send carnage.join('\n')

  reportBest = (res, displayName, modeDef) ->
    num = 3
    bungie.member(displayName)
    .bind({})
    .then (member) ->
      this.member = member
      return Object.keys(member.characters).map (characterId) =>
        bungie.activityHistory(member.membershipType, member.membershipId, characterId, modeDef[0])
    .each (activity) ->
      if(activity && activity.activities)
        best = _.sortBy activity.activities, (data) -> parseInt(data.values.kills.basic.value)
        this.activities = (this.activities || this.activities = []).concat(_.takeRight(best, num))
        this.definitions = _.merge((this.definitions || {}), activity.definitions)
    .then () ->
      best = _.sortBy this.activities, (activity) -> activity.values.kills.basic.value
      carnage = ["Top 3 kills for #{displayName}"]
      _.takeRight(best, num).forEach (activity) =>
        carnage.push("#{activity.period.substr(0, 10)} #{new Carnage(activity, this.definitions)}")
      res.send carnage.join('\n')

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

      weaponStatsOut = ["#{displayName}  weapon stats (Kills, PrecisionKills, Precision %)"]
      for weaponStat in weaponStats by -1
        weaponStatsOut.push formatWeapon(weaponStat)
      res.send "```" + weaponStatsOut.join('\n') + "```"

  addWeaponStats = (weaponsCollector, weaponType, stats) ->
    if not weaponsCollector[weaponType]?
      weaponsCollector[weaponType] = [weaponType]

    statIndex = switch
      when /^weaponPrecision/.test stats.statId then 2
      when /^weaponKillsPrecision/.test stats.statId then 3
      else
        1

    weaponsCollector[weaponType][statIndex] = stats.basic.displayValue

  formatDate = (millis) ->
    new Date(millis).toUTCString().substring(4)

  formatWeapon = (weaponStats) ->
    withSpacer(14, weaponStats[0]) + withSpacer(8, weaponStats[1]) + withSpacer(7, weaponStats[2]) + weaponStats[3]

  withSpacer = (spaces, text) ->
    text + spacer(spaces, text.length)

  spacer = (spaces, offset) ->
    Array(spaces - offset).join(' ')

