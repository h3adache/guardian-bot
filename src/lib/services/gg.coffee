Service = require('./service').Service
Q = require 'q'
modes = require('../consts').modes

class GG extends Service
  @include {
    'elo': 'elo/${membershipId}/'
    'chartElo': 'chart/elo/${membershipId}/'
    'chartKD': 'chart/kd/${membershipId}/'
  }

  elos: (membershipId) ->
    deferred = Q.defer()

    @elo({membershipId: membershipId})
    .then (allElos) ->
      sortedElos = allElos.sort((a, b) -> b.elo - a.elo)
      resolvedElos = ("#{modes[elo.mode][0]} #{elo.elo.toFixed(1)}" for elo in sortedElos)
      deferred.resolve(resolvedElos.join())
    return deferred.promise

  charts: (membershipId, mode) ->
    Q.all([@chartElo({membershipId:membershipId}), @chartKD({membershipId:membershipId})])
    .spread (elos, kds) ->
      lastElos = (elos.filter (x) -> x.mode == mode)[-5..]
      lastKds = (kds.filter (x) -> x.mode == mode)[-5..]

      for i, elo of lastElos
        kd = lastKds[i]
        console.log elo.x, elo.y, kd.y

  constructor: () ->
    super 'http://api.guardian.gg'

exports.gg = new GG()