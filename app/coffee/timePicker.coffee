console.log 'rdy'

do ($ = jQuery, window = window) ->
  defaults =
    step: 5

  $.fn.timePicker = (options)->
    options = $.extend defaults, options

    pickerHeight = 0

    # @include Item.coffee

    # @include Iterator.coffee

    # @include ColumnView.coffee

    # @include Picker.coffee

    make = ()->
      picker = new Picker $(this)


      # TODO: window ?
      $(window).on 'timePicker.change', ->
        console.log 'timePicker.change'
        #console.log picker.getTime()
        picker.setMinTime()


    this.each make