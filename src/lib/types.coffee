c = require('./consts.coffee')

class Player
  constructor: (data) ->
    @platform = data.membershipType
    @memberid = data.membershipId
    @name = data.displayName
    @characters = []
    @stats = null

  addCharacter: (characterBase) ->
    pc = new PlayerCharacter(characterBase)
    @characters.push(pc)

  addCharacterStats: (characterId, allPvPStats) ->
    for character in @characters
      if character.characterId == characterId
        character.stats = new Carnage(allPvPStats)

  toString: ->
    "#{@name} (#{c.platforms[@platform]})"

class PlayerCharacter
  constructor: (characterBase) ->
    @characterId = characterBase.characterId
    @powerLevel = characterBase.powerLevel
    @gender = c.genders[characterBase.genderType]
    @classtype = c.classes[characterBase.classType]
    @stats = null

  toString: ->
    "#{@gender} #{@classtype} (#{@powerLevel})"

class PlayerElo
  elo: (data) ->
    @elo = data.elo.toFixed(1)
    @mode = data.mode
    @gamesPlayed = data.gamesPlayed
    @gamesPlayedSolo = data.gamesPlayedSolo
    @eloSolo = data.eloSolo.toFixed(1)

    "#{c.modes[@mode][0]} #{@elo}"

class Carnage
  constructor: (data) ->
    if data.team
      @team = data.team.basic.displayValue
      @score = data.score.basic.value

    @kills = data.kills.basic.value
    @assists = data.assists.basic.value
    @deaths = data.deaths.basic.value
    @kdr = data.killsDeathsRatio.basic.value.toFixed(2)
    @kda = data.killsDeathsAssists.basic.value.toFixed(2)

    if data.precisionKills
      @precisionKills = data.precisionKills.basic.value
      @superKills = data.weaponKillsSuper.basic.value
      @bestWeapon = data.weaponBestType.basic.displayValue

  toString: ->
    ps = "k/d/a #{@kills}/#{@deaths}/#{@assists} (#{@kdr})/(#{@kda}) "
    if @precisionKills
      ps += "- precision kills #{@precisionKills} "
      ps += "- super kills #{@superKills} "
      ps += "- best weapon #{@bestWeapon}"

    if @score
      ps += "- score #{@score}"
      ps += " (#{@team})"

    return ps

module.exports.Player = Player
module.exports.PlayerCharacter = PlayerCharacter
module.exports.PlayerElo = PlayerElo
module.exports.Carnage = Carnage
