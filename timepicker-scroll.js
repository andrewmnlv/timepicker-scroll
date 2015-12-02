(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function($) {
    var defaults;
    defaults = {
      step: 5,
      minTime: false
    };
    return $.fn.timePicker = function(options) {
      var ColumnView, Item, Iterator, Picker;
      options = $.extend(defaults, options);
      Item = (function() {
        Item.prototype.$el = null;

        Item.prototype.className = 'timePicker__item';

        Item.prototype.disabled = false;

        function Item(value1, text) {
          this.value = value1 != null ? value1 : null;
          this.$el = $('<div></div>').addClass(this.className).attr('data-value', this.value).text(text);
        }

        Item.prototype.getEl = function() {
          return this.$el;
        };

        Item.prototype.disable = function() {
          this.disabled = true;
          return this.$el.addClass(this.className + "--disabled");
        };

        Item.prototype.enable = function() {
          this.disabled = false;
          return this.$el.removeClass(this.className + "--disabled");
        };

        Item.prototype.unmark = function() {
          return this.getEl().removeClass(this.className + "--active");
        };

        Item.prototype.mark = function() {
          return this.getEl().addClass(this.className + "--active");
        };

        Item.prototype.getHeight = function() {
          return this.getEl().outerHeight();
        };

        Item.prototype.getValue = function() {
          return this.value;
        };

        return Item;

      })();
      Iterator = (function() {
        Iterator.prototype.data = null;

        Iterator.prototype.index = 0;

        Iterator.prototype._valueIndex = null;

        function Iterator(data, current, type, $el) {
          if (current == null) {
            current = 0;
          }
          this.type = type != null ? type : null;
          this.$el = $el;
          this._prepareItems(data);
          this._setCurrent(current);
        }

        Iterator.prototype.rewind = function() {
          return this._rewind();
        };

        Iterator.prototype.wind = function() {
          return this._wind();
        };

        Iterator.prototype.current = function() {
          return this.data[this.index];
        };

        Iterator.prototype.getIndex = function() {
          return this.index;
        };

        Iterator.prototype.setMin = function(min) {
          return this.each(function(item, index) {
            if (index < min) {
              return item.disable();
            } else {
              return item.enable();
            }
          });
        };

        Iterator.prototype.length = function() {
          return this.data.length;
        };

        Iterator.prototype.next = function() {
          var newIndex;
          if (!this._hasNext()) {
            return this._rewind();
          }
          newIndex = this.index + 1;
          return this._setCurrent(newIndex);
        };

        Iterator.prototype.prev = function() {
          var newIndex;
          if (!this._hasPrev()) {
            return this._wind();
          }
          newIndex = this.index - 1;
          return this._setCurrent(newIndex);
        };

        Iterator.prototype.each = function(cb) {
          var i, index, item, len, ref, results;
          ref = this.data;
          results = [];
          for (index = i = 0, len = ref.length; i < len; index = ++i) {
            item = ref[index];
            results.push(cb.call(null, item, index));
          }
          return results;
        };

        Iterator.prototype.setCurrentByValue = function(value) {
          return this._setCurrent(this._valueIndex[value]);
        };

        Iterator.prototype.setCurrent = function(index) {
          return this._setCurrent(index);
        };

        Iterator.prototype._setCurrent = function(index) {
          if (!(index < this.length())) {
            throw new Error("index " + index + " > " + (this.length()));
            return;
          }
          if (this.data[index].disabled) {
            return;
          }
          this.current().unmark();
          this.index = index;
          this.current().mark();
          return $(this.$el).trigger('timePicker.change');
        };

        Iterator.prototype._prepareItems = function(array) {
          var i, key, len, num, results, text;
          this.data = [];
          this._valueIndex = {};
          results = [];
          for (key = i = 0, len = array.length; i < len; key = ++i) {
            num = array[key];
            if (this.type === 'hour' || this.type === 'minute') {
              text = String(num + 100).substr(-2);
              if (num === 0 && this.type === 'hour') {
                text = 12;
              }
            } else {
              text = num;
            }
            this.data.push(new Item(num, text));
            results.push(this._valueIndex[num] = key);
          }
          return results;
        };

        Iterator.prototype._hasNext = function() {
          var ref;
          return this.index < this.length() - 1 && (this.data[this.index + 1] && !((ref = this.data[this.index + 1]) != null ? ref.disabled : void 0));
        };

        Iterator.prototype._hasPrev = function() {
          return this.index > 0 && !this.data[this.index - 1].disabled;
        };

        Iterator.prototype._wind = function() {
          this._setCurrent(this.length() - 1);
          return this.current();
        };

        Iterator.prototype._rewind = function() {
          var i, idx, index, it, len, ref;
          index = null;
          ref = this.data;
          for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
            it = ref[idx];
            if (!it.disabled) {
              index = idx;
              break;
            }
          }
          if (index !== null) {
            this._setCurrent(index);
          }
          return this.current();
        };

        return Iterator;

      })();
      ColumnView = (function() {
        ColumnView.prototype.$el = null;

        ColumnView.prototype.className = 'timePicker__col';

        ColumnView.prototype.data = null;

        ColumnView.prototype.isDragNow = false;

        function ColumnView(options) {
          this._onMouseUp = bind(this._onMouseUp, this);
          this._onMouseDown = bind(this._onMouseDown, this);
          this._onTouchStart = bind(this._onTouchStart, this);
          this._onMouseWheel = bind(this._onMouseWheel, this);
          this.options = $.extend({}, options);
          this.data = options.data;
          this._createEl();
          this._initEvents();
          if (this.options.parent) {
            this.getEl().appendTo(this.options.parent);
            this._scrollToActive();
          } else {
            throw new Error("Specify parent element");
          }
        }

        ColumnView.prototype._createEl = function() {
          this.$el = $('<div></div>').addClass(this.className);
          this.$col = $('<div></div>').addClass('timePicker__items');
          this._drawItems();
          return this.$el.append(this.$col);
        };

        ColumnView.prototype._drawItems = function() {
          return this.data.each((function(_this) {
            return function(item) {
              return _this.$col.append(item.getEl());
            };
          })(this));
        };

        ColumnView.prototype._scrollToActive = function() {
          var current, halfHeight, top;
          current = this.data.current();
          halfHeight = this.options.parent.height() / 2;
          top = halfHeight - current.getEl().position().top;
          return this._setTop(top - current.getHeight() / 2);
        };

        ColumnView.prototype._checkActive = function() {
          var columnTop, dragItem, halfHeight, itemHeight;
          itemHeight = this.data.current().getHeight();
          halfHeight = this.options.parent.height() / 2;
          columnTop = this.$col.position().top;
          dragItem = Math.floor((halfHeight - columnTop) / itemHeight);
          if (this.data.getIndex() !== dragItem && dragItem < this.data.length()) {
            return this.data.setCurrent(dragItem);
          }
        };

        ColumnView.prototype._verifyPosition = function(top, e, isTouch) {
          var clearShiftY, columnHeight, halfHeight, touch;
          if (isTouch == null) {
            isTouch = false;
          }
          halfHeight = this.options.parent.height() / 2;
          columnHeight = this.$col.outerHeight();
          clearShiftY = false;
          if (!(columnHeight + top > halfHeight)) {
            top = halfHeight - 10;
            clearShiftY = true;
          }
          if (top > halfHeight) {
            top = halfHeight - columnHeight + 10;
            clearShiftY = true;
          }
          if (isTouch) {
            touch = e.originalEvent.touches[0];
            this.oldPosY = touch.pageY;
            if (clearShiftY && e) {
              this.shiftY = touch.pageY - this.$col.position().top;
            }
          } else {
            this.oldPosY = e.pageY;
            if (clearShiftY && e) {
              this.shiftY = e.pageY - this.$col.position().top;
            }
          }
          this._setTop(top);
          return this._checkActive();
        };

        ColumnView.prototype._setTop = function(top) {
          return this.$col.css({
            top: top
          });
        };

        ColumnView.prototype._initEvents = function() {
          var self;
          self = this;
          this.$el.on('click', '.timePicker__item', function() {
            if (self.isItemClick) {
              self.data.setCurrentByValue($(this).attr('data-value'));
              return self._scrollToActive();
            }
          });
          this.$el.on('mousewheel', _.throttle(this._onMouseWheel, 200));
          this.$el.on('mousedown', this._onMouseDown);
          return this.$el.on('touchstart', this._onTouchStart);
        };

        ColumnView.prototype._onMouseWheel = function(e) {
          e.preventDefault();
          if (this.isDragNow) {
            return;
          }
          if (e.deltaY < 0) {
            this.data.next();
          } else if (e.deltaY > 0) {
            this.data.prev();
          }
          this._scrollToActive();
          return false;
        };

        ColumnView.prototype._onTouchStart = function(e) {
          var moveAt, touch;
          this.isDragNow = true;
          this.isItemClick = true;
          touch = e.originalEvent.touches[0];
          this.oldPosY = touch.pageY;
          this.shiftY = touch.pageY - this.$col.position().top;
          moveAt = (function(_this) {
            return function(e) {
              var top;
              _this.$col.addClass('timePicker__notransition');
              touch = e.originalEvent.touches[0];
              top = touch.pageY - _this.shiftY;
              return _this._verifyPosition(top, e, true);
            };
          })(this);
          $(window).on('touchmove.timePicker', function(e) {
            e.preventDefault();
            this.isItemClick = true;
            moveAt(e);
            return false;
          });
          return $(window).on('touchend.timePicker', this._onMouseUp);
        };

        ColumnView.prototype._onMouseDown = function(e) {
          var moveAt;
          this.isDragNow = true;
          this.isItemClick = true;
          this.oldPosY = e.pageY;
          this.shiftY = e.pageY - this.$col.position().top;
          moveAt = (function(_this) {
            return function(e) {
              var top;
              _this.$col.addClass('timePicker__notransition');
              top = e.pageY - _this.shiftY;
              return _this._verifyPosition(top, e);
            };
          })(this);
          $(window).on('mousemove.timePicker', (function(_this) {
            return function(e) {
              _this.isItemClick = false;
              return moveAt(e);
            };
          })(this));
          return $(window).on('mouseup.timePicker', this._onMouseUp);
        };

        ColumnView.prototype._onMouseUp = function(e) {
          this.$col.removeClass('timePicker__notransition');
          this.isDragNow = false;
          this._scrollToActive();
          return $(window).off('mousemove.timePicker mouseup.timePicker touchend.timePicker touchmove.timePicker');
        };

        ColumnView.prototype.getEl = function() {
          return this.$el;
        };

        return ColumnView;

      })();
      Picker = (function() {
        Picker.prototype.$el = null;

        function Picker($el, options1) {
          this.$el = $el;
          this.options = options1;
          this.$el.addClass('timePicker').append($('<div class="timePicker__center"></div>'));
          this._createColumns();
          this._setMinTime(true);
          this.$el.on('timePicker.change', (function(_this) {
            return function() {
              _this._setMinTime();
              if (_this.options.onChange && typeof _this.options.onChange === 'function') {
                return _this.options.onChange.call(null, _this.getTime());
              }
            };
          })(this));
        }

        Picker.prototype._prepareTime = function(timeString) {
          var amPmResult, amPmStart, hourResult, hourStart, isNextDay, m, minuteResult, minuteStart, minutesArr, ref;
          hourResult = 0;
          minuteResult = 0;
          amPmResult = 0;
          isNextDay = false;
          ref = timeString.split(':'), hourStart = ref[0], minuteStart = ref[1];
          hourStart = parseInt(hourStart);
          minuteStart = parseInt(minuteStart);
          amPmStart = 0;
          hourResult = hourStart;
          if (hourStart > 11) {
            amPmStart = 1;
            hourResult = hourStart % 12;
          }
          amPmResult = amPmStart;
          minuteResult = minuteStart = Math.ceil(minuteStart / this.options.step);
          minutesArr = (function() {
            var i, ref1, results;
            results = [];
            for (m = i = 0, ref1 = this.options.step; i < 60; m = i += ref1) {
              results.push(m);
            }
            return results;
          }).call(this);
          if (!(minuteStart < minutesArr.length)) {
            minuteResult = 0;
            hourResult++;
            if (hourResult > 11) {
              if (!amPmStart) {
                hourResult = 0;
                amPmStart = 1;
              } else {
                isNextDay = true;
                hourResult = 11;
                minuteResult = minutesArr.length - 1;
              }
              amPmResult = amPmStart;
            }
          }
          return {
            h: hourResult,
            m: minuteResult,
            ampm: amPmResult,
            isNextDay: isNextDay
          };
        };

        Picker.prototype._createColumns = function() {
          var amPmStart, cfg, curDate, hourStart, m, minuteStart, zoneStart, zones;
          if (!this.options.defaultTime) {
            curDate = new Date();
            this.options.defaultTime = (curDate.getHours()) + ":" + (curDate.getMinutes());
          }
          cfg = this._prepareTime(this.options.defaultTime);
          hourStart = cfg.h;
          minuteStart = cfg.m;
          amPmStart = cfg.ampm;
          zoneStart = 0;
          this.amPmColView = new ColumnView({
            data: this.amPmIterator = new Iterator(['am', 'pm'], amPmStart, null, this.$el),
            parent: this.$el
          });
          this.hourColView = new ColumnView({
            data: this.hoursIterator = new Iterator([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], hourStart, 'hour', this.$el),
            parent: this.$el
          });
          this.minColView = new ColumnView({
            data: this.minutesIterator = new Iterator((function() {
              var i, ref, results;
              results = [];
              for (m = i = 0, ref = this.options.step; i < 60; m = i += ref) {
                results.push(m);
              }
              return results;
            }).call(this), minuteStart, 'minute', this.$el),
            parent: this.$el
          });
          zones = ['pst', 'mst', 'cst', 'est'];
          if (this.options.tz) {
            zoneStart = zones.indexOf(this.options.tz);
          }
          return new ColumnView({
            data: this.zonesIterator = new Iterator(zones, zoneStart, null, this.$el),
            parent: this.$el
          });
        };

        Picker.prototype.getTime = function() {
          return {
            hour: this.hoursIterator.current().getValue(),
            minute: this.minutesIterator.current().getValue(),
            ampm: this.amPmIterator.current().getValue(),
            tz: this.zonesIterator.current().getValue()
          };
        };

        Picker.prototype.setMinTime = function(minTime) {
          var cfg, curValue, hour;
          this._setMinTime(false, minTime);
          curValue = this.getTime();
          hour = curValue.ampm === "pm" ? curValue.hour + 12 : curValue.hour;
          if (minTime && parseInt(minTime.replace(':', '')) > parseInt(hour * 100 + curValue.minute)) {
            cfg = this._prepareTime(minTime);
            this.amPmIterator.setCurrent(cfg.ampm);
            this.amPmColView._scrollToActive();
            this.hoursIterator.setCurrent(cfg.h);
            this.hourColView._scrollToActive();
            this.minutesIterator.setCurrent(cfg.m);
            return this.minColView._scrollToActive();
          }
        };

        Picker.prototype._setMinTime = function(init, minTime) {
          var ampm, cfg, h, m;
          if (init == null) {
            init = false;
          }
          if (minTime !== void 0) {
            this.options.minTime = minTime;
          }
          if (init && !this.options.minTime) {
            return;
          }
          if (this.options.minTime === false) {
            this.amPmIterator.setMin(0);
            this.hoursIterator.setMin(0);
            this.minutesIterator.setMin(0);
            return;
          }
          cfg = this._prepareTime(this.options.minTime);
          ampm = cfg.ampm;
          h = cfg.h;
          m = cfg.m;
          if (cfg.isNextDay) {
            console.log('next day, disable all');
            this.amPmIterator.setMin(1);
            this.hoursIterator.setMin(12);
            this.minutesIterator.setMin(60);
            return;
          }
          this.amPmIterator.setMin(ampm);
          if (this.amPmIterator.current().getValue() === 'pm' && ampm === 0) {
            console.log('do nothing');
          } else {
            this.hoursIterator.setMin(h);
            if (h === 11 && ampm === 1 && !(m < this.minutesIterator.length())) {
              this.hoursIterator.setMin(12);
            }
            if (this.hoursIterator.current().getValue() === h) {
              this.minutesIterator.setMin(m);
              if (!init && this.minutesIterator.getIndex() < m) {
                this.minutesIterator.setCurrent(m);
                this.minColView._scrollToActive();
              }
            } else {
              if (this.hoursIterator.current().getValue() < h) {
                this.minutesIterator.setMin(60);
              } else {
                this.minutesIterator.setMin(0);
              }
            }
          }
          if (this.amPmIterator.current().getValue() === 'am' && ampm === 1) {
            console.log('disable all');
            this.hoursIterator.setMin(12);
            return this.minutesIterator.setMin(60);
          }
        };

        return Picker;

      })();
      return new Picker($(this).eq(0), options);
    };
  })(jQuery);

}).call(this);
