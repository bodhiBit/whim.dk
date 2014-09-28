"use strict"
Whimdow = require "./Whimdow.coffee"

###
 main.coffee
 This script does nothing so far...
###
windows = []

init = ->
  if window.innerWidth > 800
    (document.querySelector "header").classList.add "docked"
    (document.querySelector "nav").classList.add "docked"
    (document.querySelector "footer").classList.add "docked"
    time = 1000
    for el in document.querySelectorAll "article"
      time += -100
      do (_el=el) ->
        setTimeout ->
          windows.push new Whimdow _el
        , time

if location.search isnt "?nojs"
  addEventListener "load", init
