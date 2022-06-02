var notifId = 0;

window.addEventListener('message', function (event) {
    switch (event.data.action) {
        case 'changeSkill':
            var notification;
            if (event.data.amount >= 0.05) {
                notification = $('<div id="' + notifId + '" class="notification">+' + event.data.amount + '% ' + event.data.skillLabel + '</div>').hide().fadeIn(1000);
            } else if (event.data.amount <= -0.05) {
                notification = $('<div id="' + notifId + '" class="notification remove">' + event.data.amount + '% ' + event.data.skillLabel + '</div>').hide().fadeIn(1000);
            } else {
                return;
            }

            $("#notificationsList").append(notification);
            var element = $('#' + notifId);
            ++notifId;
            setTimeout(function () {
                element.fadeOut(1000);
            }, 6000);
            break;
    }
});