RegisterNetEvent("sack:putSackOnPlayer")
AddEventHandler("sack:putSackOnPlayer", function(target)
    local client = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(client))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local isDead = (exports.data:getUserVar(target, "status") == "dead")
    if #(sourceCoords - targetCoords) <= (isDead and 200.0  or 50.0) then
        local hasItem = exports.inventory:removePlayerItem(client, "sack", 1, {})
        if hasItem == "done" then
            TriggerClientEvent("sack:putSackOnPlayer", target, client)
            Player(target).state.hasSack = true
            TriggerClientEvent("notify:display", client, {
                type = "success",
                title = "Pytel",
                text = "Nandal/a jsi někomu pytel!",
                icon = "fas fa-ghost",
                length = 3000
            })
        else
            TriggerClientEvent("notify:display", client, {
                type = "warning",
                title = "Pytel",
                text = "Chybí ti pytel!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    else
        exports.admin:banClientForCheating(client, "0", "Cheating", "sack:putSackOnPlayer",
            "Hráč se pokusil dát pytel na hlavu někomu, kdo není blízko!".. #(sourceCoords - targetCoords))
    end
end)

RegisterNetEvent("sack:takeOffSackFromPlayer")
AddEventHandler("sack:takeOffSackFromPlayer", function(target)
    local client, canTakeoff = source, false
    local sourceCoords, targetCoords = nil, nil
    if target then
        sourceCoords = GetEntityCoords(GetPlayerPed(client))
        targetCoords = GetEntityCoords(GetPlayerPed(target))
        local isDead = (exports.data:getUserVar(target, "status") == "dead")
        if #(sourceCoords - targetCoords) <= (isDead and 200.0  or 50.0) then
            canTakeoff = true
        end
    elseif Player(client).state.hasSack and not Player(client).state.isCuffed then
        canTakeoff = true
    end
    if canTakeoff then
        local done = exports.inventory:forceAddPlayerItem(client, "sack", 1, {})
        TriggerClientEvent("sack:takeOffSackFromPlayer", target or client, client)
        Player(target or client).state.hasSack = false
        if not target then
            TriggerClientEvent("notify:display", client, {
                type = "success",
                title = "Pytel",
                text = "Sundal/a sis pytel!",
                icon = "fas fa-ghost",
                length = 3000
            })
        else

            TriggerClientEvent("notify:display", client, {
                type = "success",
                title = "Pytel",
                text = "Sundal/a jsi někomu pytel!",
                icon = "fas fa-ghost",
                length = 3000
            })
        end
    end
end)
Player(2).state.hasSack = false
Player(1).state.hasSack = false
