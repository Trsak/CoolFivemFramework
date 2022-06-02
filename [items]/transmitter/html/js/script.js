let isEnabled = false;

var documentWidth = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

var cursor = document.getElementById("cursor");
var cursorX = documentWidth / 2;
var cursorY = documentHeight / 2;

function UpdateCursorPos() {
    cursor.style.left = cursorX;
    cursor.style.top = cursorY;
}

function Click(x, y) {
    var element = $(document.elementFromPoint(x, y));
    element.focus().click();
}

$(function () {
    window.addEventListener('message', function (event) {
        if (event.data.type == "enableui") {
            isEnabled = event.data.enable;
            cursor.style.display = event.data.enable ? "block" : "none";
            document.body.style.display = event.data.enable ? "block" : "none";

            if (isEnabled) {
                $("#channel").focus();
            }
        } else if (event.data.type == "click") {
            Click(cursorX - 1, cursorY - 1);
        } else if (event.data.type == "clear") {
            $("#channel").val('');
        } else if (event.data.type == "volume") {
            //$("#volume").val(Math.floor(event.data.volume * 100));
            $.post('https://transmitter/changeRadioVolume', JSON.stringify({
            volume: event.data.volume
        }));
        }
    });

    $(document).mousemove(function (event) {
        cursorX = event.pageX;
        cursorY = event.pageY;
        UpdateCursorPos();
    });

    document.onkeyup = function (data) {
        if (isEnabled && data.which == 27) {
            $.post('https://transmitter/escape', JSON.stringify({}));
        }
    };

    $("#freq-form").submit(function (e) {
        e.preventDefault();
        $.post('https://transmitter/joinRadio', JSON.stringify({
            channel: $("#channel").val()
        }));
        $.post('https://transmitter/escape', JSON.stringify({}));
    });

    $("#onoff").submit(function (e) {
        e.preventDefault();
        $.post('https://transmitter/leaveRadio', JSON.stringify({}));
        $.post('https://transmitter/escape', JSON.stringify({}));
    });

    $("#volume-form").submit(function (e) {
        e.preventDefault();
    });

    $('#volume').change(function (e) {
        this.value = parseInt(this.value) || 0;

        if (this.value < 0 || this.value == "") {
            this.value = 0;
        } else if (this.value > 100) {
            this.value = 100;
        }

        $.post('https://transmitter/changeRadioVolume', JSON.stringify({
            volume: this.value
        }));
    });
});