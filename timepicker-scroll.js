(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function($) {
    var defaults;
    defaults = {
      step: 5
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

        Picker.prototype._createColumns = function() {
          var amPmStart, curDate, hourStart, m, minuteStart, ref, zoneStart, zones;
          hourStart = 0;
          minuteStart = 0;
          amPmStart = 0;
          zoneStart = 0;
          if (this.options.defaultTime) {
            ref = this.options.defaultTime.split(':'), hourStart = ref[0], minuteStart = ref[1];
          } else {
            curDate = new Date();
            hourStart = curDate.getHours();
            minuteStart = curDate.getMinutes();
          }
          if (hourStart > 11) {
            amPmStart = 1;
            hourStart = hourStart % 12;
          }
          minuteStart = Math.ceil(minuteStart / this.options.step);
          new ColumnView({
            data: this.amPmIterator = new Iterator(['am', 'pm'], amPmStart, null, this.$el),
            parent: this.$el
          });
          new ColumnView({
            data: this.hoursIterator = new Iterator([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], hourStart, 'hour', this.$el),
            parent: this.$el
          });
          this.minColView = new ColumnView({
            data: this.minutesIterator = new Iterator((function() {
              var i, ref1, results;
              results = [];
              for (m = i = 0, ref1 = this.options.step; i < 60; m = i += ref1) {
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
          return this._setMinTime(false, minTime);
        };

        Picker.prototype._setMinTime = function(init, minTime) {
          var ampm, h, m, ref;
          if (init == null) {
            init = false;
          }
          if (minTime !== void 0) {
            this.options.minTime = minTime;
          }
          if (!this.options.minTime) {
            return;
          }
          ampm = 0;
          ref = this.options.minTime.split(':'), h = ref[0], m = ref[1];
          if (h > 11) {
            ampm = 1;
            h %= 12;
          }
          h = parseInt(h);
          m = Math.ceil(m / this.options.step);
          this.amPmIterator.setMin(ampm);
          if (this.amPmIterator.current().getValue() === 'pm' && ampm === 0) {
            console.log('do nothing');
          } else {
            this.hoursIterator.setMin(h);
            if (this.hoursIterator.current().getValue() === h) {
              this.minutesIterator.setMin(m);
              if (!init && this.minutesIterator.getIndex() < m) {
                this.minutesIterator.setCurrent(m);
                this.minColView._scrollToActive();
              }
            } else {
              this.minutesIterator.setMin(0);
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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInRpbWVwaWNrZXItc2Nyb2xsLmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtBQUFBLE1BQUE7O0VBQUcsQ0FBQSxTQUFDLENBQUQ7QUFDRCxRQUFBO0lBQUEsUUFBQSxHQUNFO01BQUEsSUFBQSxFQUFNLENBQU47O1dBRUYsQ0FBQyxDQUFDLEVBQUUsQ0FBQyxVQUFMLEdBQWtCLFNBQUMsT0FBRDtBQUNoQixVQUFBO01BQUEsT0FBQSxHQUFVLENBQUMsQ0FBQyxNQUFGLENBQVMsUUFBVCxFQUFtQixPQUFuQjtNQUVKO3VCQUNKLEdBQUEsR0FBSzs7dUJBQ0wsU0FBQSxHQUFXOzt1QkFDWCxRQUFBLEdBQVU7O1FBQ0csY0FBQyxNQUFELEVBQWdCLElBQWhCO1VBQUMsSUFBQyxDQUFBLHlCQUFELFNBQVM7VUFDckIsSUFBQyxDQUFBLEdBQUQsR0FBTyxDQUFBLENBQUUsYUFBRixDQUFnQixDQUFDLFFBQWpCLENBQTBCLElBQUMsQ0FBQSxTQUEzQixDQUFxQyxDQUFDLElBQXRDLENBQTJDLFlBQTNDLEVBQXlELElBQUMsQ0FBQSxLQUExRCxDQUFnRSxDQUFDLElBQWpFLENBQXNFLElBQXRFO1FBREk7O3VCQUliLEtBQUEsR0FBTyxTQUFBO2lCQUNMLElBQUMsQ0FBQTtRQURJOzt1QkFHUCxPQUFBLEdBQVMsU0FBQTtVQUNQLElBQUMsQ0FBQSxRQUFELEdBQVk7aUJBQ1osSUFBQyxDQUFBLEdBQUcsQ0FBQyxRQUFMLENBQWlCLElBQUMsQ0FBQSxTQUFGLEdBQVksWUFBNUI7UUFGTzs7dUJBSVQsTUFBQSxHQUFRLFNBQUE7VUFDTixJQUFDLENBQUEsUUFBRCxHQUFZO2lCQUNaLElBQUMsQ0FBQSxHQUFHLENBQUMsV0FBTCxDQUFvQixJQUFDLENBQUEsU0FBRixHQUFZLFlBQS9CO1FBRk07O3VCQUlSLE1BQUEsR0FBUSxTQUFBO2lCQUNOLElBQUMsQ0FBQSxLQUFELENBQUEsQ0FBUSxDQUFDLFdBQVQsQ0FBd0IsSUFBQyxDQUFBLFNBQUYsR0FB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QWQsQ0FBQSxDQUF1QixDQUFDLFFBQXhCLENBQUEsQ0FBQSxLQUFzQyxJQUF0QyxJQUErQyxJQUFBLEtBQVEsQ0FBMUQ7WUFDRSxPQUFPLENBQUMsR0FBUixDQUFZLFlBQVosRUFERjtXQUFBLE1BQUE7WUFHRSxJQUFDLENBQUEsYUFBYSxDQUFDLE1BQWYsQ0FBc0IsQ0FBdEI7WUFDQSxJQUFHLElBQUMsQ0FBQSxhQUFhLENBQUMsT0FBZixDQUFBLENBQXdCLENBQUMsUUFBekIsQ0FBQSxDQUFBLEtBQXVDLENBQTFDO2NBQ0UsSUFBQyxDQUFBLGVBQWUsQ0FBQyxNQUFqQixDQUF3QixDQUF4QjtjQUNBLElBQUcsQ0FBSSxJQUFKLElBQWEsSUFBQyxDQUFBLGVBQWUsQ0FBQyxRQUFqQixDQUFBLENBQUEsR0FBOEIsQ0FBOUM7Z0JBQ0UsSUFBQyxDQUFBLGVBQWUsQ0FBQyxVQUFqQixDQUE0QixDQUE1QjtnQkFFQSxJQUFDLENBQUEsVUFBVSxDQUFDLGVBQVosQ0FBQSxFQUhGO2VBRkY7YUFBQSxNQUFBO2NBT0UsSUFBQyxDQUFBLGVBQWUsQ0FBQyxNQUFqQixDQUF3QixDQUF4QixFQVBGO2FBSkY7O1VBYUEsSUFBRyxJQUFDLENBQUEsWUFBWSxDQUFDLE9BQWQsQ0FBQSxDQUF1QixDQUFDLFFBQXhCLENBQUEsQ0FBQSxLQUFzQyxJQUF0QyxJQUErQyxJQUFBLEtBQVEsQ0FBMUQ7WUFDRSxPQUFPLENBQUMsR0FBUixDQUFZLGFBQVo7WUFDQSxJQUFDLENBQUEsYUFBYSxDQUFDLE1BQWYsQ0FBc0IsRUFBdEI7bUJBQ0EsSUFBQyxDQUFBLGVBQWUsQ0FBQyxNQUFqQixDQUF3QixFQUF4QixFQUhGOztRQTVCVzs7Ozs7YUFpQ1gsSUFBQSxNQUFBLENBQU8sQ0FBQSxDQUFFLElBQUYsQ0FBTyxDQUFDLEVBQVIsQ0FBVyxDQUFYLENBQVAsRUFBc0IsT0FBdEI7SUE1WFk7RUFKakIsQ0FBQSxDQUFILENBQVEsTUFBUjtBQUFBIiwiZmlsZSI6InRpbWVwaWNrZXItc2Nyb2xsLmpzIiwic291cmNlUm9vdCI6Ii9zb3VyY2UvIiwic291cmNlc0NvbnRlbnQiOlsiZG8gKCQgPSBqUXVlcnkpIC0+XG4gIGRlZmF1bHRzID1cbiAgICBzdGVwOiA1XG5cbiAgJC5mbi50aW1lUGlja2VyID0gKG9wdGlvbnMpLT5cbiAgICBvcHRpb25zID0gJC5leHRlbmQgZGVmYXVsdHMsIG9wdGlvbnNcblxuICAgICMgQGluY2x1ZGUgSXRlbS5jb2ZmZWVcblxuICAgICMgQGluY2x1ZGUgSXRlcmF0b3IuY29mZmVlXG5cbiAgICAjIEBpbmNsdWRlIENvbHVtblZpZXcuY29mZmVlXG5cbiAgICAjIEBpbmNsdWRlIFBpY2tlci5jb2ZmZWVcblxuICAgIG5ldyBQaWNrZXIgJCh0aGlzKS5lcSgwKSwgb3B0aW9ucyJdfQ==
