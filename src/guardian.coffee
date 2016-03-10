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
          res.send response
        else
          res.send "No elo found for #{player} for #{modeStr}"
      )
    )

  robot.respond /pvp (\S*)/i, (res) ->
    player = res.match[1]
    helper.findPlayer(robot, res.match[1], (player) ->
      helper.stats(robot, player, (stats) ->
        robot.logger.info(stats)
        res.send "#{player.name} pvp : " + stats.toString()
      )
    )
