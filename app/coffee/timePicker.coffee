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
        if @curItem isnt dragItem and dragItem < @items.length
          @curItem = dragItem
          @_setActive @curItem

      _verifyPosition: (top)->
        halfHeight = pickerHeigth / 2
        columnTop = @col.position().top
        columnHeight = @col.height()
        unless columnHeight + columnTop > halfHeight
          top = halfHeight
        @col.css
          top: top

      _initEvents: ->
        @$el.on 'mousewheel', @_onMouseWheel
        @$el.on 'mousedown', @_onMouseDown
        $(window).on 'mouseup', @_onMouseUp

      _onMouseWheel: (e)=>
        top = @col.position().top + e.deltaY * @items[0].getHeight()
        @_verifyPosition(top)
        @_checkActive()

      _onMouseDown: (e)=>
        shiftY = e.pageY - @col.position().top

        moveAt = (e)=>
          top = e.pageY - shiftY
          @_verifyPosition(top)
          @_checkActive()

        document.onmousemove = (e)->
          moveAt(e)

      _onMouseUp: (e)->
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