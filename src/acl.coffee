# Description
#   A hubot script for access control list
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   tily <tidnlyam@gmail.com>

TextListener = require('hubot').TextListener

module.exports = (robot)->
  regex = /.*/

  # https://github.com/github/hubot/blob/master/src/robot.coffee
  re = regex.toString().split('/')
  re.shift()
  modifiers = re.pop()

  pattern = re.join('/')
  name = robot.name.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')

  if robot.alias
    alias = robot.alias.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')
    newRegex = new RegExp(
      "^\\s*[@]?(?:#{alias}[:,]?|#{name}[:,]?)\\s*(?:#{pattern})"
      modifiers
    )
  else
    newRegex = new RegExp(
      "^\\s*[@]?#{name}[:,]?\\s*(?:#{pattern})",
      modifiers
    )

  robot.listeners.unshift new TextListener robot, newRegex, (msg)->
    unless robot.acl(msg)
      msg.reply "Error: you don't have permission to command that"
      msg.message.done = true
