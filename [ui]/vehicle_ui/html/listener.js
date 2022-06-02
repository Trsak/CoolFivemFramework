var warning = false;
var lowgas = false;
var isBigMap = false;
var azimutTop = false;

var minimapWidth = 0.0;
var vehicleType = undefined;

$(function () {
    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case 'show':
                $('#main').show();
                break;
            case 'hide':
                $('#main').hide();

                break;
            case 'refresh':

                if (event.data.minimapWidth !== undefined) {
                    minimapWidth = event.data.minimapWidth
                }

                if (event.data.vehicleType !== undefined) {
                    vehicleType = event.data.vehicleType
                }

                if (event.data.speedType !== undefined) {
                    $('#speedType').html(event.data.speedType);
                }

                if (event.data.isBigMapActive !== undefined) {
                    isBigMap = event.data.isBigMapActive;
                    var left = minimapWidth * 100;
                    if (isBigMap) {
                        $('#toolsData').css('left', (left + 4.9) + 'vw');
                        $('#vehicleData').css('left', (left + 4.9) + 'vw');
                        if(!azimutTop)
                            $('#currentPosition').css('left', (left + 4.9) + 'vw');
                    } else {
                        $('#toolsData').css('left', (left - 3.4) + 'vw');
                        $('#vehicleData').css('left', (left - 3.4) + 'vw');
                        if(!azimutTop)
                            $('#currentPosition').css('left', (left - 2.5) + 'vw');
                    }
                }

                if(event.data.azimutTop !== undefined){
                    azimutTop = event.data.azimutTop
                    if(event.data.azimutTop) {
                        $('#currentPosition').css('left', '40%');
                        $('#currentPosition').css('bottom', '97%');
                    }
                    else {
                        $('#currentPosition').css('left', '17%');
                        $('#currentPosition').css('bottom', '0.4%');
                    }
                }

                if (event.data.direction) {
                    $(".direction").find(".image").attr('style', 'transform: translate3d(' + event.data.direction + 'px, 0px, 0px)');
                }

                if (event.data.hasSeatbelt !== undefined) {
                    if (event.data.hasSeatbelt) {
                        $('#belt').show();
                    } else {
                        $('#belt').hide();
                    }

                }
                if (event.data.seatbelt !== undefined) {
                    if (event.data.seatbelt) {
                        $('#belt').html('<img src="img/belt-on.svg">');
                    } else {
                        $('#belt').html('<img src="img/belt-off.svg">');
                    }
                }

                if (event.data.feets >= 0) {
                    $('#feets').show();
                    $('#feetslabel').show();
                    $('#feets').html(event.data.feets);
                }

                if (event.data.isDriver !== undefined) {
                    if ((vehicleType || event.data.vehicleType) && event.data.isDriver) {
                        $('#gas').show();
                        $('#fuel').show();
                        if (vehicleType == "car") {
                            $('#limit').show();
                        }
                    } else {
                        $('#gas').hide();
                        $('#fuel').hide();
                        $('#limit').hide();
                    }
                }
                
                if (event.data.limit !== undefined) {
                    if (event.data.limit) {
                        $('#limit').html('<img src="img/limit-on.svg">');
                    } else {
                        $('#limit').html('<img src="img/limit-off.svg">');
                    }
                }

                if (event.data.gas !== undefined) {
                    $('#gas').html(event.data.gas);
                }
                if (event.data.speed !== undefined) {
                    $('#speed').html(event.data.speed);
                }
                if (event.data.streetname !== undefined) {
                    $('#position').html(event.data.streetname);
                }
                break;
            default:
                console.log('vehicle_ui: unknown action!');
                break;
        }
    }, false);
});

function loopWarning() {
    if (warning == false) return;

    $("#damage").fadeIn(600, function () {
        $("#damage").fadeOut(600, function () {
            loopWarning();
        });
    });
}

function loopLowGas() {
    if (lowgas == false) return;

    $("#gasbulb").fadeIn(800, function () {
        $("#gasbulb").fadeOut(800, function () {
            loopLowGas();
        });
    });
}