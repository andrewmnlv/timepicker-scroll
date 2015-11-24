class ColumnView

  $el: null

  className: 'timePicker__col'

  data: null

  isDragNow: false

  constructor: (options)->
    @options = $.extend {}, options
    @data = options.data
    @_createEl()
    @_initEvents()
    if @options.parent
      @getEl().appendTo @options.parent
      @_scrollToActive()
    else
      throw new Error "Specify parent element"


  _createEl: ->
    @$el = $('<div></div>').addClass @className
    @$col = $('<div></div>').addClass 'timePicker__items'
    @_drawItems()
    @$el.append @$col


  _drawItems: ->
    @data.each (item)=>
      @$col.append item.getEl()


  _scrollToActive: ->
    current = @data.current()
    halfHeight = @options.parent.height() / 2
    top = halfHeight - current.getEl().position().top
    @_setTop(top - current.getHeight() / 2)


  _checkActive: ->
    itemHeight = @data.current().getHeight()
    halfHeight = @options.parent.height() / 2
    columnTop = @$col.position().top
    dragItem = Math.floor (halfHeight - columnTop) / itemHeight
    if @data.getIndex() isnt dragItem and dragItem < @data.length()
      @data.setCurrent dragItem


  _verifyPosition: (top, e, isTouch = false)->
    halfHeight = @options.parent.height() / 2
    columnHeight = @$col.outerHeight()
    clearShiftY = false

    unless columnHeight + top > halfHeight
      top = halfHeight - 10
      clearShiftY = true

    if top > halfHeight
      top = halfHeight - columnHeight + 10
      clearShiftY = true

    if isTouch
      touch = e.originalEvent.touches[0]
      @oldPosY = touch.pageY
      if clearShiftY and e then @shiftY = touch.pageY - @$col.position().top
    else
      @oldPosY = e.pageY
      if clearShiftY and e then @shiftY = e.pageY - @$col.position().top

    @_setTop top
    @_checkActive()


  _setTop: (top)->
    @$col.css
      top: top


#TODO : _.throttle
  _initEvents: ->
    self = @

    @$el.on 'click', '.timePicker__item', ->
      if self.isItemClick
        self.data.setCurrentByValue($(this).attr('data-value'))
        self._scrollToActive()

    @$el.on 'mousewheel', _.throttle @_onMouseWheel, 200
    @$el.on 'mousedown', @_onMouseDown
    @$el.on 'touchstart', @_onTouchStart


  _onMouseWheel: (e)=>
    e.preventDefault()
    if @isDragNow
      return
    if e.deltaY < 0
      @data.next()
    else if e.deltaY > 0
      @data.prev()
    @_scrollToActive()
    return false


  _onTouchStart: (e)=>
    @isDragNow = true
    @isItemClick = true
    touch = e.originalEvent.touches[0]
    @oldPosY = touch.pageY
    @shiftY = touch.pageY - @$col.position().top

    moveAt = (e)=>
      @$col.addClass 'timePicker__notransition'
      touch = e.originalEvent.touches[0]
      top = touch.pageY - @shiftY
      @_verifyPosition(top, e, true)

    $(window).on 'touchmove.timePicker', (e)->
      e.preventDefault()
      @isItemClick = true
      moveAt(e)
      return false

    $(window).on 'touchend.timePicker', @_onMouseUp


  _onMouseDown: (e)=>
    @isDragNow = true
    @isItemClick = true
    @oldPosY = e.pageY
    @shiftY = e.pageY - @$col.position().top

    moveAt = (e)=>
      @$col.addClass 'timePicker__notransition'
      top = e.pageY - @shiftY
      @_verifyPosition(top, e)

    $(window).on 'mousemove.timePicker', (e)=>
      @isItemClick = false
      moveAt(e)

    $(window).on 'mouseup.timePicker', @_onMouseUp


  _onMouseUp: (e)=>
    @$col.removeClass 'timePicker__notransition'
    @isDragNow = false
    @_scrollToActive()
    $(window).off 'mousemove.timePicker mouseup.timePicker touchend.timePicker touchmove.timePicker'


  getEl: ->
    @$el