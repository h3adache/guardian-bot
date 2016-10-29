# Description:
#   Allows hubot to get destiny related information
#
# Commands:
#   hubot hi <server> - hubot-guardian: says hi back

module.exports = (robot) ->
  robot.hear /elo (\S*)(\s?)(\S*)?/i, (res) ->
    modeStr = res.match[3] ? "all"
    displayName = res.match[1]
    res.send "Finding #{modeStr} elo for #{displayName}"

  robot.hear /challenge (\S*)?/i, (res) ->
    home = res.message.room
    away = res.match[1]

    res.send "#{home} challenged #{away}"
    res.messageRoom "#{away}", "#{home} challenged #{away}"
