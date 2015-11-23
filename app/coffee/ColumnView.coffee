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
    @col = $('<div></div>').addClass 'timePicker__items'
    @_drawItems()
    @$el.append @col

  _drawItems: ->
    @data.each (item)=>
      @col.append item.getEl()


  _scrollToActive: ->
    current = @data.current()
    halfHeight = @options.parent.height() / 2
    top = halfHeight - current.getEl().position().top
    @_setTop(top - current.getHeight() / 2)
#@_setTop top

  _checkActive: ->
    itemHeight = @data.current().getHeight()
    halfHeight = @options.parent.height() / 2
    columnTop = @col.position().top
    dragItem = Math.floor (halfHeight - columnTop) / itemHeight
    if @data.getIndex() isnt dragItem and dragItem < @data.length()
      @data.setCurrent dragItem


  _verifyPosition: (top, e)->
    halfHeight = @options.parent.height() / 2
    columnHeight = @col.outerHeight()
    clearShiftY = false

    @oldPosY = e.pageY

    unless columnHeight + top > halfHeight
      top = halfHeight - 5
      clearShiftY = true

    if top > halfHeight
      top = halfHeight - columnHeight + 5
      clearShiftY = true

    if clearShiftY and e then @shiftY = e.pageY - @col.position().top

    @_setTop top
    @_checkActive()

  _setTop: (top)->
    @col.css
      top: top

#TODO : _.throttle
  _initEvents: ->
    @$el.on 'mousewheel', _.throttle @_onMouseWheel, 200
    @$el.on 'mousedown', @_onMouseDown

  _onMouseWheel: (e)=>
    if @isDragNow
      return
    if e.deltaY < 0
      @data.next()
    else if e.deltaY > 0
      @data.prev()
    @_scrollToActive()

  _onMouseDown: (e)=>
    @isDragNow = true
    @oldPosY = e.pageY
    @shiftY = e.pageY - @col.position().top

    moveAt = (e)=>
      top = e.pageY - @shiftY
      @_verifyPosition(top, e)

    document.onmousemove = (e)->
      moveAt(e)

    $(window).on 'mouseup.timePicker', @_onMouseUp

  _onMouseUp: (e)=>
    document.onmousemove = null
    @isDragNow = false
    @_scrollToActive()
    $(window).off 'mouseup.timePicker'


  getEl: ->
    @$el