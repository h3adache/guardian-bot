# Description:
#   Allows hubot to get destiny related information
#
# Commands:
#   hubot hi <server> - hubot-guardian: says hi back

module.exports = (robot) ->
  robot.hear /(\S*) (\S*)/i, (res) ->
    command = res.match[1]
    displayName = res.match[2]

    switch command
      when 'carnage' then res.send "carnage #{displayName}"
      when 'elo' then res.send "elo #{displayName}"
      when 'pvp' then res.send "pvp #{displayName}"

      # challenge/accept system : wip
      when 'accept' then challenge(res, res.message.room, res.message.user.name, displayName)
      when 'challenge' then challenge(res, res.message.room, res.message.user.name, displayName)

  challenge = (res, team, challenger, challenged) ->
    res.send "#{challenger} of #{team} challenged #{challenged}"
#    res.messageRoom "#{challenged}", "#{challenger} challenged #{challenged}"
