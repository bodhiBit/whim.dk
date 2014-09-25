"use strict"
Whimdow = require "./Whimdow.coffee"

###
 main.coffee
 This script does nothing so far...
###

init = ->
  projWindow = new Whimdow document.querySelector "article#projects"

addEventListener "DOMContentLoaded", init
