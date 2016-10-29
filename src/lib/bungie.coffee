exports.base = 'https://www.bungie.net/platform'

class Service
  @include: (services) ->
    for service, url of services
      extend = @
      do (service, url) ->
        extend::[service] = (param) -> console.log("calling #{url} with #{param}")

class Bungie extends Service
  @include {
    'Search': 'SearchDestinyPlayer/${ membershipType }/${ name }/',
    'Account': '${ membershipType }/Account/${ membershipId }/',
    'Character': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/',
    'Activities': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Activities/',
    'ActivityHistory': 'Stats/ActivityHistory/${ membershipType }/${ membershipId }/${ characterId }/?definitions=true&mode=${ mode }',
    'CarnageReport': '/Stats/PostGameCarnageReport/${ activityId }/',
    'Inventory': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Inventory/',
    'Progression': '${ membershipType }/Account/${ membershipId }/Character/${ characterId }/Progression/'
  }

module.exports.bungie = new Bungie()