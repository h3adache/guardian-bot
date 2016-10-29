Service = require('./service').Service

class GG extends Service
  @include {
    'elo': 'elo/${membershipId}/'
  }

  constructor: () ->
    super 'http://api.guardian.gg'

exports.gg = new GG()