class Picker
  $el: null
  constructor: (@$el, @options)->
    @$el.addClass('timePicker').append $('<div class="timePicker__center"></div>')
    @_createColumns()
    @_setMinTime(true)

    # TODO: window ?
    @$el.on 'timePicker.change', =>
      console.log 'timePicker.change'
      #console.log @.getTime()
      @_setMinTime()

  _createColumns: ->
    hourStart = 0
    minuteStart = 0
    amPmStart = 0

    if @options.defaultTime
      [hourStart, minuteStart] = @options.defaultTime.split ':'
      if hourStart > 11
        amPmStart = 1
        hourStart = hourStart % 12
      minuteStart = Math.ceil minuteStart / @options.step

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
    new ColumnView
      data: @zonesIterator = new Iterator zones, 0, null, @$el
      parent: @$el

  getTime: ->
    hour: @hoursIterator.current().getValue()
    minute: @minutesIterator.current().getValue()
    ampm: @amPmIterator.current().getValue()
    tz: @zonesIterator.current().getValue()

  _setMinTime: (init = false)->
    unless @options.minTime
      return
    ampm = 0
    [h,m] = @options.minTime.split ':'
    if h > 11
      ampm = 1
      h %= 12
    m = Math.ceil m / @options.step

    if ampm is 1
      @amPmIterator.setMin(1)

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