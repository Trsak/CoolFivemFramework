RegisterNUICallback('TransferCid', function(data, cb)
    local TransferedCid = data.newBsn

    --[[QBCore.Functions.TriggerCallback('qb-phone:server:TransferCid', function(CanTransfer)
            cb(CanTransfer)
        end, TransferedCid, data.HouseData)]]
end)

RegisterNUICallback('FetchPlayerHouses', function(data, cb)
    --[[QBCore.Functions.TriggerCallback('qb-phone:server:MeosGetPlayerHouses', function(result)
            cb(result)
        end, data.input)]]
end)


RegisterNUICallback('SetGPSLocation', function(data, cb)
    local ped = PlayerPedId()

    SetNewWaypoint(data.coords.x, data.coords.y)
    exports.notify:display({type = "success", title = "GPS", text = "Byla nastavena", icon = "fas fa-times", length = 5000})
end)

RegisterNUICallback('SetApartmentLocation', function(data, cb)
    --[[local ApartmentData = data.data.appartmentdata
        local TypeData = Apartments.Locations[ApartmentData.type]

        SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
        exports.notify:display({type = "success", title = "GPS", text = "Byla nastavena", icon = "fas fa-times", length = 5000})]]
end)

RegisterNUICallback('GetPlayerHouses', function(data, cb)
    --[[QBCore.Functions.TriggerCallback('qb-phone:server:GetPlayerHouses', function(Houses)
            cb(Houses)
        end)]]
end)

RegisterNUICallback('GetPlayerKeys', function(data, cb)
    --[[QBCore.Functions.TriggerCallback('qb-phone:server:GetHouseKeys', function(Keys)
            cb(Keys)
        end)]]
end)

RegisterNUICallback('SetHouseLocation', function(data, cb)
    --[[SetNewWaypoint(data.HouseData.HouseData.coords.enter.x, data.HouseData.HouseData.coords.enter.y)
        exports.notify:display({type = "success", title = "GPS", text = "Byla nastavena na" .. data.HouseData.HouseData.adress .. "", icon = "fas fa-times", length = 5000})]]
end)

RegisterNUICallback('RemoveKeyholder', function(data)
    --[[    TriggerServerEvent('qb-houses:server:removeHouseKey', data.HouseData.name, {
            citizenid = data.HolderData.citizenid,
            firstname = data.HolderData.charinfo.firstname,
            lastname = data.HolderData.charinfo.lastname,
        })]]
end)