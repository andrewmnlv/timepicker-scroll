console.log 'rdy'

(($, window) ->
  defaults =
    step: 5

  $.fn.timePicker = (options)->
    options = $.extend defaults, options

    pickerHeigth = 0

    class Item
      $el: null
      className: 'timePicker__item'
      constructor: (value, text)->
        @$el = $('<div></div>').addClass(@className).attr('value', value).text(text)

      getEl: ->
        @$el

      setInactive: ->
        @getEl().removeClass("#{@className}--active")

      setActive: ->
        @getEl().addClass("#{@className}--active")

      getHeight: ->
        @getEl().height()


    class Column

      $el: null

      className: 'timePicker__col'

      $items: null

      curItem: null

      constructor: (options)->
        @options = $.extend {}, options
        @items = []
        @_createEl()
        @_initEvents()

      _createEl: ->
        @$el = $('<div></div>').addClass @className
        @col = $('<div></div>').addClass @options.className
        @_drawItems()
        @$el.append @col

      _drawItems: ->
        @items = []
        for num in [0..11]
          item = new Item num, num
          @items.push item
          @col.append item.getEl()

      _findCurItem: ->
        itemHeight = @items[0].getHeight()
        halfHeight = pickerHeigth / 2
        columnTop = @col.position().top
        shiftY = halfHeight - columnTop
        console.log @curItem = Math.floor shiftY / itemHeight

      _clearActive: ->
        for item in @items
          item.setInactive()

      _setActive: (indx)=>
        @_clearActive()
        @items[indx].setActive()

      _checkActive: =>
        itemHeight = @items[0].getHeight()
        halfHeight = pickerHeigth / 2
        columnTop = @col.position().top
        dragItem = Math.floor (halfHeight - columnTop) / itemHeight
        if @curItem isnt dragItem
          @curItem = dragItem
          @_setActive @curItem

      _initEvents: ->
        column = @col
        setActive = @_setActive
        _checkActive = @_checkActive

        @$el.on 'mousewheel', (e)->
          console.log e.deltaY * 3

        @$el.on 'mousedown', (e)->
          self = $(this)

          shiftY = e.pageY - column.position().top

          moveAt = (e)->
            _checkActive()
            column.css
              top: e.pageY - shiftY

          document.onmousemove = (e)->
            moveAt(e)

        $(window).on 'mouseup', ->
          document.onmousemove = null

      getEl: ->
        @$el


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