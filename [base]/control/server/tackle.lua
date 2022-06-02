RegisterNetEvent('playerTackled')
AddEventHandler('playerTackled', function(clientTackled)
    TriggerClientEvent("playerTackled", clientTackled)
end)