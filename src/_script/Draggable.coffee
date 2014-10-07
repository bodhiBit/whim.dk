"use strict"

###
  Draggable class
  For all things draggable
###
class Draggable
  Object.defineProperties @::,
    dynamicProp:
      get: -> @_dynamicProp
      set: (@_dynamicProp) ->
  
  constructor: (@mainEl) ->
    angle = -2 + 4 * do Math.random
    @mainEl.style.webkitTransform = "rotate("+angle+"deg)"
    @mainEl.style.transform = "rotate("+angle+"deg)"
    @mainEl.style.left = @mainEl.offsetLeft + "px"
    @mainEl.style.top = @mainEl.offsetTop + "px"
    requestAnimationFrame =>
      @mainEl.style.margin = "0"
      @mainEl.style.right = "auto"
      @mainEl.style.bottom = "auto"
      @mainEl.style.position = "absolute"
    
    @mainEl.addEventListener "mousedown", @_moveStart.bind @
    # @mainEl.addEventListener "touchstart", @_moveStart.bind @
    document.body.addEventListener "mousemove", @_drag.bind @
    document.body.addEventListener "touchmove", @_drag.bind @
    document.addEventListener "mouseup", @_dragEnd.bind @
    document.addEventListener "touchend", @_dragEnd.bind @
  
  _moveStart: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    pageY = e.pageY or e.changedTouches[0].pageY
    do e.preventDefault
    do e.stopPropagation
    @_mouseDragX = pageX - @mainEl.offsetLeft
    @_mouseDragY = pageY - @mainEl.offsetTop
    @_moveTO = setTimeout =>
      @mainEl.parentNode.appendChild @mainEl
      @isMoving = true
    , 250
  
  _drag: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    pageY = e.pageY or e.changedTouches[0].pageY
    if @isMoving
      @mainEl.style.left = (pageX - @_mouseDragX) + "px"
      @mainEl.style.top = (pageY - @_mouseDragY) + "px"

  _dragEnd: (e) ->
    clearTimeout @_moveTO
    if @isMoving
      requestAnimationFrame =>
        @isMoving = false

module.exports = Draggable
