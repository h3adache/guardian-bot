c = require('./consts.coffee')
t = require('./types.coffee')
Deferred = require('promise.coffee').Deferred;
r = require("request")

class Helper
  findPlayer: (robot, displayname) ->
    for pid in Object.keys(c.platforms)
      response = @callApi(robot, c.memberSearchUrl.apply @, [pid, displayname])
      if response.length > 0
        player = new t.Player(pid, response[0]) # @todo : handle same playername different platforms
        player.characters = getPlayerCharacters(robot, player)

  getPlayerCharacters: (robot, player)->
    response = callBungieApi(robot, c.characterSearchUrl.apply @, [player])
    characters = []

    if response.length > 0
      for character in response.data.characters
        characters.push(character.characterBase.characterId)

    characters

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

  stats: (robot, player, callback) ->
    response = @callApi(robot, c.accountStatsUrl.apply @, [player])
    alltime = response.mergedAllCharacters.results.allPvP.allTime
    callback(new t.PlayerStats(alltime))

  modeFor: (robot, modestr) ->
    if !modestr
      return null

    robot.logger.info("looking for #{modestr}")

    for key in Object.keys(c.modes)
      value = c.modes[key]
      if value.toLowerCase().startsWith(modestr.toLowerCase())
        return key

    # @todo : keep these in conts.
    switch modestr.toLowerCase()
      when 'ib' then return 19
      when 'tos' then return 14

    return null

  callApi: (robot, url) ->
    BUNGIE_API_KEY = process.env.BUNGIE_API_KEY

    yield r.getAsync("#{url}").get(0)
    # .header('X-API-Key', BUNGIE_API_KEY)
    # .header('Accept', 'application/json')
    # .get() (err, res, body)

    # body

module.exports = Helper
