Service = require('./service').Service
modes = require('../consts').modes
Promise = require('bluebird')

class GG extends Service
  @include {
    'elo': 'elo/${membershipId}/'
    'chartElo': 'chart/elo/${membershipId}/'
    'chartKD': 'chart/kd/${membershipId}/'
  }

  elos: (membershipId, mode = -1) ->
    return new Promise (resolve) =>
      @elo({membershipId: membershipId})
      .then (allElos) ->
        sortedElos = allElos.sort((a, b) -> b.elo - a.elo).filter((elo) -> elo.rank > -1 )
        if mode != -1
          sortedElos = sortedElos.filter((elo) -> elo.mode == parseInt(mode))
        resolvedElos = ("#{modes[elo.mode][0]} #{elo.elo.toFixed(1)}" for elo in sortedElos)
        resolve(resolvedElos.join())

  charts: (membershipId, mode) ->
    return new Promise (resolve) =>
      chart = []
      Promise.all([@chartElo({membershipId:membershipId}), @chartKD({membershipId:membershipId})])
      .spread (elos, kds) ->
        lastElos = (elos.filter (x) -> x.mode is parseInt(mode))
        lastKds = (kds.filter (x) -> x.mode is parseInt(mode))
        limit = Math.min(5, lastElos.length)

        for i, elo of lastElos[-limit..]
          kd = lastKds[-limit..][i]
          chart.push([elo.x, elo.y, kd.y])

        resolve(chart)

  constructor: () ->
    super 'http://api.guardian.gg'

exports.gg = new GG()
