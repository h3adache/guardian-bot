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
    getMembershipId(displayname)
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
    getMembershipId(displayname)
    .then (member) ->
      return callApi(apiurl.apply @, [member])
    .then (response) ->
      alltime = response.mergedAllCharacters.results.allPvP.allTime
      deferred.resolve(new t.PlayerStats(alltime))
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
    callApi(apiurl).then (grimoires) ->
      themeCollection = grimoires.themeCollection
      results = []

      if (Object.keys(query).length == 0)
        results.push theme.themeName for theme in themeCollection
      else if query.card
        for theme in themeCollection
          for page in theme.pageCollection
            for card in page.cardCollection
              if `card.cardId == query.card`
                payload = {
                  text: card.cardName,
                  attachments: [{
                    text: card.cardDescription,
                    thumb_url: "http://www.bungie.net" + card.normalResolution.smallImage.sheetPath,
                  }]
                }

                results.push payload
      else if query.page
        for theme in themeCollection
          if theme.themeName.toLowerCase() == query.theme.toLowerCase()
            for page in theme.pageCollection
              if page.pageName.toLowerCase() == query.page.toLowerCase()
                for card in page.cardCollection
                  intro = if card.cardIntro then card.cardIntro else ""
                  results.push "#{card.cardName}(#{card.cardId}) #{card.cardIntro}"
      else if query.theme
        for theme in themeCollection
          if theme.themeName.toLowerCase() == query.theme.toLowerCase()
            results.push page.pageName for page in theme.pageCollection

      deferred.resolve(results)


    return deferred.promise

  inspect: (displayname, item) ->
    apiurl = (player) -> "#{bungie_api}/destiny/#{player.platform}/account/#{player.memberid}"
    getMembershipId(displayname)
    .then (member) ->
      return callApi(apiurl.apply @, [member])
    .then (response) ->
      player = new t.Player(pid, response[0]) # @todo : handle same playername different platforms
      player.characters = getPlayerCharacters(robot, player)
}

getMembershipId = (displayname) ->
  deferred = new Deferred()
  apiurl = (platform, displayname) ->
    "#{bungie_api}/destiny/#{platform}/stats/getmembershipidbydisplayname/#{displayname}"
  for platform in Object.keys(c.platforms)
    callApi(apiurl.apply(@, [platform, displayname])).then (memberid) ->
      if memberid != "0"
        deferred.resolve({ memberid: memberid, platform: platform })
  return deferred.promise

callApi = (url) ->
  console.log("url : #{url}")
  deferred = new Deferred()
  options = {
    url: url,
    headers: {
      'X-API-Key': bungie_api_key
    },
    json : true
  };

  r options, (err, req, body) ->
    if body.Response
      deferred.resolve(body.Response)
    else
      deferred.resolve(body)

  return deferred.promise
