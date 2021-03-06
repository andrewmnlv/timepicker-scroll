class Iterator
  data: null
  index: 0
  _valueIndex: null

  constructor: (data, current = 0, @type = null, @$el)->
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

  setCurrentByValue: (value)->
    @_setCurrent(@_valueIndex[value])

  setCurrent: (index)->
    @_setCurrent(index)

  _setCurrent: (index)->
    unless index < @length()
      throw new Error "index #{index} > #{@length()}"
      return
    if @data[index].disabled
      return
    @current().unmark()
    @index = index
    @current().mark()
    $(@$el).trigger 'timePicker.change'

  _prepareItems: (array)->
    @data = []
    @_valueIndex = {}
    for num, key in array
      if @type is 'hour' or @type is 'minute'
        text = String(num + 100).substr -2
        if num is 0 and @type is 'hour' then text = 12
      else
        text = num
      @data.push new Item num, text
      @_valueIndex[num] = key

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