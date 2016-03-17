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

  # robot.respond /inspect (.*)/i, (res) ->
  #   query_parts = res.match[1].split " "
  #
  #   if query_parts.length != 2
  #     res.send "usage: inspect <playername> <itemname>"
  #   else
  #     api.getMembershipId(query_parts[0]).then (member) ->
  #         console.log JSON.stringify member

find_mode = (modestr) ->
    if !modestr
        return null

    for key in Object.keys(c.modes)
        values = c.modes[key]
        if modestr.toLowerCase() in values
            return key

    return -1
