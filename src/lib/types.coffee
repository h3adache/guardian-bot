c = require('./consts.coffee')

class Player
  constructor: (platform, data) ->
    @platform = platform
    @memberid = data.membershipId
    @name = data.displayName
    @characters = []
    for character in data.characters
      @characters.push(character.characterBase.characterId)

  toString: ->
    "#{@name} (#{c.platforms[@platform]})"

class PlayerElo
  constructor: (data) ->
    @elo = data.elo.toFixed(1)
    @mode = data.mode
    @gamesPlayed = data.gamesPlayed
    @gamesPlayedSolo = data.gamesPlayedSolo
    @eloSolo = data.eloSolo.toFixed(1)

  toString: ->
    "#{c.modes[@mode]} #{@elo}"

class PlayerStats
  constructor: (data) ->
    @kills = data.kills.basic.value
    @assists = data.assists.basic.value
    @deaths = data.deaths.basic.value
    @kdr = data.killsDeathsRatio.basic.value.toFixed(2)
    @kda = data.killsDeathsAssists.basic.value.toFixed(2)
    @precisionKills = data.precisionKills.basic.value
    @superKills = data.weaponKillsSuper.basic.value
    @bestWeapon = data.weaponBestType.basic.displayValue

  toString: ->
    "k/d/a #{@kills}/#{@deaths}/#{@assists} (#{@kdr})/(#{@kda}) " +
    "- precision kills #{@precisionKills} " +
    "- super kills #{@superKills} " +
    "- best weapon #{@bestWeapon}"

module.exports.Player = Player
module.exports.PlayerElo = PlayerElo
module.exports.PlayerStats = PlayerStats
