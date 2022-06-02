iejobs = {}
cfg = Config;
span = document.getElementsByClassName("close")[0];
pref = 'https://iejobs/';

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        iejobs = {}
        iejobs.company = event.data.company
        iejobs.alreadyInWork = event.data.can
        iejobs.identifier = event.data.steam
        iejobs.work = event.data;
        iejobs.countS = 0;
        switch(event.data.action) {
            case "open":
                open()
                break;
            case "open2":
                open()
                break;
            case "success":
                work.data[work.currentWork.key][work.currentWork.uuid].WorkTaken = true
                open()
                break;
            case "close":
                close()
                break;
            case "payout":
                $("body").show();
                $('.content').empty();
                payout()
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            close();
            break;
        case 112: // F1
            close();
            break;
    }
});

span.onclick = function(){
    $.post(pref + 'close', JSON.stringify({}));
};

function close(){
    $("body").hide();
    $('.content').empty();
}

function clos(){
    $.post(pref + 'close', JSON.stringify({}));
}

function open(){
    $("body").show();
    $('.content').empty();
    createCards()
}