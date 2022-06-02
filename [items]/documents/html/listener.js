var openedmenu = "";

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        $.post('https://documents/closepanel', JSON.stringify({}));
    }
};

$(function() {
    window.addEventListener('message', function(event) {
        switch (event.data.Action) {
            case 'show':
                $('#box').show();
                break;
            case 'hide':
                $('#box').hide();
                break;
            case 'opencontent':
                $('#content').html(event.data.Content);
                $('#leftmenu').html(event.data.Leftmenu);
                if (event.data.Openedmenu != null) openedmenu = event.data.Openedmenu;
                break;
            default:
                console.log('ui_documents: unknown action!');
                break;
        }
    }, false);
});

function openMenu(newmenu, plate) {
    $.post('https://documents/openmenu', JSON.stringify({
        openedmenu: openedmenu,
        newmenu: newmenu,
        plate: plate
    }));
}

function selectAction(action, data) {
    $.post('https://documents/selectaction', JSON.stringify({
        openedmenu: openedmenu,
        action: action,
        data: data
    }));
}

function selectJob(job, plate) {
    console.log(job, plate)
    $.post('https://documents/selectjob', JSON.stringify({
        job: job,
        plate: plate
    }));
}