"use strict"
Whimdow = require "./Whimdow.coffee"

###
 main.coffee
 This script does nothing so far...
###
windows = []

init = ->
  time = 1000
  for el in document.querySelectorAll "article"
    time += -100
    do (_el=el) ->
      setTimeout ->
        windows.push new Whimdow _el
      , time

addEventListener "DOMContentLoaded", init
