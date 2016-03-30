c = require("./consts.coffee")
t = require('./types.coffee')
r = require("request")
Deferred = require('promise.coffee').Deferred;

# bungie apis
bungie_api_key = process.env.BUNGIE_API_KEY
bungie_api = "https://www.bungie.net/platform"

module.exports = {
  findElo: (displayname) ->
    apiurl = (memberid) -> "http://api.guardian.gg/elo/#{memberid}/"
    deferred = new Deferred()
    getMember(displayname)
    .then (member) ->
      return callApi(apiurl.apply @, [member.memberid])
    .then (response) ->
      playerElos = []
      for elo in response
        playerElo = new t.PlayerElo(elo)
        playerElos.push(playerElo)

      playerElos.sort((a, b) -> a.mode - b.mode)
      deferred.resolve playerElos
    return deferred.promise

  getPvpStats: (displayname) ->
    apiurl = (player) -> "#{bungie_api}/destiny/stats/account/#{player.platform}/#{player.memberid}"
    deferred = new Deferred()

    self = @
    getMemberWithCharacters(displayname)
    .then (member) ->
      self.member = member
      return callApi(apiurl.apply @, [member])
    .then (response) ->
      stats = []
      alltime = response.mergedAllCharacters.results.allPvP.allTime
      self.member.stats = new t.PlayerStats(alltime)

      for character in response.characters
        if !character.deleted
          self.member.characters[character.characterId].stats = new t.PlayerStats(character.results.allPvP.allTime)

      deferred.resolve(self.member)
    return deferred.promise

  armsday: ->
    apiurl = "http://www.bungie.net/platform/destiny/advisors/?definitions=true"
    deferred = new Deferred()
    callApi(apiurl).then (advisors) ->
      item_definitions = advisors.definitions.items
      order_items = []

      for order in advisors.data.armsDay.orders
        order_items.push item_definitions[order.item.itemHash].itemName

      deferred.resolve order_items

    return deferred.promise

  grimoire: (query) ->
    apiurl = "http://www.bungie.net/Platform/Destiny/Vanguard/Grimoire/Definition/"
    deferred = new Deferred()
    searchTerm = query.query.toLowerCase()
    callApi(apiurl).then (grimoires) ->
      results = []
      themeCollection = grimoires.themeCollection
      for theme in themeCollection
        if (searchTerm == 'themes')
          results.push theme.themeName
        else if theme.themeName.toLowerCase() == searchTerm
          results.push page.pageName for page in theme.pageCollection
        else
          for page in theme.pageCollection
            if page.pageName.toLowerCase() == searchTerm
              for card in page.cardCollection
                intro = if card.cardIntro then card.cardIntro else ""
                results.push "#{card.cardName}(#{card.cardId}) #{card.cardIntro}"
            else
              for card in page.cardCollection
                if `card.cardId == searchTerm`
                  console.log "found card #{card.cardName}"
                  attachment = {
                    text: stripHtml(card.cardDescription),
                    fallback: card.cardDescription,
                    thumb_url: "http://www.bungie.net" + card.normalResolution.smallImage.sheetPath,
                  }
                  results.push attachment
      deferred.resolve(results)
    return deferred.promise

  carnage: (displayname) ->
    deferred = new Deferred()
    getActivityHistory(displayname, 5, true)
    .then (response) ->
      definitions = response.definitions
      activityDetails = response.data.activities[0].activityDetails
      activityValues = response.data.activities[0].values
      activityDef = definitions.activities[activityDetails.referenceId]
      activityType = definitions.activityTypes[activityDetails.activityTypeHashOverride]

      playerStats = new t.PlayerStats(activityValues)
      deferred.resolve "#{activityType.activityTypeName} (#{activityDef.activityName}) - #{playerStats.toString()}"
    return deferred.promise

  inspect: (displayname, item) ->
    # apiurl = (player) -> "#{bungie_api}/destiny/#{player.platform}/account/#{player.memberid}"
    getMemberWithCharacters(displayname)
    .then (member) ->
      for character in member.characters
        console.log character.toString()
    #   return callApi(apiurl.apply @, [member])
    # .then (response) ->
    #   player = new t.Player(pid, response[0]) # @todo : handle same playername different platforms
    #   player.characters = getMemberWithCharacters(robot, player)
}

getMember = (displayname) ->
  deferred = new Deferred()
  apiurl = (platform, displayname) ->
    "http://proxy.guardian.gg/Platform/Destiny/SearchDestinyPlayer/#{platform}/#{displayname}"
  for platform in Object.keys(c.platforms)
    callApi(apiurl.apply(@, [platform, displayname])).then (response) ->
      if response.length > 0
        deferred.resolve({ memberid: response[0].membershipId, platform: response[0].membershipType })
  return deferred.promise

getMemberWithCharacters = (displayname) ->
  deferred = new Deferred()
  self = @
  apiurl = (member) ->
    "#{bungie_api}/destiny/#{member.platform}/account/#{member.memberid}/summary"
  getMember(displayname)
  .then (member) ->
    self.member = member
    return callApi(apiurl.apply @, [member])
  .then (response) ->
    self.member.characters = {}
    for character in response.data.characters
      try
        pc = new t.PlayerCharacter(character.characterBase)
        self.member.characters[pc.characterId] = pc
      catch error
        console.error error

    deferred.resolve(self.member)
  return deferred.promise

getActivityHistory = (displayname, mode, definitions) ->
  deferred = new Deferred()
  apiurl = (c) ->
    "http://www.bungie.net/Platform/Destiny/Stats/ActivityHistory/#{c.membershipType}/#{c.membershipId}/#{c.characterId}/"
  getMemberWithCharacters(displayname)
  .then (member) ->
    return callApi(apiurl.apply(@, [member.characters[0]]), { mode:mode, definitions:definitions })
  .then (response) ->
    deferred.resolve response
  return deferred.promise

callApi = (url, params) ->
  console.log("url : #{url} / params: #{JSON.stringify params}")
  deferred = new Deferred()
  options = {
    url: url,
    headers: {
      'X-API-Key': bungie_api_key
    },
    qs: params,
    json : true
  };

  r options, (err, req, body) ->
    if body.Response
      deferred.resolve(body.Response)
    else
      deferred.resolve(body)

  return deferred.promise

stripHtml = (html) ->
  return_text = html.replace(/<style.+\/style>/g, '')
  return_text = return_text.replace(/<br ?\/?>/g, "\n\n").replace(/&nbsp;/g, ' ').replace(/[ ]+/g, ' ').replace(/%22/g, '"').replace(/&amp;/g, '&').replace(/<\/?.+?>/g, '')
  return_text = return_text.replace(/&gt;/g, '>').replace(/&lt;/g, '<')
  return return_text
