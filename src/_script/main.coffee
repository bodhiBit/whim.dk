"use strict"
Whimdow = require "./Whimdow.coffee"
Whicon = require "./Whicon.coffee"
Draggable = require "./Draggable.coffee"

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
  for el in document.querySelectorAll "[am-icon]"
    new Whicon el
    href = (el.querySelector "a").getAttribute "href"
    if "#" is href.substr 0, 1
      windows[href.substr 1] = new Whimdow document.querySelector href
  new Draggable document.querySelector "header img"
  new Draggable document.querySelector "header p"
  
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
