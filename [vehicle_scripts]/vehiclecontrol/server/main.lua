RegisterNetEvent("vehiclecontrol:destroyTire")
AddEventHandler(
    "vehiclecontrol:destroyTire",
    function(vehicle, tireIndex)
        local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(vehicle))

        if owner then
            TriggerClientEvent("vehiclecontrol:destroyTire", owner, vehicle, tireIndex)
        end
    end
)
