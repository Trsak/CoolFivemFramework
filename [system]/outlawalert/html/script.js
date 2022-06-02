var currentAlert = null;
var currentList = null;

window.onload = function () {
    var eventCallback = {
        openList: function (data) {
            $("body").show();
        },
        updateList: function (data) {
            $(".card-body").html("");
            currentList = data.alerts;
            $.each(data.alerts, function (key, alert) {
                var text = `<div class="report" tabindex="1" data-id="${key + 1}" data-index="${key}" onmouseenter="mouseOnHover(${key})" onclick="setGPS('${alert.coords.x}', '${alert.coords.y}', '${alert.title}')">
                <div class="code">
                    <span class="badge badge-danger">${alert.code}</span> ${alert.title}
                </div>
                <div class="info">
                    <i class="fas fa-map-marker-alt"></i> ${alert.location}`;

                if (alert.vehicle) {
                    text = text + '  <i class="fas fa-car divider"></i>  ' + alert.vehicle;
                }

                if (alert.plate) {
                    text = text + '  <i class="fas fa-font divider"></i>  ' + alert.plate;
                }

                if (alert.color) {
                    text = text + '  <i class="fas fa-tint divider"></i>  ' + alert.color;
                }

                if (alert.weapon) {
                    text = text + '  <i class="fas fa-font divider"></i>  ' + alert.weapon;
                }

                if (alert.text) {
                    text = text + '  <i class="fas fa-info divider"></i>' + alert.text;
                }

                if (alert.time) {
                    text = text + '  <i class="fas fa-clock divider"></i>  ' + alert.time;
                }

                text = text + `</div></div>`;

                $(".card-body").prepend(text);
            });
        },
        close: function (data) {
            $("body").hide();
        }
    };

    window.addEventListener('message', function (event) {
        eventCallback[event.data.action](event.data);
    });
}

function mouseOnHover(index){
    currentAlert = index;
}

document.onkeyup = function (data) {
    if (data.which == 27 || data.which == 8) {
        $.post('https://outlawalert/closeui', JSON.stringify({}));
    }
    else if(data.which == 40) {
        if(currentAlert == null){
            currentAlert = currentList.length - 1;
        }else{
            if((currentAlert-1) >= 0){
                currentAlert--;
            }else{
                currentAlert = currentList.length - 1;
            }
        }
        $("[data-index='"+currentAlert+"']").focus();
    }
    else if(data.which == 38) {
        if(currentAlert == null){
            currentAlert = 0;
        }else{
            if((currentAlert+1) < currentList.length){
                currentAlert++;
            }else{
                currentAlert = 0;
            }
        }
        $("[data-index='"+currentAlert+"']").focus();
    }
};

document.onkeydown = function (data) {
    if(data.which == 13) {
        if(currentAlert !== null){
            setGPS(currentList[currentAlert].coords.x, currentList[currentAlert].coords.y, currentList[currentAlert].title);
        }
    }
};

function setGPS(x, y, title) {
    $.post('https://outlawalert/closeui', JSON.stringify({
        x: x,
        y: y,
        title: title
    }));
}