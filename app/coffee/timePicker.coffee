console.log 'rdy'

console.log " #{}"

(($, window) ->
  defaults =
    step: 5

  $.fn.timePicker = (options)->
    options = $.extend defaults, options

    pickerHeigth = 0

    class Item
      className: 'timePicker__item'
      constructor: (value, text)->
        @$el = $('<div></div>').addClass(@className).attr('value', value).text(text)

      getEl: ->
        @$el

      setInactive: ->
        @getEl().removeClass("#{@className}--active")

      setActive: ->
        @getEl().addClass("#{@className}--active")


    class Column

      columnClassName: 'timePicker__col'

      constructor: (options)->
        console.log 'init column'
        @options = $.extend {}, options
        @items = []
        @_createEl()
        @_initEvents()

      _createEl: ->
        @colWrap = $('<div></div>').addClass @columnClassName
        @col = $('<div></div>').addClass @options.className
        @_drawItems()
        @colWrap.append @col

      _drawItems: ->
        @items = []
        for num in [0..11]
          item = new Item num, num
          @items.push item
          @col.append item.getEl()

      _clearActive: ->
        for item in @items
          item.setInactive()

      _initEvents: ->
        column = @col
        setActive = (indx)=>
          @_clearActive()
          @items[indx].setActive()


        @colWrap.on 'mousewheel', (e)->
          console.log e.deltaY * 3

        @colWrap.on 'mousedown', (e)->
          self = $(this)

          shiftY = e.pageY - column.position().top

          halfHeight = pickerHeigth / 2

          x = halfHeight - column.position().top

          curItem = Math.floor x / 24

          moveAt = (e)->
            dragItem = Math.floor (halfHeight - column.position().top) / 24
            if curItem isnt dragItem
              curItem = dragItem
              setActive curItem
            column.css
              top: e.pageY - shiftY

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
      $(this).append $('<div class="timePicker__center"></div>')

      pickerHeigth = $(this).height()

    this.each make) jQuery, window