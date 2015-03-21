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
  allow user: /^(seeda|bes)$/, text: /^help$/
```

### Blacklisting

```coffee
robot.on 'acl', (order, allow, deny)->
  order allow, deny
  allow user: /.*/, text: /.*/
  deny user: /^(bay4k|manny)$/, text: /.*/
  deny user: /^sticky$/, text: /^jenkins/
```

## Sample Interaction

```
user1>> hubot hello
hubot>> hello!
```
