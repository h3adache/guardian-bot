c = require('./consts.coffee')
t = require('./types.coffee')

class Helper
  findPlayer: (robot, player, callback) ->
    for pid in Object.keys(c.platforms)
      do(pid) ->
        robot.http("#{c.memberSearchUrl}/#{pid}/#{player}/")
        .header('Accept', 'application/json')
        .get() (eloerr, elores, body) ->
          data = JSON.parse body
          if data.Response.length > 0

            platform = c.platforms[pid]
            callback(new t.Player(platform, data.Response[0]))

  findElo: (robot, memberid, callback) ->
    robot.http("#{c.eloSearchUrl}/#{memberid}/")
    .header('Accept', 'application/json')
    .get() (eloerr, elores, body) ->
      allelos = JSON.parse body
      playerElos = []
      for elo in allelos
        do (elo) ->
          playerElo = new t.PlayerElo(elo)
          playerElos.push(playerElo)

      playerElos.sort((a, b) -> a.mode - b.mode)

      callback(playerElos)

  modeFor: (robot, modestr) ->
    if !modestr
      return null

    robot.logger.info("looking for #{modestr}")

    for key in Object.keys(c.modes)
      value = c.modes[key]
      if modestr.toLowerCase() == value.toLowerCase()
        return key

    switch modestr.toLowerCase()
      when 'ib' then return 19
      when 'tos' then return 14

    return null

module.exports = Helper
