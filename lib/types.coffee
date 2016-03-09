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
    @mode = c.modes[data.mode]
    @gamesPlayed = data.gamesPlayed
    @gamesPlayedSolo = data.gamesPlayedSolo
    @eloSolo = data.eloSolo.toFixed(1)

    # gamesPlayed":8,"gamesPlayedSolo":6,"mode":9,"elo":1252.5458443618131,"eloSolo"

  toString: ->
    "#{@mode} #{@elo} (#{@gamesPlayed}) / #{@eloSolo} (#{@gamesPlayedSolo})"

module.exports.Player = Player
module.exports.PlayerElo = PlayerElo
