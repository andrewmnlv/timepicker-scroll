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

      constructor: (array, current = 0)->
        @_prepareItems array
        @_setCurrent current

      rewind: ->
        @_rewind()

      wind: ->
        @_wind()

      current: ->
        @data[@index]

      length: ->
        @data.length

      next: ->
        unless @_hasNext()
          return @_rewind()
        newIndex = @index + 1
        @_setCurrent newIndex

      prev: ->
        unless @_hasPrev()
          return @_wind()
        newIndex = @index - 1
        @_setCurrent newIndex


      each: (cb)->
        for item in @data
          cb.call null, item

      _setCurrent: (index)->
        @current().setInactive()
        @index = index
        @current().setActive()

      _prepareItems: (array)->
        @data = []
        for num in [0...array.length]
          @data.push new Item array[num], array[num]

      _hasNext: ->
        @index < @length() - 1

      _hasPrev: ->
        @index > 0

      _wind: ->
        @_setCurrent @length() - 1
        @current()

      _rewind: ->
        @_setCurrent 0
        @current()


    class ColumnView

      $el: null

      className: 'timePicker__col'

      curIndex: 0

      data: null

      isDragNow: false

      constructor: (options)->
        @options = $.extend {}, options
        @data = options.data
        @_createEl()
        @_initEvents()

      init: ->
        @_scrollToActive()

      _createEl: ->
        @$el = $('<div></div>').addClass @className
        @col = $('<div></div>').addClass @options.className
        @_drawItems()
        @$el.append @col

      _drawItems: ->
        @data.each (item)=>
          @col.append item.getEl()


      _clearActive: ->
        @data.each (item)=>
          item.setInactive()


      _scrollToActive: ->
        current = @data.current()
        halfHeight = pickerHeight / 2
        top = halfHeight - current.getEl().position().top
        #@_setTop(top - current.getHeight() / 2)
        @_setTop top

      _checkActive: ->
        itemHeight = @data.current().getHeight()
        halfHeight = pickerHeight / 2
        columnTop = @col.position().top
        dragItem = Math.floor (halfHeight - columnTop) / itemHeight
        if @curIndex isnt dragItem and dragItem < @data.length()
          @curIndex = dragItem
          if @direction < 0
            @data.next()
          else
            @data.prev()

      _verifyPosition: (top, e)->
        halfHeight = pickerHeight / 2
        columnHeight = @col.height()
        clearShiftY = false

        diff = e.pageY - @oldPosY
        @oldPosY = e.pageY
        @direction = if diff isnt 0 then diff / Math.abs(diff) else @direction

        unless columnHeight + top > halfHeight
          top = halfHeight
          clearShiftY = true

        if top > halfHeight
          top = halfHeight - columnHeight
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


    make = ()->
      $(this).addClass 'timePicker';

      pickerHeight = $(this).height()

      hoursIterator = new Column([0...12])

      #create column
      $hours = new ColumnView
        className: 'timePicker__hours'
        data: hoursIterator

      $(this).append $hours.getEl()
      $hours.init()

      minutesIterator = new Column((x for x in [0...60] by options.step || 5))

      #create column
      $minutes = new ColumnView
        className: 'timePicker__minutes'
        data: minutesIterator

      $(this).append $minutes.getEl()
      $minutes.init()

      $(this).append $('<div class="timePicker__center"></div>')


    this.each make