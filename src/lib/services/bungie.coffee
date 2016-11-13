Service = require('./service').Service
e = require('../data/extractors')

class Bungie extends Service
  @include {
    'MembershipId': 'Destiny/${membershipType}/Stats/GetMembershipIdByDisplayName/${name}',
    'BungieAccount': '/User/GetBungieAccount/${membershipId}/${membershipType}/',
    'Account': 'Destiny/${ membershipType }/Account/${ membershipId }',
    'AccountStats': 'Destiny/Stats/Account/${ membershipType }/${ membershipId }/',
    'Character': 'Destiny/${ membershipType }/Account/${ membershipId }/Character/${ characterId }',
    'Activities': 'Destiny/${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Activities',
    'ActivityHistory': 'Destiny/Stats/ActivityHistory/${ membershipType }/${ membershipId }/${ characterId }',
    'CarnageReport': 'Destiny/Stats/PostGameCarnageReport/${ activityId }',
    'Inventory': 'Destiny/${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Inventory',
    'Progression': 'Destiny/${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Progression'
  }

  constructor: () ->
    super 'https://www.bungie.net/Platform', {'X-API-Key': process.env.BUNGIE_API_KEY}

  id: (name) ->
    @MembershipId({membershipType: 2, name: name}, {ignorecase: true})

  account: (membershipType, membershipId) ->
    @Account({membershipType: membershipType, membershipId: membershipId})

  member: (name) ->
    @MembershipId({membershipType: 2, name: name}, {ignorecase: true})
    .then (membershipId) =>
      @BungieAccount({membershipType: 2, membershipId: membershipId})
    .then (bungieAccount) ->
      e.member(name, bungieAccount)

  character: (membershipType, membershipId, characterId) ->
    @Character({membershipType: membershipType, membershipId: membershipId, characterId: characterId})

  accountStats: (membershipType, membershipId, groups = 1) ->
    @AccountStats({membershipType: membershipType, membershipId: membershipId}, {groups: groups})

  activityHistory: (membershipType, membershipId, characterId, count = 200) ->
    params = {mode: 5, definitions: true, count: count}
    @ActivityHistory({membershipType: membershipType, membershipId: membershipId, characterId: characterId}, params)


exports.bungie = new Bungie()
