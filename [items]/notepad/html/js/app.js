var isOpen = false;

document.onkeyup = function (data) {
    if (isOpen) {
        if (data.which == 27) { // Escape key
            cancelNotepad();
        } else if (data.which == 17) {
            $.post('https://notepad/movewhile', JSON.stringify({}));
        }
    }
};

function cancelNotepad() {
    if (isOpen) {
        isOpen = false;
        var x = document.getElementById("p1").value;
        $.post('https://notepad/escape', JSON.stringify({
            text: x
        }));
        $("#main").fadeOut();
        $("#main").css('display', 'none');
        document.getElementById("p1").value = "";
    }
}

window.addEventListener('message', function (e) {
    switch (event.data.action) {
        case 'openNotepad':
            isOpen = true;
            $("#main").fadeIn();
            document.getElementById("p1").value = event.data.TextRead;
            break;
        case 'closeNotepad':
            $("#main").fadeOut();
            $("#main").css('display', 'none');
            break;
    }
});
