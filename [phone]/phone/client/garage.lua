RegisterNUICallback('SetupGarageVehicles', function(data, cb)
    TriggerServerEvent('qb-phone:server:SetupGarageVehicles', PhoneData.MetaData.id)
    RegisterNetEvent("qb-phone:client:SetupGarageVehicles")
    AddEventHandler("qb-phone:client:SetupGarageVehicles", function(garage)
        local garages = garage
        for i, vehData in each(garages) do
            local DisplayName = GetLabelText(GetDisplayNameFromVehicleModel(vehData.data.model))
            if DisplayName == "NULL" then
                DisplayName = exports.base_vehicles:getVehicleNameByHash(vehData.data.model)
            end
            vehData.data.DisplayName = DisplayName
        end
        PhoneData.GarageVehicles = garage
        cb(PhoneData.GarageVehicles)
    end)
end)

RegisterNUICallback('SetGarageWP', function(data)
    SetNewWaypoint(data.garageCoords.x, data.garageCoords.y)
end)