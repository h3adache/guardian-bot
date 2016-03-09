Helper = require('./lib/helpers.coffee')
helper = new Helper

module.exports = (robot) ->
  robot.respond /elo (.*)/i, (res) ->
    helper.findPlayer(robot, res.match[1], (player) ->
      res.reply "Looking up elo for #{player.toString()}"
      res.reply "mode elo (games played) / solo elo (solo games played)"
      helper.findElo(robot, player.memberid, (playerelo) ->
        res.reply playerelo.toString()
      )
    )
