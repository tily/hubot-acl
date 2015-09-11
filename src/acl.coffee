# Description:
#   A hubot script for access control list
#
# Author:
#   tily <tidnlyam@gmail.com>

TextListener = require("hubot").TextListener
util = require("util")
_ = require("lodash")

list = allow: [], deny: [], order: null

allow = (item)->
  list.allow.push(item)

deny = (item)->
  list.deny.push(item)

order = (first, second)->
  list.order = [arguments[0], arguments[1]]

checkList = (list, user, role, text)->
  for item in list
    flag = if text.match(item.text) then true else false
    flag = flag && (user.id in item.id) if item.id
    flag = flag && (user.name in item.name) if item.name
    flag = flag && (_.intersection(role, item.role).length > 0) if item.role
    return flag if flag
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
  robot.logger.debug "[hubot-acl] regex: " + regex

  robot.listeners.unshift new TextListener robot, regex, (msg)->
    user = msg.message.user
    text = msg.match[2]
    role = if robot.auth then robot.auth.userRoles(user) else []

    robot.logger.debug "[hubot-acl] acl check start"
    robot.logger.debug "[hubot-acl] list: " + util.inspect(list).replace(/\n/g, "")
    robot.logger.debug "[hubot-acl] target: " + "user=" + user.name + "(" + user.id + "), text=" + text

    if list.order[0] == allow and list.order[1] == deny
      robot.logger.debug "[hubot-acl] order: allow -> deny, default: deny"
      flag = false
      if checkList(list.allow, user, role, text)
        robot.logger.debug "[hubot-acl] target is allowed"
        flag = true
      if checkList(list.deny, user, role, text)
        robot.logger.debug "[hubot-acl] target is denied"
        flag = false
    else
      robot.logger.debug "[hubot-acl] order: deny -> allow, default: allow"
      flag = true
      if checkList(list.deny, user, role, text)
        robot.logger.debug "[hubot-acl] target is denied"
        flag = false
      if checkList(list.allow, user, role, text)
        robot.logger.debug "[hubot-acl] target is allowed"
        flag = true

    robot.logger.debug "[hubot-acl] acl check end: " + (if flag then "allow" else "deny")

    if !flag
      msg.reply "Error: you are not allowed to execute that command"
      msg.message.done = true

  robot.emit "acl", order, allow, deny
