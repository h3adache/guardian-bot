# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot elo <playerName> [mode] - finds player elo optionally filtered by mode
bungie = require('./lib/services/bungie').bungie
gg = require('./lib/services/gg').gg

module.exports = (robot) ->
  @client = robot.adapter.client

  robot.respond /(\S*) (\S*)/i, (res) ->
    process(res)

  robot.hear /(\S*) (\S*)/i, (res) ->
    process(res)

  process = (res) ->
    command = res.match[1].toLowerCase()
    displayName = res.match[2]

    switch command
      when 'carnage' then carnage(displayName)
      when 'elo' then showElo(res, displayName)
      when 'pvp' then pvp(displayName)
      when 'accept' then accept(res, res.message.room, res.message.user.name, displayName)
      when 'challenge' then challenge(res, res.message.room, res.message.user.name, displayName)

  challenge = (res, team, challenger, challenged) ->
    res.send "#{challenger} of #{team} challenged #{challenged}"
    robot.messageRoom "##{challenged}", "#{challenger} challenged #{challenged}"

  accept = (res, team, challenged, challenger) ->
    res.send "#{challenged} of #{team} accepted #{challenger}'s challenge"
    robot.messageRoom "#{team}", "#{challenged} accepted #{challenger}"

  showElo = (res, displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      if membershipId > 0
        gg.getElos(membershipId)
      else
        res.send "can't find user #{displayName}"
    .then (elos) ->
      res.send "#{displayName} elo - #{elos}"

  pvp = (displayName) ->
    console.log "get pvp stats for #{displayName}"

  carnage = (displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      bungie.Account({membershipType: 2, membershipId: membershipId})
    .then (account) ->
      characterId = account.characters[0].characterBase.characterId
      console.log "last played #{characterId}"
