var binds = {};
var selectedKey = null;

$(function() {
    $("body").hide();

    window.addEventListener('message', function(event) {
        var item = event.data;

        if (item.message == "show") {
            $(".keyboard td").removeClass("selected");
            selectedKey = null;
            $("body").show();
        } else if (item.message == "hide") {
            $("body").hide();
        } else if (item.message == "updateBind") {
            binds = item.binds;
            updateBindings();
        }
    });
})

$(document).ready(function() {
    $("body").on("keyup", function(key) {
        if (key.which == 27 || key.which == 8) {
            close();
        }
    });

    $(".keyboard td").on("click", function() {
        var key = $(this).find("a").data("key");
        if (typeof key !== 'undefined') {
            $(".keyboard td").removeClass("selected");
            $(this).addClass("selected");
            selectedKey = key;
        }
    });

    $("#close").on("click", function() {
        close();
    });

    $("#removeBind").on("click", function() {
        if (selectedKey) {
            $.post("https://bind/removeBind", JSON.stringify({
                key: selectedKey
            }));
        }
    });

    $("#addBind").on("click", function() {
        if (selectedKey) {
            close();

            $.post("https://bind/addBind", JSON.stringify({
                key: selectedKey
            }));
        }
    });
})

function updateBindings() {
    $(".keyboard td").removeClass("active");
    binds.forEach(function(bind) {
        var element = $(".keyboard td").find(`[data-key='${bind.key}']`).closest('td');
        if (element) {
            element.addClass("active");
        }
    });
}

function close() {
    $.post("https://bind/NUIFocusOff", JSON.stringify({
        binds: binds
    }));
}