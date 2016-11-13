c = require('./consts.coffee')

class Carnage
  constructor: (activity, definitions) ->
    activityDetails = activity.activityDetails
    @activityName = definitions.activities[activityDetails.referenceId].activityName
    @activityTypeName = definitions.activityTypes[activityDetails.activityTypeHashOverride].activityTypeName
    data = activity.values

    @pvpStats = new PvPStats(data)

  toString: ->
    return "#{@activityTypeName} (#{@activityName}) - " + @pvpStats.toString()

class PvPStats
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

module.exports.Carnage = Carnage
module.exports.PvPStats = PvPStats