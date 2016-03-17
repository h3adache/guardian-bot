c = require("./consts.coffee")
t = require('./types.coffee')
r = require("request")
Deferred = require('promise.coffee').Deferred;

bungie_api_key = process.env.BUNGIE_API_KEY

# bungie apis
bungie_api = "https://www.bungie.net/platform"

module.exports = {
    getPlayer: (displayname) ->
        apiurl = (player) -> "#{bungie_api}/destiny/#{player.platform}/account/#{player.memberid}"
        getMembershipId(displayname)
        .then (member) ->
            return callApi(apiurl.apply @, [member])
        .then (response) ->
            player = new t.Player(pid, response[0]) # @todo : handle same playername different platforms
            player.characters = getPlayerCharacters(robot, player)

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

    # http://www.bungie.net/platform/destiny/2/stats/getmembershipidbydisplayname/gchen77/
    #   memberSearchUrl: (platform, displayname) ->
    #     "#{bungieApi}/Destiny/SearchDestinyPlayer/#{platform}/#{displayname}"
    #   characterSearchUrl: (player) ->
    #     "#{bungieApi}/Destiny/#{player.platform}/Account/#{player.memberid}"
    #   accountStatsUrl: (player) ->
    #     "#{bungieApi}/Destiny/Stats/Account/#{player.platform}/#{player.memberid}"
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
