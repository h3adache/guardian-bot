c = require('./consts.coffee')

class Player
  constructor: (platform, data) ->
    @platform = platform
    @memberid = data.membershipId
    @name = data.displayName

  toString: ->
    "#{@name} (#{@platform})"

class PlayerElo
  constructor: (data) ->
    @elo = data.elo.toFixed(1)
    @mode = data.mode
    @gamesPlayed = data.gamesPlayed
    @gamesPlayedSolo = data.gamesPlayedSolo
    @eloSolo = data.eloSolo.toFixed(1)

  toString: ->
    "#{c.modes[@mode]} #{@elo}"

module.exports.Player = Player
module.exports.PlayerElo = PlayerElo
