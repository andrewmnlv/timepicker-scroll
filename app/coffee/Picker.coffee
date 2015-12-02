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


  _prepareTime: (timeString)->
    hourResult = 0
    minuteResult = 0
    amPmResult = 0
    isNextDay = false

    [hourStart, minuteStart] = timeString.split ':'
    hourStart = parseInt hourStart
    minuteStart = parseInt minuteStart

    amPmStart = 0

    hourResult = hourStart

    if hourStart > 11
      amPmStart = 1
      hourResult = hourStart % 12

    amPmResult = amPmStart

    minuteResult = minuteStart = Math.ceil minuteStart / @options.step
    minutesArr = (m for m in [0...60] by @options.step)

    unless minuteStart < minutesArr.length
      minuteResult = 0
      hourResult++
      if hourResult > 11
        unless amPmStart
          hourResult = 0
          amPmStart = 1
        else
          isNextDay = true
          hourResult = 11
          minuteResult = minutesArr.length - 1
        amPmResult = amPmStart

    h: hourResult
    m: minuteResult
    ampm: amPmResult
    isNextDay: isNextDay


  _createColumns: ->
    unless @options.defaultTime
      curDate = new Date()
      @options.defaultTime = "#{curDate.getHours()}:#{curDate.getMinutes()}"

    cfg = @_prepareTime(@options.defaultTime)

    hourStart = cfg.h
    minuteStart = cfg.m
    amPmStart = cfg.ampm
    zoneStart = 0

    @amPmColView = new ColumnView
      data: @amPmIterator = new Iterator ['am', 'pm'], amPmStart, null, @$el
      parent: @$el

    @hourColView = new ColumnView
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
    curValue = @getTime()
    hour = if curValue.ampm is "pm" then curValue.hour + 12 else curValue.hour
    if minTime and parseInt(minTime.replace(':', '')) > parseInt(hour * 100 + curValue.minute)
      cfg = @_prepareTime(minTime)
      @amPmIterator.setCurrent(cfg.ampm)
      @amPmColView._scrollToActive()
      @hoursIterator.setCurrent(cfg.h)
      @hourColView._scrollToActive()
      @minutesIterator.setCurrent(cfg.m)
      @minColView._scrollToActive()

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

    cfg = @_prepareTime @options.minTime

    ampm = cfg.ampm
    h = cfg.h
    m = cfg.m

    if cfg.isNextDay
      console.log 'next day, disable all'
      @amPmIterator.setMin(1)
      @hoursIterator.setMin(12)
      @minutesIterator.setMin(60)
      return

    @amPmIterator.setMin(ampm)

    if @amPmIterator.current().getValue() is 'pm' and ampm is 0
      console.log 'do nothing'
    else
      @hoursIterator.setMin(h)
      if h is 11 and ampm is 1 and not (m < @minutesIterator.length())
        @hoursIterator.setMin(12)
      if @hoursIterator.current().getValue() is h
        @minutesIterator.setMin(m)
        if not init and @minutesIterator.getIndex() < m
          @minutesIterator.setCurrent(m)
          #TODO: events
          @minColView._scrollToActive()
      else
        if @hoursIterator.current().getValue() < h
          @minutesIterator.setMin(60)
        else
          @minutesIterator.setMin(0)

    if @amPmIterator.current().getValue() is 'am' and ampm is 1
      console.log 'disable all'
      @hoursIterator.setMin(12)
      @minutesIterator.setMin(60)