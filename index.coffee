# Description:
#   Executes Minecraft commands over RCON.
#
# Commands:
#   hubot mc <command>

{object, keys} = require "underscore"
Rcon = require "rcon"

params = ["host", "port", "pass", "boss"]
opts = do ->
  getopt = (opt) -> process.env["HUBOT_MCRCON_#{opt.toUpperCase()}"]
  object ([opt, getopt opt] for opt in params)

cmds = ["list", "say"]

module.exports = (robot) ->

  if keys(opts).length is params.length
    configure robot
  else
    robot.logger.warning "MC RCON: Invalid settings: #{JSON.stringify opts}"

configure = (robot) ->

  robot.respond /mc\s+(\w+)(?:\s+(.+))?/i, (msg) ->
    user = msg.message.user.mention_name
    cmd = msg.match[1]
    args = msg.match[2]
    if isAdmin(user) or cmd in cmds
      robot.logger.debug "MC RCON: request '#{cmd}' by '#{user}'"
      exec format(user, cmd, args), (err, result) ->
        return msg.send String(err) if err
        robot.logger.debug "MC RCON: result '#{result}' for '#{cmd}' by '#{user}'"
        msg.send result
    else
      robot.logger.debug "MC RCON: unauthorized request '#{cmd}' by '#{user}'"
      msg.send "Available commands are: #{cmds.join ', '}"

isAdmin = (user) ->
  user is opts.boss

format = (user, cmd, args) ->
  switch cmd
    when "say" then "#{cmd} [#{user}] #{args}"
    else "#{cmd}#{if args then ' ' + args else ''}"

exec = (cmd, callback) ->
  timeout = new Timeout 2000, ->
    callback "The server is not responding."
  connected = false
  rcon = Rcon opts.host, opts.port, opts.pass
  rcon.on "connect", ->
    timeout.cancel()
    connected = true
  rcon.on "auth", ->
    rcon.setTimeout 2000
    rcon.send cmd
  rcon.on "response", (str) ->
    callback null, sanitize(str)
    rcon.disconnect()
  rcon.on "error", (err) ->
    callback err
    rcon.disconnect() if connected
  rcon.on "end", ->
    connected = false
  rcon.connect()

class Timeout
  constructor: (ms, callback) ->
    @handle = setTimeout callback, ms
  cancel: ->
    clearTimeout @handle
    @handle = null

sanitize = (s) ->
  # \u0000 strips buffer chars;
  # \ufffd. may be an encoding error?
  s.replace /(\u0000)|(\ufffd.)/g, -> ""
