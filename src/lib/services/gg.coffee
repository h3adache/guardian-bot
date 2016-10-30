Service = require('./service').Service
Q = require 'q'
modes = require('../consts').modes

class GG extends Service
  @include {
    'elo': 'elo/${membershipId}/'
  }

  getElos: (membershipId) ->
    deferred = Q.defer()

    @elo({membershipId: membershipId})
    .then (allElos) ->
      sortedElos = allElos.sort((a, b) -> b.elo - a.elo)
      resolvedElos = ("#{modes[elo.mode][0]} #{elo.elo.toFixed(1)}" for elo in sortedElos)
      deferred.resolve(resolvedElos.join())
    return deferred.promise

  constructor: () ->
    super 'http://api.guardian.gg'

exports.gg = new GG()