###
  Whimdow class
###
class Whimdow
  Object.defineProperties @::,
    dynamicProp:
      get: -> @_dynamicProp
      set: (@_dynamicProp) ->
  
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
    
    document.body.appendChild @windowEl
    
    @titlebarEl.addEventListener "mousedown", @_moveStart.bind @
    @resizeEl.addEventListener "mousedown", @_resizeStart.bind @
    @scrollSliderEl.addEventListener "mousedown", @_scrollStart.bind @
    @hScrollSliderEl.addEventListener "mousedown", @_hScrollStart.bind @
    document.body.addEventListener "mousemove", @_drag.bind @
    document.addEventListener "mouseup", @_dragEnd.bind @
    
    (@windowEl.querySelector '[am-scrollbutton="up"]').addEventListener "mousedown", =>
      @_autoScrollTO = setInterval =>
        @viewportEl.scrollTop += -32
      , 100
    (@windowEl.querySelector '[am-scrollbutton="down"]').addEventListener "mousedown", =>
      @_autoScrollTO = setInterval =>
        @viewportEl.scrollTop += 32
      , 100
    (@windowEl.querySelector '[am-scrollbutton="left"]').addEventListener "mousedown", =>
      @_autoScrollTO = setInterval =>
        @viewportEl.scrollLeft += -32
      , 100
    (@windowEl.querySelector '[am-scrollbutton="right"]').addEventListener "mousedown", =>
      @_autoScrollTO = setInterval =>
        @viewportEl.scrollLeft += 32
      , 100
    @windowEl.addEventListener "wheel", (e) =>
      do e.preventDefault
      unit = if e.deltaMode then 32 else 1
      @viewportEl.scrollLeft += e.deltaX * unit
      @viewportEl.scrollTop += e.deltaY * unit
      do @_updateScrollSlider
    
    requestAnimationFrame @_updateScrollSlider.bind @

  _moveStart: (e) ->
    do e.preventDefault
    @_mouseDragX = e.pageX - @windowEl.offsetLeft
    @_mouseDragY = e.pageY - @windowEl.offsetTop
    @isMoving = true
  
  _resizeStart: (e) ->
    do e.preventDefault
    @_mouseDragX = e.pageX - @windowEl.offsetLeft
    @_mouseDragY = e.pageY - @windowEl.offsetTop
    @isResizing = true
  
  _scrollStart: (e) ->
    do e.preventDefault
    @_mouseDragY = e.pageY
    @_viewportDragY = @viewportEl.scrollTop
    @_viewportScrollRatio = @contentEl.offsetHeight / @scrollShaftEl.offsetHeight
    @isScrolling = true
  
  _hScrollStart: (e) ->
    do e.preventDefault
    @_mouseDragX = e.pageX
    @_viewportDragX = @viewportEl.scrollLeft
    @_viewportScrollRatio = @contentEl.offsetWidth / @hScrollShaftEl.offsetWidth
    @isHScrolling = true
  
  _drag: (e) ->
    if @isMoving
      @windowEl.style.left = (e.pageX - @_mouseDragX) + "px"
      @windowEl.style.top = (e.pageY - @_mouseDragY) + "px"
    if @isResizing
      @windowEl.style.width = (e.pageX - @windowEl.offsetLeft - 16) + "px"
      @windowEl.style.height = (e.pageY - @windowEl.offsetTop - 16) + "px"
    if @isScrolling
      @viewportEl.scrollTop = @_viewportDragY - @_viewportScrollRatio * (@_mouseDragY - e.pageY)
      do @_updateScrollSlider
    if @isHScrolling
      @viewportEl.scrollLeft = @_viewportDragX - @_viewportScrollRatio * (@_mouseDragX - e.pageX)
      do @_updateScrollSlider

  _dragEnd: (e) ->
    if @isResizing
      @contentEl.style.width = ""
    @isMoving = false
    @isResizing = false
    @isScrolling = false
    @isHScrolling = false
    clearTimeout @_autoScrollTO
    do @_updateScrollSlider
  
  _updateScrollSlider: ->
    if not @contentEl.style.width
      scrollLeft = @viewportEl.scrollLeft
      @viewportEl.scrollLeft = 4096
      @contentEl.style.width = (@contentEl.offsetWidth + @viewportEl.scrollLeft) + "px"
      @viewportEl.scrollLeft = scrollLeft
    @scrollSliderEl.style.height  = (Math.min 100, 100 * @viewportEl.offsetHeight / @contentEl.offsetHeight) + "%"
    @scrollSliderEl.style.top     = (Math.min 100, 100 * @viewportEl.scrollTop / @contentEl.offsetHeight) + "%"
    @hScrollSliderEl.style.width  = (Math.min 100, 100 * @viewportEl.offsetWidth / @contentEl.offsetWidth) + "%"
    @hScrollSliderEl.style.left   = (Math.min 100, 100 * @viewportEl.scrollLeft / @contentEl.offsetWidth) + "%"

module.exports = Whimdow
