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
  allow id: [1], text: /.*/
  allow id: [2], text: /^jenkins/
  allow id: [3], text: /^jenkins (list|last|describe)/
```

* all users are not allowed to execute all commands by default
* user (id=1) is allowed to execute all commands
* user (id=2) is allowed to execute commands which begin with `jenkins`
* user (id=3) is allowed to execute `jenkins` read only commands (list, last, desribe)

### Blacklisting

```coffee
robot.on 'acl', (order, allow, deny)->
  order allow, deny
  allow text: /.*/
  deny name: ['bay4k', 'manny'], text: /^jenkins/
  deny name: ['sticky'], text: /^jenkins (b|build)/
```

* all users are allowed to execute all commands by default
* user (whose name is `bay4k` or `manny`) are not allowed to execute commands which begin with `jenkins`
* user (whose name is `sticky`) is not allowed to execute `jenkins` build commands (b, build)

## working with hubot-acl

```
robot.on 'acl', (order, allow, deny)->
  order deny, allow
  deny user: /.*/, text: /.*/
  allow role: ['admin'], text: /.*/
  allow role: ['jenkins'], text: /^jenkins/
  allow role: ['jenkins-readonly'], text: /^jenkins (list|last|describe)/
```

## Sample Interaction

```
Hubot> Hubot jenkins build hoge
bes: Error: you are not allowed to execute that command
```
