"use strict"

###
  Whicon class
###
class Whicon
  Object.defineProperties @::,
    dynamicProp:
      get: -> @_dynamicProp
      set: (@_dynamicProp) ->
  
  constructor: (@iconEl, @action) ->
    @linkEl = @iconEl.querySelector "a"
    if not @linkEl.getAttribute "href"
      @linkEl.setAttribute "href", "javascript:void(0)"
    angle = -2 + 4 * do Math.random
    @iconEl.style.webkitTransform = "rotate("+angle+"deg)"
    @iconEl.style.transform = "rotate("+angle+"deg)"
    @iconEl.style.left = @iconEl.offsetLeft + "px"
    @iconEl.style.top = @iconEl.offsetTop + "px"
    requestAnimationFrame =>
      @iconEl.style.margin = "0"
      @iconEl.style.position = "absolute"
    
    @iconEl.addEventListener "mousedown", @_moveStart.bind @
    # @iconEl.addEventListener "touchstart", @_moveStart.bind @
    document.body.addEventListener "mousemove", @_drag.bind @
    document.body.addEventListener "touchmove", @_drag.bind @
    document.addEventListener "mouseup", @_dragEnd.bind @
    document.addEventListener "touchend", @_dragEnd.bind @
    @linkEl.addEventListener "click", @click.bind @
  
  click: (e) ->
    if @isMoving
      do e.preventDefault
  
  _moveStart: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    pageY = e.pageY or e.changedTouches[0].pageY
    do e.preventDefault
    @_mouseDragX = pageX - @iconEl.offsetLeft
    @_mouseDragY = pageY - @iconEl.offsetTop
    @_moveTO = setTimeout =>
      @isMoving = true
    , 250
  
  _drag: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    pageY = e.pageY or e.changedTouches[0].pageY
    do e.preventDefault
    if @isMoving
      @noClick = true
      @iconEl.style.left = (pageX - @_mouseDragX) + "px"
      @iconEl.style.top = (pageY - @_mouseDragY) + "px"

  _dragEnd: (e) ->
    clearTimeout @_moveTO
    if @isMoving
      requestAnimationFrame =>
        @isMoving = false
  

    
module.exports = Whicon
