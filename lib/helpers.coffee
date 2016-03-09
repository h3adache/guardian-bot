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

      for elo in allelos
        do (elo) ->
          callback(new t.PlayerElo(elo))

module.exports = Helper
