RegisterNetEvent("plate:getVehiclePlate")
AddEventHandler(
    "plate:getVehiclePlate",
    function(plateText, plateTextIndex)
        local _source = source
        exports.inventory:forceAddPlayerItem(_source, "plate", 1, {id = plateText, label = "SPZ: " .. plateText, plateText = plateText, plateIndex = plateTextIndex})
    end
)

RegisterNetEvent("plate:usedPlate")
AddEventHandler(
    "plate:usedPlate",
    function(data, slot)
        local _source = source
        exports.inventory:removePlayerItem(_source, "plate", 1, data, slot)
    end
)

RegisterNetEvent("plate:setVehicleNumberPlate")
AddEventHandler(
    "plate:setVehicleNumberPlate",
    function(netId, plate, plateIndex)
        
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        local owner = NetworkGetEntityOwner(vehicle)

        if owner > 0 then

            TriggerClientEvent("plate:setVehicleNumberPlate", owner, netId, plate, plateIndex)

        else

            SetVehicleNumberPlateText(vehicle, plate)
            if plateIndex then
                SetVehicleNumberPlateTextIndex(vehicle, plateIndex)
            end
        end
    end
)
