# Description:
#   Get destiny related information from slack
#
# Commands:
#   hubot hi <server> - hubot-guardian: says hi back
bungie = require('./lib/services/bungie').bungie
gg = require('./lib/services/gg').gg

module.exports = (robot) ->
  robot.hear /(\S*) (\S*)/i, (res) ->
    command = res.match[1]
    displayName = res.match[2]

    switch command
      when 'carnage' then carnage(displayName)
      when 'elo' then elo(displayName)
      when 'pvp' then pvp(displayName)
      when 'accept' then challenge(res, res.message.room, res.message.user.name, displayName)
      when 'challenge' then challenge(res, res.message.room, res.message.user.name, displayName)

  challenge = (res, team, challenger, challenged) ->
    res.send "#{challenger} of #{team} challenged #{challenged}"
    res.messageRoom "#{team}", "#{challenger} challenged #{challenged}"

  accept = (res, team, challenged, challenger) ->
    res.send "#{challenged} of #{team} accepted #{challenger}'s challenge"
    res.messageRoom "#{team}", "#{challenged} accepted #{challenger}" # get challengers room (brain?)

  elo = (displayName) ->
    bungie.id(displayName)
    .then (membershipId) ->
      console.log(membershipId)
      gg.elo({membershipId: membershipId})
    .then (elos) ->
      for elo in elos
        console.log "elo #{JSON.stringify(elo)}"

  pvp = (displayName) ->
    console.log "get pvp stats for #{displayName}"

  carnage = (displayName) ->
    console.log "get last carnage report for #{displayName}"