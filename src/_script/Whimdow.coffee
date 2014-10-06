"use strict"

###
  Whimdow class
###
class Whimdow
  Object.defineProperties @::,
    width:
      get: ->
        @windowEl.offsetWidth +
        (@windowEl.querySelector '[am-border="w"]').offsetWidth +
        (@windowEl.querySelector '[am-border="e"]').offsetWidth
      set: (width) ->
        width += (@windowEl.querySelector '[am-border="w"]').offsetWidth
        width += (@windowEl.querySelector '[am-border="e"]').offsetWidth
        @windowEl.style.width = width + "px"
    height:
      get: ->
        @windowEl.offsetHeight +
        (@windowEl.querySelector '[am-border="n"]').offsetHeight +
        (@windowEl.querySelector '[am-border="s"]').offsetHeight
      set: (height) ->
        height += (@windowEl.querySelector '[am-border="n"]').offsetHeight
        height += (@windowEl.querySelector '[am-border="s"]').offsetHeight
        @windowEl.style.height = height + "px"
  
  lastLeftPos: 360
  lastTopPos: 48
  
  constructor: (@contentEl) ->
    @titleEl = @contentEl.querySelector "h1"
    
    @windowEl = document.createElement "x-whimdow"
    @windowEl.innerHTML = """
      <div am-border="n w"></div>
      <div am-border="n"></div>
      <div am-border="n e"></div>
      <div am-border="w"></div>
      <div am-border="e"></div>
      <div am-border="s w"></div>
      <div am-border="s"></div>
      <div am-border="s e"></div>
      <div am-titlebar>
        <button am-widget="menu icon"></button>
        <h1>Untitled</h1>
        <button am-widget="close"></button>
      </div>
      <div am-viewport>
        <article>Lorem ipsum etc...</article>
      </div>
      <div am-scrollbar="v">
        <button am-scrollbutton="up"></button>
        <div am-scrollshaft>
          <div am-scrollslider></div>
        </div>
        <button am-scrollbutton="down"></button>
      </div>
      <div am-scrollbar="h">
        <button am-scrollbutton="left"></button>
        <div am-scrollshaft>
          <div am-scrollslider></div>
        </div>
        <button am-scrollbutton="right"></button>
      </div>
    """
    @titlebarEl = @windowEl.querySelector "[am-titlebar]"
    @titlebarEl.replaceChild @titleEl, @titlebarEl.querySelector "h1"
    @viewportEl = @windowEl.querySelector "[am-viewport]"
    @viewportEl.replaceChild @contentEl, @viewportEl.querySelector "article"
    @resizeEl = @windowEl.querySelector '[am-border="s e"]'
    @scrollShaftEl = @windowEl.querySelector '[am-scrollbar~="v"] [am-scrollshaft]'
    @scrollSliderEl = @windowEl.querySelector '[am-scrollbar~="v"] [am-scrollslider]'
    @hScrollShaftEl = @windowEl.querySelector '[am-scrollbar~="h"] [am-scrollshaft]'
    @hScrollSliderEl = @windowEl.querySelector '[am-scrollbar~="h"] [am-scrollslider]'
    
    angle = -1 + 3 * do Math.random
    @windowEl.style.webkitTransform = "rotate("+angle+"deg)"
    @windowEl.style.transform = "rotate("+angle+"deg)"
    
    document.body.appendChild @windowEl
    Whimdow::lastLeftPos += 32
    Whimdow::lastTopPos += 48
    if Whimdow::lastLeftPos + @width > window.innerWidth
      Whimdow::lastLeftPos = 64
      if Whimdow::lastTopPos < 192
        Whimdow::lastTopPos = 192
    if Whimdow::lastTopPos + @height > window.innerHeight
      Whimdow::lastTopPos = 64
    @windowEl.style.left = Whimdow::lastLeftPos + "px"
    @windowEl.style.top = Whimdow::lastTopPos + "px"
      
    
    @titlebarEl.addEventListener "mousedown", @_moveStart.bind @
    @titlebarEl.addEventListener "touchstart", @_moveStart.bind @
    @resizeEl.addEventListener "mousedown", @_resizeStart.bind @
    @resizeEl.addEventListener "touchstart", @_resizeStart.bind @
    @scrollSliderEl.addEventListener "mousedown", @_scrollStart.bind @
    @scrollSliderEl.addEventListener "touchstart", @_scrollStart.bind @
    @hScrollSliderEl.addEventListener "mousedown", @_hScrollStart.bind @
    @hScrollSliderEl.addEventListener "touchstart", @_hScrollStart.bind @
    document.body.addEventListener "mousemove", @_drag.bind @
    document.body.addEventListener "touchmove", @_drag.bind @
    document.addEventListener "mouseup", @_dragEnd.bind @
    document.addEventListener "touchend", @_dragEnd.bind @
    
    (@windowEl.querySelector '[am-scrollbutton="up"]').addEventListener "mousedown", =>
      @viewportEl.scrollTop += -32
    (@windowEl.querySelector '[am-scrollbutton="down"]').addEventListener "mousedown", =>
      @viewportEl.scrollTop += 32
    (@windowEl.querySelector '[am-scrollbutton="left"]').addEventListener "mousedown", =>
      @viewportEl.scrollLeft += -32
    (@windowEl.querySelector '[am-scrollbutton="right"]').addEventListener "mousedown", =>
      @viewportEl.scrollLeft += 32
    @windowEl.addEventListener "wheel", (e) =>
      do e.preventDefault
      unit = if e.deltaMode then 32 else 1
      @viewportEl.scrollLeft += e.deltaX * unit
      @viewportEl.scrollTop += e.deltaY * unit
      do @_updateScrollSlider
    
    (@windowEl.querySelector '[am-widget="close"]').addEventListener "mouseup", @close.bind @
    (@windowEl.querySelector '[am-widget="close"]').addEventListener "touchend", @close.bind @
    
    requestAnimationFrame @_updateScrollSlider.bind @
    requestAnimationFrame @close.bind @
  
  open: ->
    @windowEl.classList.remove "closed"
    @windowEl.classList.add "open"
    scrollTop = @viewportEl.scrollTop
    scrollLeft = @viewportEl.scrollLeft
    document.body.appendChild @windowEl
    @viewportEl.scrollTop = scrollTop
    @viewportEl.scrollLeft = scrollLeft
    requestAnimationFrame @_updateScrollSlider.bind @
    
  close: ->
    @windowEl.classList.remove "open"
    @windowEl.classList.add "closed"
  
  _moveStart: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    pageY = e.pageY or e.changedTouches[0].pageY
    do e.preventDefault
    do @open
    @_mouseDragX = pageX - @windowEl.offsetLeft
    @_mouseDragY = pageY - @windowEl.offsetTop
    @isMoving = true
  
  _resizeStart: (e) ->
    do e.preventDefault
    do @open
    @isResizing = true
  
  _scrollStart: (e) ->
    pageY = e.pageY or e.changedTouches[0].pageY
    do e.preventDefault
    @_mouseDragY = pageY
    @_viewportDragY = @viewportEl.scrollTop
    @_viewportScrollRatio = @contentEl.offsetHeight / @scrollShaftEl.offsetHeight
    @isScrolling = true
  
  _hScrollStart: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    do e.preventDefault
    @_mouseDragX = pageX
    @_viewportDragX = @viewportEl.scrollLeft
    @_viewportScrollRatio = @contentEl.offsetWidth / @hScrollShaftEl.offsetWidth
    @isHScrolling = true
  
  _drag: (e) ->
    pageX = e.pageX or e.changedTouches[0].pageX
    pageY = e.pageY or e.changedTouches[0].pageY
    if @isMoving
      @windowEl.style.left = (pageX - @_mouseDragX) + "px"
      @windowEl.style.top = (pageY - @_mouseDragY) + "px"
    if @isResizing
      @windowEl.style.width = (pageX - @windowEl.offsetLeft - 16) + "px"
      @windowEl.style.height = (pageY - @windowEl.offsetTop - 16) + "px"
    if @isScrolling
      @viewportEl.scrollTop = @_viewportDragY - @_viewportScrollRatio * (@_mouseDragY - pageY)
      do @_updateScrollSlider
    if @isHScrolling
      @viewportEl.scrollLeft = @_viewportDragX - @_viewportScrollRatio * (@_mouseDragX - pageX)
      do @_updateScrollSlider

  _dragEnd: (e) ->
    if @isResizing
      @contentEl.style.width = ""
      @contentEl.style.height = ""
    @isMoving = false
    @isResizing = false
    @isScrolling = false
    @isHScrolling = false
    do @_updateScrollSlider
  
  _updateScrollSlider: ->
    if not @contentEl.style.width
      scrollLeft = @viewportEl.scrollLeft
      @viewportEl.scrollLeft = 4096
      @contentEl.style.width = (@viewportEl.offsetWidth + @viewportEl.scrollLeft) + "px"
      @viewportEl.scrollLeft = scrollLeft
    if not @contentEl.style.height
      scrollTop = @viewportEl.scrollTop
      @viewportEl.scrollTop = 40960
      @contentEl.style.height = (@viewportEl.offsetHeight + @viewportEl.scrollTop) + "px"
      @viewportEl.scrollTop = scrollTop
    @scrollSliderEl.style.height  = (Math.min 100, 100 * @viewportEl.offsetHeight / @contentEl.offsetHeight) + "%"
    @scrollSliderEl.style.top     = (Math.min 100, 100 * @viewportEl.scrollTop / @contentEl.offsetHeight) + "%"
    @hScrollSliderEl.style.width  = (Math.min 100, 100 * @viewportEl.offsetWidth / @contentEl.offsetWidth) + "%"
    @hScrollSliderEl.style.left   = (Math.min 100, 100 * @viewportEl.scrollLeft / @contentEl.offsetWidth) + "%"

module.exports = Whimdow
