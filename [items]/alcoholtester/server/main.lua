RegisterNetEvent("alcoholtester:getPlayerDrunkLevel")
AddEventHandler("alcoholtester:getPlayerDrunkLevel", function(target)
    local client = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(client))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if #(sourceCoords - targetCoords) <= 5.0 then

        local hasItem = exports.inventory:checkPlayerItem(client, "alcoholtester", 1, {})
        if hasItem then
            local needs = exports.data:getCharVar(target, "needs")
            if needs then
                if needs.drunk then
                    local promiles = needs.drunk
                    local typeOfNotify = "success"
                    if promiles < 30.0 and promiles > 0.0 then
                        typeOfNotify = "info"
                    elseif promiles < 60.0 and promiles >= 30.0 then
                        typeOfNotify = "warning"
                    elseif promiles < 90.0 and promiles >= 60.0 then
                        typeOfNotify = "error"
                    elseif promiles >= 90.0 then
                        typeOfNotify = "extreme"
                    end
                    TriggerClientEvent("notify:display", client, {
                        type = typeOfNotify,
                        title = "Alkohol tester",
                        text = "Osoba má " .. round((promiles / 30)) .. " promile!",
                        icon = "fas fa-glass-martini",
                        length = 3000
                    })
                else

                    TriggerClientEvent("notify:display", client, {
                        type = "success",
                        title = "Alkohol tester",
                        text = "Osoba má 0.00 promile!",
                        icon = "fas fa-glass-martini",
                        length = 3000
                    })
                end
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "warning",
                title = "Alkohol Tester",
                text = "Chybí ti alkohol tester!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    else
    end
end)

function round(number)
    return string.format("%.1f", number)
end
