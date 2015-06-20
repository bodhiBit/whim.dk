"use strict"
Draggable = require "./Draggable.coffee"

###
  Whicon class
###
class Whicon extends Draggable
  constructor: (@iconEl, @action) ->
    super @iconEl
    @linkEl = @iconEl.querySelector "a"
    if not @linkEl.getAttribute "href"
      @linkEl.setAttribute "href", "javascript:void(0)"
    @linkEl.addEventListener "click", @click.bind @
  
  click: (e) ->
    if @isMoving
      do e.preventDefault
    else if @action
      @action e

module.exports = Whicon
