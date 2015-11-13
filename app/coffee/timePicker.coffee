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


    #TODO : refator class
    class Column
      data: null
      index: 0
      length: 0
      constructor: (array, current = 0)->
        @_prepareItems array
        @index = current
        @data[current].setActive()
        return {
        rewind: =>
          @_rewind()
        current: =>
          @data[@index]
        next: =>
          unless @_hasNext()
            return @_rewind()
          @data[@index].setInactive()
          @data[++@index].setActive()
          @data[@index]
        prev: =>
          unless @_hasPrev()
            return @_wind()
          @data[@index].setInactive()
          @data[--@index].setActive()
          @data[@index]
        each: (cb)=>
          for item in @data
            cb.call null, item
        }

      _prepareItems: (array)->
        @data = []
        @length = array.length
        for num in [0..@length]
          @data.push new Item num, num

      _hasNext: ->
        @index < @length

      _hasPrev: ->
        @index > 0

      _wind: ->
        @data[@index].setInactive()
        @index = @length
        @data[@index].setActive()
        @data[@index]

      _rewind: ->
        @data[@index].setInactive()
        @index = 0
        @data[@index].setActive()
        @data[@index]

    class ColumnView

      $el: null

      className: 'timePicker__col'

      curIndex: null

      data: null

      constructor: (options)->
        @options = $.extend {}, options
        @data = options.data
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
        @data.each (item)=>
          @col.append item.getEl()

      _findCurItem: ->
        itemHeight = @items[0].getHeight()
        halfHeight = pickerHeight / 2
        columnTop = @col.position().top
        shiftY = halfHeight - columnTop
        console.log @curIndex = Math.floor shiftY / itemHeight

      _clearActive: ->
        @data.each (item)=>
          item.setInactive()

      _setActive: (indx)=>
        console.log 'depr'
        return
        @curIndex = indx || 0
        @_clearActive()
        @items[@curIndex].setActive()

      _scrollToActive: ->
        current = @data.current()
        halfHeight = pickerHeight / 2
        top = halfHeight - current.getEl().position().top
        @_setTop(top - @data.current().getHeight() / 2)

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

#TODO : _.throttle
      _initEvents: ->
        @$el.on 'mousewheel', _.throttle @_onMouseWheel, 200
        @$el.on 'mousedown', @_onMouseDown

      _onMouseWheel: (e)=>
        tempIndex = @curIndex
        if e.deltaY < 0
          @data.next()
        else if e.deltaY > 0
          @data.prev()
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

      hoursIterator = new Column([0..11])

      #create column
      $hours = new ColumnView
        className: 'timePicker__hours'
        data: hoursIterator

      $(this).append $hours.getEl()
      $hours.init()

      $(this).append $('<div class="timePicker__center"></div>')


    this.each make