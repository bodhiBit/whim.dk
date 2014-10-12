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
  document.body.classList.add "desktop"
  for el in document.querySelectorAll "[am-icon]"
    href = (el.querySelector "a").getAttribute "href"
    new Whicon el, do (hash=href) ->
      ->
        if hash is location.hash
          do desktopHashChange
    if "#" is href.substr 0, 1
      windows[href.substr 1] = new Whimdow document.querySelector href
  new Draggable document.querySelector "header img"
  new Draggable document.querySelector "header p"
  ajaxForm document.querySelector "form"
  
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

ajaxForm = (formEl) ->
  formEl.addEventListener "submit", (e) ->
    request = new XMLHttpRequest()
    request.open "POST", formEl.getAttribute "action"
    request.responseType = "document"
    request.send new FormData formEl
    (formEl.querySelector 'input[type="submit"]').setAttribute "disabled", true
    do e.preventDefault
    request.onreadystatechange = ->
      if request.readyState is 4
        if request.status is 200
          resultWhimdow = new Whimdow (request.response.querySelector "article"), true
          do resultWhimdow.open
        else
          alert "HTTP error! Check your internet!"
