var garageid = 0;
var action = "";

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        $.post('https://garages/closepanel', JSON.stringify({}));
    }
};

$(function() {
    window.addEventListener('message', function(event) {
        switch (event.data.action) {
            case 'show':
                $('#box').html(`<div class='vehicleName'>${event.data.garageLabel} - ${event.data.garage}</div>`);

                var vehiclesList = event.data.vehicles;
                for (var i = 0; i < vehiclesList.length; i++) {
                    var vehiclesData = vehiclesList[i];
                    var owner = typeof vehiclesData['owner'] == "table" && vehiclesData['owner'].job || "undefined"
                    let vehClass ='class="menu-point"'
                    if (vehiclesData.access) {
                        vehClass ='class="menu-point access "'
                    }
                    $('#box').append(`
					<li ${vehClass} onclick="selectVehicle('${vehiclesData.plate}', ${vehiclesData.towed}, ${vehiclesData.blocked}, '${owner}')" data-id='${i}' style="background-image: url('https://static.server.cz/img/vehicles/${vehiclesData.model}.png');">
						<div class='vehicleName'>${vehiclesData.label} ${vehiclesData.note}</div>
						<div class='vehicleTextWrapper'>
							<div class='vehicleText'><strong class="engineStateText">Stav motoru</strong>
								<div class="wrapper engineBar">
									<div class='progress-bar'><span class='progress-bar-fill'
											style='width: ${vehiclesData.engineState}%; background-color: ${getColor(vehiclesData.engineState)};'></span></div>
								</div><strong class="vehicleStateText">Stav karoserie</strong>
								<div class="wrapper vehicleBar">
									<div class='progress-bar'><span class='progress-bar-fill'
											style='width: ${vehiclesData.vehicleState}%; background-color: ${getColor(vehiclesData.vehicleState)};'></span></div>
								</div><strong class="fuelStateText">Palivo</strong>
								<div class="wrapper fuelBar">
									<div class='progress-bar'><span class='progress-bar-fill'
											style='width: ${vehiclesData.fuelState}%; background-color: ${getColor(vehiclesData.fuelState)};'></span></div>
								</div>
							</div>
						</div>
						<div class='vehicleSPZ'>${vehiclesData.plate == vehiclesData.fakePlate || vehiclesData.fakePlate == null ? vehiclesData.plate : vehiclesData.plate + " (" + vehiclesData.fakePlate + ")"}</div>
					</li>`);

                    if (event.data.class == 13 || event.data.class == 14 || event.data.class == 15 || event.data.class == 16) {
                        $(".menu-point[data-id='" + i + "'] .fuelStateText").hide();
                        $(".menu-point[data-id='" + i + "'] .fuelBar").hide();
                    }

                    if (event.data.class == 13) {
                        $(".menu-point[data-id='" + i + "'] .engineStateText").hide();
                        $(".menu-point[data-id='" + i + "'] .engineBar").hide();
                    }
                }

                $('#box').show();

                garageid = event.data.garage
                action = event.data.action
                break;
            case 'hide':
                $('#box').hide();
                break;
            default:
                console.log('ui_garages: unknown action!');
                break;
        }
    }, false);
});

function getColor(i) {
    var hue = i * 1.2 / 360;
    var rgb = hslToRgb(hue, 1, 0.5);
    return 'rgb(' + rgb[0] + ',' + rgb[1] + ',' + rgb[2] + ')';
}

function hslToRgb(h, s, l) {
    var r, g, b;

    if (s == 0) {
        r = g = b = l; // achromatic
    } else {
        var hue2rgb = function hue2rgb(p, q, t) {
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            if (t < 1 / 6) return p + (q - p) * 6 * t;
            if (t < 1 / 2) return q;
            if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
            return p;
        };

        var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        var p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    }

    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
}

function selectVehicle(plate, towed, blocked, owner) {
    $.post('https://garages/selectvehicle', JSON.stringify({
        plate: plate,
        garageid: garageid,
        action: action,
        towed: towed,
        blocked: blocked,
        owner: owner
    }));
}