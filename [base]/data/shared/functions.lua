function getFormattedCurrency(value)
    local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
    return "$" .. left .. (num:reverse():gsub('(%d%d%d)', '%1' .. ","):reverse()) .. right
end

function getVehicleActualPlateNumber(vehicle)
    if DoesEntityExist(vehicle) then
        local veh = Entity(vehicle)
        if veh.state.actualPlate then
            return veh.state.actualPlate
        end

        return GetVehicleNumberPlateText(vehicle)
    end

    return nil
end

function getVehicleVin(vehicle)
    if DoesEntityExist(vehicle) then
        local veh = Entity(vehicle)
        if veh.state.vin then
            return veh.state.vin
        end
        return "error"
    end

    return nil
end

function setVehicleActualPlateText(netId, plateText)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local ent = Entity(vehicle)
    if not ent.state.actualPlate then
        Entity(vehicle).state:set('actualPlate', plateText, true)
    end
end