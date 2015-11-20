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