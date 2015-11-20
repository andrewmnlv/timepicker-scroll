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