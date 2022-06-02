function setupJobs(jobCounts) {
    if (jobCounts.taxi > 0) {
        $('#taxi').removeClass("off");
        $('#taxi').addClass("on");
    } else {
        $('#taxi').removeClass("on");
        $('#taxi').addClass("off");
    }

    if (jobCounts.paramedics > 0) {
        $('#paramedics').removeClass("off");
        $('#paramedics').addClass("on");
    } else {
        $('#paramedics').removeClass("on");
        $('#paramedics').addClass("off");
    }

    if (jobCounts.doctors > 0) {
        $('#doctors').removeClass("off");
        $('#doctors').addClass("on");
    } else {
        $('#doctors').removeClass("on");
        $('#doctors').addClass("off");
    }

    if (jobCounts.lsfd > 0) {
        $('#lsfd').removeClass("off");
        $('#lsfd').addClass("on");
    } else {
        $('#lsfd').removeClass("on");
        $('#lsfd').addClass("off");
    }
}

function openPlayer(id) {
    $.post('https://scoreboard/closeMenu', JSON.stringify({
        openPlayer: id
    }));
}

$(function () {
    $('body').bind("contextmenu", function (e) {
        $.post('https://scoreboard/closeMenu', JSON.stringify({
            openPlayer: null
        }));
    });

    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case 'show':
                $('#main').show();
                break;
            case 'hide':
                $('#main').hide();
                break;
            case 'refresh':
                var data = event.data.data;
                var players = data.players;
                var adminLevel = event.data.adminLevel;

                $('#currentPlayers').html(data.currentPlayers);
                $('#maxPlayers').html(data.maxPlayers);

                setupJobs(data.jobCounts)

                $('.user').removeClass("checked");

                var hoverAble = ""
                if (adminLevel >= 2) {
                    hoverAble = " hoverable";
                }

                $.each(players, function (i, player) {
                    if (!$("#" + player.source).length) {
                        var vipIcon = "";
                        if (player.vipLevel == 3) {
                            vipIcon = "🔧 ";
                        } else if (player.vipLevel == 2) {
                            vipIcon = "🌟 ";
                        } else if (player.vipLevel == 1) {
                            vipIcon = "⭐";
                        }

                        $('#users').append("<div class='user col-2 checked" + hoverAble + "' data-id='" + player.source + "' id='" + player.source + "'><div class='badge badge-light'>" + player.source + "</div><div class='name'>" + vipIcon + player.name + "</div></div>");
                        if (adminLevel >= 2) {
                            $('#' + player.source).click(function () {
                                openPlayer($(this).data("id"));
                            });
                        }
                    } else {
                        $("#" + player.source).addClass("checked");
                    }
                });

                var usersList = $(".user");
                usersList.sort(function (a, b) {
                    return $(a).data("id") - $(b).data("id")
                });
                $("#usersList").html(usersList);

                $('.user').not('.checked').remove();
                break;
            case "jobs":
                setupJobs(event.data.counts)
                break
            default:
                console.log('ui_scoreboard: unknown action!');
                break;
        }
    }, false);
});