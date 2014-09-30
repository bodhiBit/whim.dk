"use strict"
Whimdow = require "./Whimdow.coffee"
Whicon = require "./Whicon.coffee"

###
 main.coffee
 Startup script for whim.dk
###
window.requestAnimationFrame ?= window.webkitRequestAnimationFrame

windows = {}

init = ->
  if window.innerWidth > 800
    do initDesktop

initDesktop = ->
  (document.querySelector "header").classList.add "docked"
  (document.querySelector "nav").classList.add "docked"
  (document.querySelector "footer").classList.add "docked"
  for el in document.querySelectorAll "article"
    windows[el.id] = new Whimdow el
  for el in document.querySelectorAll "[am-icon]"
    new Whicon el
  
  window.addEventListener "hashchange", desktopHashChange
  requestAnimationFrame desktopHashChange

desktopHashChange = ->
  name = location.hash.substr 1
  if windows[name]
    do windows[name].open
  else
    for name of windows
      do windows[name].close

if location.search isnt "?nojs"
  addEventListener "load", init
