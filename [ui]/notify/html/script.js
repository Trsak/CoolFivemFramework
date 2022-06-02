$('document').ready(function () {
    alerts = {};

    window.addEventListener('message', function (event) {
        ShowNotif(event.data);
    });

    function ShowNotif(data) {
        var $notification;

        if (data.action == "message") {
            $notification = CreateNotification(data);
        } else if (data.action == "outlaw") {
            $notification = CreateOutlaw(data);
        }

        $('.notif-container').append($notification);
        setTimeout(function () {
            $.when($notification.fadeOut()).done(function () {
                $notification.remove()
            });
        }, data.length != null ? data.length : 2500);
    }

    function CreateNotification(data) {
        var $notification = $(document.createElement('div'));
        $notification.addClass('notification').addClass(data.style);
        $notification.html('\
        <div class="content">\
        <div id="alert-name">' + data.title + '</div>\
        <div id="marker"><i class="' + data.icon + '" aria-hidden="true"></i></div>\
        <div id="alert-info">' + data.text + '</div>\
        </div>');
        $notification.fadeIn();
        if (data.style !== undefined) {
            Object.keys(data.style).forEach(function (css) {
                $notification.css(css, data.style[css])
            });
        }
        return $notification;
    }

    function CreateOutlaw(data) {
        var $notification = $(document.createElement('div'));
        $notification.addClass('notification').addClass(data.style);

        var text = '\
        <div class="content">';

        if (data.code) {
            text = text + '<div id="code">' + data.code + '</div>';
        }

        text = text + '<div id="alert-name-code">' + data.title + '</div>\
        <div id="marker"><i class="' + data.icon + '" aria-hidden="true"></i></div>\
        <div id="alert-info"><i class="fas fa-map-marker-alt"></i>' + data.location;

        if (data.vehicle) {
            text = text + '<i class="fas fa-car divider"></i>' + data.vehicle;
        }

        if (data.plate) {
            text = text + '<i class="fas fa-font divider"></i>' + data.plate;
        }

        if (data.weapon) {
            text = text + '<i class="fas fa-font divider"></i>' + data.weapon;
        }

        if (data.color) {
            text = text + '<i class="fas fa-tint divider"></i>' + data.color;
        }

        text = text + '</div></div>';

        $notification.html(text);
        $notification.fadeIn();
        if (data.style !== undefined) {
            Object.keys(data.style).forEach(function (css) {
                $notification.css(css, data.style[css]);
            });
        }
        return $notification;
    }
});