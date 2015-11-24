do ($ = jQuery) ->
  defaults =
    step: 5

  $.fn.timePicker = (options)->
    options = $.extend defaults, options

    # @include Item.coffee

    # @include Iterator.coffee

    # @include ColumnView.coffee

    # @include Picker.coffee

    new Picker $(this).eq(0), options