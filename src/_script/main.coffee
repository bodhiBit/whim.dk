"use strict"
Whimdow = require "./Whimdow.coffee"

###
 main.coffee
 This script does nothing so far...
###
windows = []

init = ->
  for el in document.querySelectorAll "article"
    windows.push new Whimdow el

addEventListener "DOMContentLoaded", init
