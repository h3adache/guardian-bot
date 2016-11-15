# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot pvp <playerName> - shows historical k/d/a stats for player and non deleted characters
#   hubot highscore <playerName> [mode] - shows highest kill game stats in last 250 pvp games for player and non deleted characters
#   hubot precision <playerName> - shows historical weapon kill/precision stats for player
#   hubot elo <playerName> [mode] - finds player elo optionally filtered by mode
#   hubot report <playerName> - shows last pvp activity stats for player
#   hubot chart <playerName> <mode> - shows the player k/d, elo chart for the last 5 days of mode
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
    mQuery = res.match[3]
    modeDef = findMode(mQuery)

    cfn = commandFunction(command)

    console.log "--->", modeDef[0]

    if(cfn)
      res.send "Unknown mode #{mQuery}" if modeDef[0] is -1
      cfn(res, displayName, modeDef) if modeDef[0] != -1

  commandFunction = (command) ->
    switch command
      when 'highscore' then reportBest
      when 'report' then reportLast
      when 'elo' then reportElos
      when 'pvp' then reportPvPStats
      when 'precision' then reportPrecision
      when 'chart' then reportCharts

  reportCharts = (res, displayName, modeDef) ->
    if(modeDef[0] == 5)
      res.send "must specify mode for chart"
    else
      bungie.id(displayName)
      .then (membershipId) ->
        gg.charts(membershipId, modeDef[0])
      .then (charts) ->
        chartOut = "#{displayName} #{modeDef[1]} elo / kd chart\n"
        for chart in charts
          chartOut += "#{formatDate(chart[0])} - #{chart[1]} #{chart[2].toFixed(2)}\n"
        res.send chartOut

  reportElos = (res, displayName, modeDef) ->
    bungie.id(displayName)
    .then (membershipId) ->
      if membershipId > 0
        gg.elos(membershipId, modeDef[0])
        .then (elos) ->
          if(!elos)
            res.send "#{displayName} no elo found for #{modeDef[1]}"
          else
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
      _.take(response.activities, num).forEach (activity) ->
        carnage.push "#{activity.period.substr(0, 10)} #{new Carnage(activity, response.definitions)}"
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
        console.log "comparing " + activity.activities.length + " activities"
        best = _.sortBy(activity.activities, ((d) -> d.values.kills.basic.value));
        (this.activities || this.activities = []).push best...
        this.definitions = _.merge((this.definitions || {}), activity.definitions)
    .then () ->
      best = _.sortBy(this.activities, ((d) -> d.values.kills.basic.value))
      carnage = ["Top #{num} kills for #{displayName}"]
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
    date = new Date(millis)
    (date.getUTCMonth() + 1) + "-" + date.getUTCDate() + "-" + date.getUTCFullYear()

  formatWeapon = (weaponStats) ->
    withSpacer(14, weaponStats[0]) + withSpacer(8, weaponStats[1]) + withSpacer(7, weaponStats[2]) + weaponStats[3]

  withSpacer = (spaces, text) ->
    text + spacer(spaces, text.length)

  spacer = (spaces, offset) ->
    Array(spaces - offset).join(' ')