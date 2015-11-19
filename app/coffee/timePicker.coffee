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
      constructor: (@value = null, text, @disabled = false)->
        @$el = $('<div></div>').addClass(@className).attr('value', @value).text(text)
        if @disabled
          @$el.addClass("#{@className}--disabled")

      getEl: ->
        @$el

      setInactive: ->
        @getEl().removeClass("#{@className}--active")

      setActive: ->
        @getEl().addClass("#{@className}--active")

      getHeight: ->
        @getEl().outerHeight()

      getValue: ->
        @value


    class Column
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

      setCurrent: (index)->
        @_setCurrent(index)

      _setCurrent: (index)->
        if @data[index].disabled
          return
        @current().setInactive()
        @index = index
        @current().setActive()
        $(window).trigger 'timePicker.change'

      _prepareItems: (array, type)->
        @data = []
        for num in array
          text = num.value
          if text is 0
            switch type
              when 'hour' then text = 12
              when 'minute' then text = '00'
          @data.push new Item num.value, text, num.disabled

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


    make = ()->
      $(this).addClass 'timePicker';

      hourStart = 0
      minuteStart = 0
      amPmStart = 0
      zones = ['pst', 'mst', 'cst', 'est']
      zoneStart = 0
      step = options.step || 5


      if options.defaultTime
        defaultTime = options.defaultTime.split ':'
        hourStart = defaultTime[0]
        if hourStart > 11
          amPmStart = 1
          hourStart = hourStart % 12
        minuteStart = Math.ceil defaultTime[1] / step
      if options.tz
        zoneStart = zones.indexOf options.tz

      if options.minTime
        console.log options.minTime

      pickerHeight = $(this).height()

      hourArr = []
      for h in [0...12]
        hourArr.push
          value: h
#disabled: false
          disabled: h < 5

      hoursIterator = new Column(hourArr, hourStart, 'hour')
      #create column
      $hours = new ColumnView
        className: 'timePicker__hours'
        data: hoursIterator
      $(this).append $hours.getEl()
      $hours.init()


      minutesArr = []
      for m in [0...60] by step
        minutesArr.push
          value: m
#disabled: false
          disabled: m < 30

      minutesIterator = new Column(minutesArr, minuteStart, 'minute')
      #create column
      $minutes = new ColumnView
        className: 'timePicker__minutes'
        data: minutesIterator
      $(this).append $minutes.getEl()
      $minutes.init()


      amPmArr = []
      for m in ['am', 'pm']
        amPmArr.push
          value: m
          disabled: false

      amPmIterator = new Column amPmArr, amPmStart
      #create column
      $amPm = new ColumnView
        className: 'timePicker__minutes'
        data: amPmIterator
      $(this).append $amPm.getEl()
      $amPm.init()


      zonesArr = []
      for m in ['pst', 'mst', 'cst', 'est']
        zonesArr.push
          value: m
          disabled: false

      tzIterator = new Column zonesArr, zoneStart
      #create column
      $tz = new ColumnView
        className: 'timePicker__minutes'
        data: tzIterator
      $(this).append $tz.getEl()
      $tz.init()


      $(this).append $('<div class="timePicker__center"></div>')

      getTime = ->
        hour: hoursIterator.current().getValue()
        minute: minutesIterator.current().getValue()
        ampm: amPmIterator.current().getValue()
        tz: tzIterator.current().getValue()


      # TODO: window ?
      $(window).on 'timePicker.change', ->
        console.log 'timePicker.change'
        #console.log getTime()


    this.each make