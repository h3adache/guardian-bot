Helper = require('./lib/helpers.coffee')
helper = new Helper

module.exports = (robot) ->
  robot.respond /elo (\S*)(\s?)(\S*)?/i, (res) ->
    modeStr = res.match[3]
    mode = helper.modeFor(robot, modeStr)
    player = helper.findPlayer(robot, res.match[1])
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

  robot.respond /pvp (\S*)/i, (res) ->
    player = res.match[1]
    player = helper.findPlayer(robot, res.match[1])
    stats = helper.stats(robot, player)
    console.log(stats)
    res.send "#{player.name} pvp : " + stats.toString()

  robot.respond /inspect (.*)/i, (res) ->
    query_parts = res.match[1].split " "

    if query_parts.length != 2
      res.send "usage: inspect <playername> <itemname>"
    else
      player = helper.findPlayer(robot, query_parts[0])
      for characterId in player.characters
        console.log(characterId)

# possibleNodes = talentGridDef.nodes;
