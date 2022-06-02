RegisterNetEvent('qb-phone:client:addPoliceAlert')
AddEventHandler('qb-phone:client:addPoliceAlert', function(alertData)
    if PlayerData.MetaData.simActive.primary.job == "police" or PlayerData.MetaData.simActive.secondary.job == "police" then
        SendNUIMessage({
            action = "AddPoliceAlert",
            alert = alertData,
        })
    end
end)

RegisterNUICallback('FetchSearchResults', function(data, cb)
    cb("result")
end)

RegisterNUICallback('FetchVehicleResults', function(data, cb)
    cb("result")
end)

RegisterNUICallback('FetchVehicleScan', function(data, cb)
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 70)
    local plate = GetVehicleNumberPlateText(vehicle)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    --[[    QBCore.Functions.TriggerCallback('qb-phone:server:ScanPlate', function(result)
            QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
                result.isFlagged = flagged
                local vehicleInfo = QBCore.Shared.Vehicles[vehname] ~= nil and QBCore.Shared.Vehicles[vehname]["model"] or {["brand"] = "Unknown brand..", ["name"] = ""}
                result.label = vehicleInfo["name"]
                cb(result)
            end, plate)
        end, plate)]]
    cb("result")
end)

RegisterNUICallback('SetAlertWaypoint', function(data)
    local coords = data.alert.coords

    exports.notify:display({type = "success", title = "GPS", text = "nastavena:" ..data.alert.title.. "", icon = "fas fa-times", length = 5000})
    SetNewWaypoint(coords.x, coords.y)
end)