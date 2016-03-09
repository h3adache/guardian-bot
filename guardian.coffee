Helper = require('./lib/helpers.coffee')
helper = new Helper

module.exports = (robot) ->
  robot.respond /elo (\S*)(\s?)(\S*)?/i, (res) ->
    modeStr = res.match[3]
    mode = helper.modeFor(robot, modeStr)
    helper.findPlayer(robot, res.match[1], (player) ->
      response = "#{player.toString()} :"
      found = false

      helper.findElo(robot, player.memberid, (playerelos) ->
        for elo in playerelos
          if !mode || `mode == elo.mode`
            response += " " + elo.toString()
            found = true

        if found
          res.reply response
        else
          res.reply "No elo found for #{player} for #{modeStr}"
      )
    )
