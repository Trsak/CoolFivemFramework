var openedLicenseId = 0;

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        close();
    }
};

$(function() {
    window.addEventListener('message', function(event) {
        switch (event.data.action) {
            case 'open':
                $('#tablet').attr('src', event.data.url);
                $('#main').show();
                break;
            case 'close':
                close();
                break;
        }
    }, false);
});

function close() {
    $('#main').hide();
    $.post('https://jobtablet/close', JSON.stringify({}));
}