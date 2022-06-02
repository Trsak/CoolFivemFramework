var cancelledTimer = null;

$('document').ready(function () {
    Progressbar = {};

    Progressbar.start = function (data) {
        clearTimeout(cancelledTimer);
        $("#progress-label").text(data.label);

        $(".progress-container").fadeIn('fast', function () {
            $("#progress-bar").stop().css({ "width": 0, "background-color": "rgba(109, 80, 160, 0.7)" }).animate({
                width: '100%'
            }, {
                duration: parseInt(data.duration),
                complete: function () {
                    $(".progress-container").fadeOut('fast', function () {
                        $('#progress-bar').removeClass('cancellable');
                        $("#progress-bar").css("width", 0);
                        $.post('https://progressbar/actionFinish', JSON.stringify({}));
                    })
                }
            });
        });
    };

    Progressbar.cancel = function () {
        $("#progress-label").text("ZRUŠENO");
        $("#progress-bar").stop().css({ "width": "100%", "background-color": "rgba(120, 0, 0, 0.7)" });
        $('#progress-bar').removeClass('cancellable');

        cancelledTimer = setTimeout(function () {
            $(".progress-container").fadeOut('fast', function () {
                $("#progress-bar").css("width", 0);
            });
        }, 1000);
    };

    Progressbar.CloseUI = function () {
        $('.main-container').fadeOut('fast');
    };

    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case 'showProgressBar':
                Progressbar.start(event.data);
                break;
            case 'cancelProgressBar':
                Progressbar.cancel();
                break;
        }
    });
});