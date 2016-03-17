api = require('./lib/api.coffee')
c = require('./lib/consts.coffee')

module.exports = (robot) ->
  robot.respond /elo (\S*)(\s?)(\S*)?/i, (res) ->
    modeStr = res.match[3]
    displayname = res.match[1]

    api.findElo(displayname).then (playerElos) ->
      if modeStr
        mode = find_mode(modeStr)
        found = false
        for elo in playerElos
          if `elo.mode == mode`
            res.send "#{displayname}: #{elo}"
            found = true

        if not found
          res.send "no elo for #{modeStr} for player #{displayname}"
      else
        res.send "#{displayname}: #{playerElos.join()}"

  robot.respond /pvp (\S*)/i, (res) ->
    displayname = res.match[1]
    api.getPvpStats(displayname).then (stats) ->
      res.send "#{displayname} pvp : #{stats.toString()}"

  robot.respond /armsday/i, (res) ->
    api.armsday().then (arms) ->
      res.send arms.join()

  robot.respond /lure themes/i, (res) ->
    api.grimoire({}).then (themes) ->
      res.send theme for theme in themes

  robot.respond /lure pages (\S*)/i, (res) ->
    themeName = res.match[1]
    api.grimoire({theme:themeName}).then (pages) ->
      res.send page for page in pages

  robot.respond /lure cards (.*)/i, (res) ->
    query_parts = res.match[1].split "/"
    if query_parts.length < 2
      res.send "usage: lure cards <themeName>/<pageName>"
    else
      api.grimoire({theme:query_parts[0], page:query_parts[1]}).then (cards) ->
        console.log cards
        robot.emit 'slack.attachment', card for card in cards

  robot.respond /lure card (\S*)/i, (res) ->
    try
      cardId = res.match[1]
      api.grimoire({card:cardId}).then (cards) ->
        console.log JSON.stringify card for card in cards
        robot.emit 'slack.attachment', JSON.stringify card for card in cards
    catch error
      console.error error

  robot.respond /inspect (.*)/i, (res) ->
    query_parts = res.match[1].split " "

    if query_parts.length != 2
      res.send "usage: inspect <playername> <itemname>"
    else
      api.inspect(query_parts[0], query_parts[1]).then (weapons) ->
        console.log JSON.stringify weapons

find_mode = (modestr) ->
  if !modestr
    return null

  for key in Object.keys(c.modes)
    values = c.modes[key]
    if modestr.toLowerCase() in values
      return key

  return -1
