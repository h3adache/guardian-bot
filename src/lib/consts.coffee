# bungie apis
bungieApi = "https://www.bungie.net/Platform"

module.exports = {
# guardian apis
  eloSearchUrl: "http://api.guardian.gg/elo"

  memberSearchUrl: (platform, displayname) ->
    "#{bungieApi}/Destiny/SearchDestinyPlayer/#{platform}/#{displayname}"
  characterSearchUrl: (player) ->
    "#{bungieApi}/Destiny/#{player.platform}/Account/#{player.memberid}"
  accountStatsUrl: (player) ->
    "#{bungieApi}/Destiny/Stats/Account/#{player.platform}/#{player.memberid}"

  platforms: {
    1: 'Xbox'
    2: 'PlayStation'
  }
  modes: {
    9: 'Skirmish'
    10: 'Control'
    11: 'Salvage'
    12: 'Clash'
    13: 'Rumble'
    14: 'Trials of Osiris'
    15: 'Doubles'
    19: 'Iron Banner'
    23: 'Elimination'
    24: 'Rift'
    28: 'Zone Control'
    29: 'SRL'

    523: 'Crimson Doubles'
  }
}
