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
      disabled: false
      constructor: (@value = null, text)->
        @$el = $('<div></div>').addClass(@className).attr('value', @value).text(text)


      getEl: ->
        @$el

      disable: ->
        @disabled = true
        @$el.addClass("#{@className}--disabled")

      enable: ->
        @disabled = false
        @$el.removeClass("#{@className}--disabled")

      unmark: ->
        @getEl().removeClass("#{@className}--active")

      mark: ->
        @getEl().addClass("#{@className}--active")

      getHeight: ->
        @getEl().outerHeight()

      getValue: ->
        @value


    class Iterator
      data: null
      index: 0

      constructor: (data, current = 0, @type = null)->
        @_prepareItems data
        @_setCurrent current

      rewind: ->
        @_rewind()

      wind: ->
        @_wind()

      current: ->
        @data[@index]

      getIndex: ->
        @index

      setMin: (min)->
        @each (item, index)->
          if index < min
            item.disable()
          else
            item.enable()

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
        for item, index in @data
          cb.call null, item, index

      setCurrent: (index)->
        @_setCurrent(index)

      _setCurrent: (index)->
        if @data[index].disabled
          return
        @current().unmark()
        @index = index
        @current().mark()
        $(window).trigger 'timePicker.change'

      _prepareItems: (array, type)->
        @data = []
        for num in array
          text = num
          if text is 0
            switch type
              when 'hour' then text = 12
              when 'minute' then text = '00'
          @data.push new Item num, text

      _hasNext: ->
        @index < @length() - 1 and (@data[@index + 1] and not @data[@index + 1]?.disabled)

      _hasPrev: ->
        @index > 0 and not @data[@index - 1].disabled

      _wind: ->
        @_setCurrent @length() - 1
        @current()

      _rewind: ->
        index = null
        for it, idx in @data
          unless it.disabled
            index = idx
            break

        if index isnt null
          @_setCurrent index
        @current()


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
        halfHeight = pickerHeight / 2
        top = halfHeight - current.getEl().position().top
        @_setTop(top - current.getHeight() / 2)
#@_setTop top

      _checkActive: ->
        itemHeight = @data.current().getHeight()
        halfHeight = pickerHeight / 2
        columnTop = @col.position().top
        dragItem = Math.floor (halfHeight - columnTop) / itemHeight
        if @data.getIndex() isnt dragItem and dragItem < @data.length()
          @data.setCurrent dragItem


      _verifyPosition: (top, e)->
        halfHeight = pickerHeight / 2
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


    class Picker
      $el: null
      constructor: (@$el)->
        @$el.addClass('timePicker').append $('<div class="timePicker__center"></div>')
        pickerHeight = @$el.height()
        @_createColumns()
        @setMinTime()

      _createColumns: ->
        hourStart = 0
        minuteStart = 0
        amPmStart = 0

        if options.defaultTime
          [hourStart, minuteStart] = options.defaultTime.split ':'
          if hourStart > 11
            amPmStart = 1
            hourStart = hourStart % 12
          minuteStart = Math.ceil minuteStart / options.step

        new ColumnView
          data: @amPmIterator = new Iterator ['am', 'pm'], amPmStart
          parent: @$el

        new ColumnView
          data: @hoursIterator = new Iterator([0...12], hourStart, 'hour')
          parent: @$el


        new ColumnView
          data: @minutesIterator = new Iterator((m for m in [0...60] by options.step), minuteStart, 'minute')
          parent: @$el


        #TODO: move to plugin
        zones = ['pst', 'mst', 'cst', 'est']
        new ColumnView
          data: @zonesIterator = new Iterator zones
          parent: @$el

      getTime: ->
        hour: @hoursIterator.current().getValue()
        minute: @minutesIterator.current().getValue()
        ampm: @amPmIterator.current().getValue()
        tz: @zonesIterator.current().getValue()

      setMinTime: ->
        unless options.minTime
          return
        ampm = 0
        [h,m] = options.minTime.split ':'
        if h > 11
          ampm = 1
          h %= 12
        m = Math.ceil m / options.step

        if ampm is 1
          @amPmIterator.setMin(1)

        if @amPmIterator.current().getValue() is 'pm' and ampm is 0
          console.log 'do nothing'
        else
          @hoursIterator.setMin(h)
          if @hoursIterator.current().getValue() is h
            @minutesIterator.setMin(m)
          else
            @minutesIterator.setMin(0)

        if @amPmIterator.current().getValue() is 'am' and ampm is 1
          console.log 'disable all'
          @hoursIterator.setMin(12)
          @minutesIterator.setMin(60)


    make = ()->
      picker = new Picker $(this)


      # TODO: window ?
      $(window).on 'timePicker.change', ->
        console.log 'timePicker.change'
        #console.log picker.getTime()
        picker.setMinTime()


    this.each make