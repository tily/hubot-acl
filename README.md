# hubot-acl

A hubot script for access control list.

See [`src/acl.coffee`](src/acl.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-acl --save`

Then add **hubot-acl** to your `external-scripts.json`:

```json
["hubot-acl"]
```

## Usage

Catch `acl` event to define your ACL in your hubot script.

```coffee
module.exports = (robot)->
  robot.on 'acl', (order, allow, deny)->
    # your acl settings
```

ACL can be defined in apache.conf-like style.

### Whitelisting

```coffee
robot.on 'acl', (order, allow, deny)->
  order deny, allow
  deny user: /.*/, text: /.*/
  allow user: /^a-thug$/, text: /.*/
  allow user: /^seeda$/, text: /^jenkins/
  allow user: /^bes$/, text: /^jenkins (list|last|describe)/
```

* all users are not allowed to execute all commands by default
* `a-thug` is allowed to execute all commands
* `seeda` is allowed to execute commands which begin with `jenkins`
* `bes` is allowed to execute `jenkins` read only commands (list, last, desribe)

### Blacklisting

```coffee
robot.on 'acl', (order, allow, deny)->
  order allow, deny
  allow user: /.*/, text: /.*/
  deny user: /^(bay4k|manny)$/, text: /^jenkins/
  deny user: /^sticky$/, text: /^jenkins (b|build)/
```

* all users are allowed to execute all commands by default
* `bay4k` and `manny` are not allowed to execute commands which begin with `jenkins`
* `sticky` is not allowed to execute `jenkins` build commands (b, build)

## Sample Interaction

```
Hubot> Hubot jenkins build hoge
bes: Error: you are not allowed to execute that command
```
