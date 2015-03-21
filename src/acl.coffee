# Description:
#   A hubot script for access control list
#
# Author:
#   tily <tidnlyam@gmail.com>

TextListener = require("hubot").TextListener

list = allow: [], deny: [], order: null

allow = (params)->
  list.allow.push(params)

deny = (params)->
  list.deny.push(params)

order = (first, second)->
  list.order = arguments

checkList = (list, user, text)->
  for params in list
    if user.match(params.user) && text.match(params.text)
      return true
  false

# create regex that matches any possible replies
# modified version of Robot#respond regex
regex = (robot)->
  regex = /.*/

  re = regex.toString().split("/")
  re.shift()
  modifiers = re.pop()

  pattern = re.join("/")
  name = robot.name.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")

  if robot.alias
    alias = robot.alias.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
    newRegex = new RegExp(
      "^\\s*[@]?(?:#{alias}[:,]?|#{name}[:,]?)\\s*(#{pattern})"
      modifiers
    )
  else
    newRegex = new RegExp(
      "^\\s*[@]?#{name}[:,]?\\s*(#{pattern})",
      modifiers
    )
  newRegex

module.exports = (robot)->
  regex = regex(robot)
  robot.logger.debug "[hubot-acl] regex: "

  robot.listeners.unshift new TextListener robot, regex, (msg)->
    user = msg.message.user.name
    text = msg.match[1]

    robot.logger.debug "[hubot-acl] acl check start"
    robot.logger.debug "[hubot-acl] list: " + list
    robot.logger.debug "[hubot-acl] target: " + "user=" + user + " , text=" + text

    if list.order is [allow, deny]
      robot.logger.debug "[hubot-acl] order: allow -> deny, default: deny"
      flag = false
      if checkList(list.allow, user, text)
        robot.logger.debug "[hubot-acl] target is allowed"
        flag = true
      if checkList(list.deny, user, text)
        robot.logger.debug "[hubot-acl] target is denied"
        flag = false
    else
      robot.logger.debug "[hubot-acl] order: deny -> allow, default: allow"
      flag = true
      if checkList(list.deny, user, text)
        robot.logger.debug "[hubot-acl] target is denied"
        flag = false
      if checkList(list.allow, user, text)
        robot.logger.debug "[hubot-acl] target is allowed"
        flag = true

    robot.logger.debug "[hubot-acl] acl check end: " + (if flag then "allow" else "deny")

    if !flag
      msg.reply "Error: you are not allowed to execute that command"
      msg.message.done = true

  robot.emit "acl", order, allow, deny
