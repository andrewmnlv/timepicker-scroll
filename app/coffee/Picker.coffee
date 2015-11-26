class Picker
  $el: null
  constructor: (@$el, @options)->
    @$el.addClass('timePicker').append $('<div class="timePicker__center"></div>')
    @_createColumns()
    @_setMinTime(true)

    # TODO: window ?
    @$el.on 'timePicker.change', =>
      @_setMinTime()
      if @options.onChange and typeof @options.onChange is 'function'
        @options.onChange.call null, @.getTime()

  _createColumns: ->
    hourStart = 0
    minuteStart = 0
    amPmStart = 0
    zoneStart = 0

    if @options.defaultTime
      [hourStart, minuteStart] = @options.defaultTime.split ':'
    else
      curDate = new Date()
      hourStart = curDate.getHours()
      minuteStart = curDate.getMinutes()

    if hourStart > 11
      amPmStart = 1
      hourStart = hourStart % 12

    minuteStart = Math.ceil minuteStart / @options.step
    minutesArr = (m for m in [0...60] by @options.step)
    unless minuteStart < minutesArr.length
      minuteStart = 0
      hourStart++
      if hourStart > 11
        unless amPmStart
          hourStart = 0
        else
          hourStart = 11
          console.log minuteStart = minutesArr.length - 1
          @options.minTime = '23:59'

    new ColumnView
      data: @amPmIterator = new Iterator ['am', 'pm'], amPmStart, null, @$el
      parent: @$el

    new ColumnView
      data: @hoursIterator = new Iterator [0...12], hourStart, 'hour', @$el
      parent: @$el


    @minColView = new ColumnView
      data: @minutesIterator = new Iterator (m for m in [0...60] by @options.step), minuteStart, 'minute', @$el
      parent: @$el


    #TODO: move to plugin
    zones = ['pst', 'mst', 'cst', 'est']
    if @options.tz
      zoneStart = zones.indexOf @options.tz
    new ColumnView
      data: @zonesIterator = new Iterator zones, zoneStart, null, @$el
      parent: @$el

  getTime: ->
    hour: @hoursIterator.current().getValue()
    minute: @minutesIterator.current().getValue()
    ampm: @amPmIterator.current().getValue()
    tz: @zonesIterator.current().getValue()

  setMinTime: (minTime)->
    @_setMinTime false, minTime


  _setMinTime: (init = false, minTime)->
    if minTime isnt undefined
      @options.minTime = minTime
    if init and not @options.minTime
      return
    if @options.minTime is false
      @amPmIterator.setMin(0)
      @hoursIterator.setMin(0)
      @minutesIterator.setMin(0)
      return
    ampm = 0
    [h,m] = @options.minTime.split ':'
    if h > 11
      ampm = 1
      h %= 12
    h = parseInt h
    m = Math.ceil m / @options.step

    @amPmIterator.setMin(ampm)

    if @amPmIterator.current().getValue() is 'pm' and ampm is 0
      console.log 'do nothing'
    else
      @hoursIterator.setMin(h)
      if @hoursIterator.current().getValue() is h
        @minutesIterator.setMin(m)
        if not init and @minutesIterator.getIndex() < m
          @minutesIterator.setCurrent(m)
          #TODO: events
          @minColView._scrollToActive()
      else
        @minutesIterator.setMin(0)

    if @amPmIterator.current().getValue() is 'am' and ampm is 1
      console.log 'disable all'
      @hoursIterator.setMin(12)
      @minutesIterator.setMin(60)