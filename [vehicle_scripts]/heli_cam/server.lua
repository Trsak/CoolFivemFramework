RegisterNetEvent("heli_cam:startRapple")
AddEventHandler("heli_cam:startRapple", function()
    local client = source
    local sourcePed = NetworkGetNetworkIdFromEntity(GetPlayerPed(client))
    TriggerClientEvent("heli_cam:startRapple", -1, sourcePed)
end)
