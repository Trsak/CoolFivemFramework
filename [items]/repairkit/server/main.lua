RegisterNetEvent("repairkit:repair")
AddEventHandler(
    "repairkit:repair",
    function(vehicle, engine, design, clean)
        local veh = NetworkGetEntityFromNetworkId(vehicle)
        local owner = NetworkGetEntityOwner(veh)

        if engine then
            SetVehicleBodyHealth(veh, 1000.0)
        end

        if clean then
            SetVehicleDirtLevel(vehicle, 0.0)
        end

        if owner and owner > 0 then
            TriggerClientEvent("repairkit:repair", owner, vehicle, engine, design, clean)
        end
    end
)
