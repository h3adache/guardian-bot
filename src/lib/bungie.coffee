Service = require('./service').Service

class Bungie extends Service
  @include {
    'MembershipId': '${membershipType}/Stats/GetMembershipIdByDisplayName/${name}',
    'Account': '${ membershipType }/Account/${ membershipId }/',
    'Character': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/',
    'Activities': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Activities/',
    'ActivityHistory': 'Stats/ActivityHistory/${ membershipType }/${ membershipId }/${ characterId }/?definitions=true&mode=${ mode }',
    'CarnageReport': '/Stats/PostGameCarnageReport/${ activityId }/',
    'Inventory': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Inventory/',
    'Progression': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Progression/'
  }

  constructor: () ->
    super 'https://www.bungie.net/Platform/Destiny', {'X-API-Key': process.env.BUNGIE_API_KEY}

  id: (name) -> @MembershipId({membershipType: 2, name: name})

exports.bungie = new Bungie()