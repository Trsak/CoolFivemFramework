$(document).on('click', '.garage-vehicle', function(e) {
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 30 + "vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: 0 + "vh"
    }, 200);

    var Id = $(this).attr('id');
    var VehData = $("#" + Id).data('VehicleData');
    SetupDetails(VehData);
});

$(document).on('click', '.garage-cardetails-footer', function(e) {
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 00 + "vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: -30 + "vh"
    }, 200);
});

SetupGarageVehicles = function(Vehicles) {
    $(".garage-vehicles").html("");
    if (Vehicles != null) {
        $.each(Vehicles, function(i, vehicle) {
            var Element = '<div class="garage-vehicle" id="vehicle-' + i + '"> <span class="garage-vehicle-firstletter">' + vehicle.in_garage + '</span> <span class="garage-vehicle-name">' + vehicle.data.DisplayName + '</span> </div>';

            $(".garage-vehicles").append(Element);
            $("#vehicle-" + i).data('VehicleData', vehicle);
        });
    }
}

SetupDetails = function(data) {
    $(".vehicle-brand").find(".vehicle-answer").html(data.data.model);
    $(".vehicle-model").find(".vehicle-answer").html(data.data.DisplayName);
    $(".vehicle-plate").find(".vehicle-answer").html(data.spz);
    $(".vehicle-garage").find(".vehicle-answer").html(data.in_garage);
    $(".vehicle-garage").data('garage_ID', data.garage_coords);
    var status = "Venku"
    if (data.in_garage !== 0) {
        status = 'V garáži'
    }
    if (data.towed) {
        status = "Odtaženo"
    }
    $(".vehicle-status").find(".vehicle-answer").html(status);
    $(".vehicle-fuel").find(".vehicle-answer").html(Math.ceil(data.data.fuelLevel) + "%");
    $(".vehicle-engine").find(".vehicle-answer").html(Math.ceil(data.data.engineHealth / 10) + "%");
    $(".vehicle-body").find(".vehicle-answer").html(Math.ceil(data.data.bodyHealth / 10) + "%");
}

$(document).on('click', '.vehicle-garage', function(e) {
    e.preventDefault();
    var garageCoords = $(".vehicle-garage").data('garage_ID');
    if (garageCoords.x !== undefined && garageCoords.y !== undefined) {
        $.post('https://phone/SetGarageWP', JSON.stringify({
            garageCoords: garageCoords,
        }));
        QB.Phone.Notifications.Add("fas fa-warehouse", "Garage", "Waypoint is set!", "#00ff04", 1000);
    }
});