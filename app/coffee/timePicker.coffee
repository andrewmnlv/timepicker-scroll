console.log 'rdy'

do ($ = jQuery, window = window) ->
  defaults =
    step: 5

  $.fn.timePicker = (options)->
    options = $.extend defaults, options

    pickerHeight = 0

    class Item
      $el: null
      className: 'timePicker__item'
      constructor: (value, text)->
        @$el = $('<div></div>').addClass(@className).attr('value', value).text(text)

      getEl: ->
        @$el

      setInactive: ->
        @getEl().removeClass("#{@className}--active")

      setActive: ->
        @getEl().addClass("#{@className}--active")

      getHeight: ->
        @getEl().height()

    class Column
      data: null
      index: 0
      length: 0
      constructor: (array)->
        @data = array
        @length = array.length
        return {
        rewind: =>
          @_rewind()
        current: =>
          @data[++@index]
        next: =>
          unless @_hasNext()
            @_rewind()
          @data[++@index]
        prev: =>
          unless @_hasPrev()
            @_wind()
          @data[--@index]
        }

      _hasNext: ->
        @index < @length

      _hasPrev: ->
        @index > 0

      _wind: ->
        @index = @length

      _rewind: ->
        @index = 0

    class ColumnView

      $el: null

      className: 'timePicker__col'

      curIndex: null

      constructor: (options)->
        @options = $.extend {}, options
        @items = []
        @_createEl()
        @_initEvents()

      init: ->
        @_setActive 0
        @_scrollToActive()

      _createEl: ->
        @$el = $('<div></div>').addClass @className
        @col = $('<div></div>').addClass @options.className
        @_drawItems()
        @$el.append @col

      _drawItems: ->
        @items = []
        for num in [0..11]
          item = new Item num, num
          @items.push item
          @col.append item.getEl()

      _findCurItem: ->
        itemHeight = @items[0].getHeight()
        halfHeight = pickerHeight / 2
        columnTop = @col.position().top
        shiftY = halfHeight - columnTop
        console.log @curIndex = Math.floor shiftY / itemHeight

      _clearActive: ->
        for item in @items
          item.setInactive()

      _setActive: (indx)=>
        @curIndex = indx || 0
        @_clearActive()
        @items[@curIndex].setActive()

      _scrollToActive: ->
        halfHeight = pickerHeight / 2
        top = halfHeight - @curIndex * @items[0].getHeight()
        @_setTop(top - @items[0].getHeight() / 2)

      _checkActive: =>
        itemHeight = @items[0].getHeight()
        halfHeight = pickerHeight / 2
        columnTop = @col.position().top
        dragItem = Math.floor (halfHeight - columnTop) / itemHeight
        if @curIndex isnt dragItem and dragItem < @items.length
          @_setActive dragItem

      _verifyPosition: (top, e)->
        halfHeight = pickerHeight / 2
        columnHeight = @col.height()
        clearShiftY = false

        unless columnHeight + top > halfHeight
          top = halfHeight
          clearShiftY = true

        if top > halfHeight
          top = halfHeight - columnHeight
          clearShiftY = true

        if clearShiftY and e then @shiftY = e.pageY - @col.position().top

        @_setTop(top)

      _setTop: (top)->
        @col.css
          top: top

      _initEvents: ->
#TODO _.throttle
        @$el.on 'mousewheel', _.throttle @_onMouseWheel, 200
        @$el.on 'mousedown', @_onMouseDown

      _onMouseWheel: (e)=>
        tempIndex = @curIndex
        if e.deltaY < 0
          tempIndex++
        else if e.deltaY > 0
          tempIndex--
        if tempIndex < 0
          tempIndex = @items.length - 1
        unless tempIndex < @items.length
          tempIndex = 0
        @_setActive(tempIndex)
        @_scrollToActive()

      _onMouseDown: (e)=>
        @shiftY = e.pageY - @col.position().top

        moveAt = (e)=>
          top = e.pageY - @shiftY
          @_verifyPosition(top, e)
          @_checkActive()

        document.onmousemove = (e)->
          moveAt(e)

        $(window).on 'mouseup.timePicker', @_onMouseUp

      _onMouseUp: (e)=>
        document.onmousemove = null
        @_scrollToActive()
        $(window).off 'mouseup.timePicker'


      getEl: ->
        @$el


    make = ()->
      $(this).addClass 'timePicker';

      pickerHeight = $(this).height()

      #create column
      $hours = new ColumnView
        className: 'timePicker__hours'

      $(this).append $hours.getEl()
      $hours.init()

      $(this).append $('<div class="timePicker__center"></div>')


    this.each make