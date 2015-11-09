console.log('rdy');


(function ($) {

    var defaults = {
        step: 5
    };

    jQuery.fn.timePicker = function (options) {

        options = $.extend(defaults, options);

        var make = function () {
            console.log($(this));

            $(this).addClass('timePicker');

            var $hours = $('<div></div>').addClass('timePicker__hours');

            var $hour;
            for (var i = 0; i < 12; i++) {
                $hour = $('<div></div>').addClass('timePicker__item').attr('value', i).text(i == 0 ? 12 : i);
                $hours.append($hour);
            }

            var $colHours = $('<div class="timePicker__col"></div>');
            $colHours.append($hours);

            $colHours.on('mousewheel', function (event) {

                var top = parseInt($hours.css('top'));

                top = top - (event.deltaY * 3);

                $hours.css({
                    top: top
                });

            });


            var $minutes = $('<div></div>').addClass('timePicker__minutes');
            var $minute;

            console.log(options.step);

            var minutes = 0;

            while (minutes < 60) {
                $minute = $('<div></div>').addClass('timePicker__item').attr('value', minutes).text(minutes);
                $minutes.append($minute);
                minutes += options.step;
            }

            var $colMinutes = $('<div class="timePicker__col"></div>');
            $colMinutes.append($minutes);

            $(this).append($colHours);
            $(this).append($colMinutes);

        };

        return this.each(make);

    };

})(jQuery);

