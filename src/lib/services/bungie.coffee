Service = require('./service').Service

class Bungie extends Service
  @include {
    'MembershipId': '${membershipType}/Stats/GetMembershipIdByDisplayName/${name}',
    'Account': '${ membershipType }/Account/${ membershipId }',
    'AccountStats': 'Stats/Account/${ membershipType }/${ membershipId }/',
    'Character': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }',
    'Activities': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Activities',
    'ActivityHistory': 'Stats/ActivityHistory/${ membershipType }/${ membershipId }/${ characterId }',
    'CarnageReport': 'Stats/PostGameCarnageReport/${ activityId }',
    'Inventory': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Inventory',
    'Progression': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Progression'
  }

  constructor: () ->
    super 'https://www.bungie.net/Platform/Destiny', {'X-API-Key': process.env.BUNGIE_API_KEY}

  id: (name) ->
    @MembershipId({membershipType: 2, name: name}, {ignorecase: true})

  account: (membershipType, membershipId) ->
    @Account({membershipType: membershipType, membershipId: membershipId})

  character: (membershipType, membershipId, characterId) ->
    @Character({membershipType: membershipType, membershipId: membershipId, characterId: characterId})

  accountStats: (membershipType, membershipId) ->
    @AccountStats({membershipType: membershipType, membershipId: membershipId})

  activityHistory: (membershipType, membershipId, characterId) ->
    params = {mode: 5, definitions: true}
    @ActivityHistory({membershipType: membershipType, membershipId: membershipId, characterId: characterId}, params)


exports.bungie = new Bungie()