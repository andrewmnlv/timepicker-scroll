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


  _prepareTime: ->
    hourResult = 0
    minuteResult = 0
    amPmResult = 0

    if @options.defaultTime
      [hourStart, minuteStart] = @options.defaultTime.split ':'
      hourStart = parseInt hourStart
      minuteStart = parseInt minuteStart
    else
      curDate = new Date()
      hourStart = curDate.getHours()
      minuteStart = curDate.getMinutes()
    amPmStart = 0

    hourResult = hourStart

    if hourStart > 11
      amPmStart = 1
      hourResult = hourStart % 12

    amPmResult = amPmStart

    minuteResult = minuteStart = Math.ceil minuteStart / @options.step
    console.log minutesArr = (m for m in [0...60] by @options.step)

    unless minuteStart < minutesArr.length
      minuteResult = 0
      hourResult++
      if hourResult > 11
        unless amPmStart
          hourResult = 0
          amPmStart = 1
        else
          hourResult = 11
          minuteResult = minutesArr.length - 1
        amPmResult = amPmStart

    console.log @options.defaultTime
    console.log hourResult, minuteResult * @options.step, if amPmResult then 'pm' else 'am'

    h: hourResult
    m: minuteResult
    ampm: amPmResult


  _createColumns: ->
    cfg = @_prepareTime()

    hourStart = cfg.h
    minuteStart = cfg.m
    amPmStart = cfg.ampm
    zoneStart = 0

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