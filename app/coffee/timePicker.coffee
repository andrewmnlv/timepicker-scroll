console.log 'rdy'

console.log " #{}"

(($, window) ->
  defaults =
    step: 5

  $.fn.timePicker = (options)->
    options = $.extend defaults, options


    class Item
      className: 'timePicker__item'
      constructor: (value, text)->
        @$el = $('<div></div>').addClass(@className).attr('value', value).text(text)

      getEl: ->
        @$el


    class Column

      columnClassName: 'timePicker__col'

      constructor: (options)->
        console.log 'init column'
        @options = $.extend {}, options
        @_createEl()
        @_initEvents()

      _createEl: ->
        @colWrap = $('<div></div>').addClass @columnClassName
        @col = $('<div></div>').addClass @options.className
        @_drawItems()
        @colWrap.append @col

      _drawItems: ->
        for num in [0..11]
          item = new Item num, num
          @col.append item.getEl()

      _initEvents: ->
        column = @col

        @colWrap.on 'mousewheel', (e)->
          console.log e.deltaY * 3

        @colWrap.on 'mousedown', (e)->
          self = $(this)

          console.log "e.pageY #{e.pageY}"

          console.log "self.offset()?.top #{self.offset()?.top}"

          shiftY = e.pageY - self.offset()?.top

          console.log "shiftY #{shiftY}"

          deltaY = e.pageY - self.offset()?.top - column.position().top

          console.log "deltaY #{deltaY}"

          moveAt = (e)->
            column.css
              top: e.pageY - self.offset()?.top - deltaY

          #moveAt(e)

          document.onmousemove = (e)->
            moveAt(e)

        $(window).on 'mouseup', ->
          document.onmousemove = null

      getEl: ->
        @colWrap


    make = ()->
      console.log $(this)

      $(this).addClass 'timePicker';

      #create column

      $hours = new Column
        className: 'timePicker__hours'

      $(this).append $hours.getEl()

    this.each make) jQuery, window