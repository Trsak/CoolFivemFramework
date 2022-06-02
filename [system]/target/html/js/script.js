var isOpen = false;

window.addEventListener('message', function (event) {
    let item = event.data;

    if (item.response === 'openTarget') {
        $(".target-label").html("");
        $(".target-label").hide();

        $('.target-wrapper').show();
        isOpen = true;

        $(".target-eye").css("color", "black");
    } else if (item.response === 'closeTarget') {
        closeMenu();
    } else if (item.response === 'validTarget') {
        $(".target-label").html("");
        $(".target-label").hide();


        jQuery.each(item.actions, function (action, actionData) {
            $(".target-label").append("<div class='single-target' id='target-" + action + "'><span class='target-icon'><i class='" + actionData.icon + "'></i></span>&nbsp" + actionData.label + "</div>");

            $("#target-" + action).data('index', item.index);
            $("#target-" + action).data('type', item.type);
            $("#target-" + action).data('entity', item.entity);
            $("#target-" + action).data('action', action);
            $(".target-label").show();
        });

        $(".target-eye").css("color", "rgb(109, 80, 160)");
    } else if (item.response == 'leftTarget') {
        $(".target-label").html("");
        $(".target-eye").css("color", "black");
    }
});

$(document).on('mousedown', (event) => {
    let element = event.target;

    if (element.id.split("-")[0] === 'target') {
        $.post('https://target/selectTarget', JSON.stringify({
            index: $("#" + element.id).data('index'),
            type: $("#" + element.id).data('type'),
            entity: $("#" + element.id).data('entity'),
            action: $("#" + element.id).data('action')
        }));

        closeMenu();
    }
});

$(document).on('keydown', function (event) {
    if (event.keyCode === 27 || event.keyCode === 8) {
        closeMenu();
    }
});

$(document).on('contextmenu', function (event) {
    event.preventDefault();
    closeMenu();
});

function closeMenu() {
    if (isOpen) {
        $(".target-eye").css("color", "black");
        $(".target-label").html("");
        $('.target-wrapper').hide();
        $.post('https://target/closeTarget');
        isOpen = false;
    }
}