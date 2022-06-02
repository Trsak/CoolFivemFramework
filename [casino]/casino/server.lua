RegisterNetEvent("casino:buyChips")
AddEventHandler("casino:buyChips",
    function(chipsValue)
        local client = source

        local removeResult = exports.inventory:removePlayerItem(client, "cash", chipsValue, {})
        if removeResult == "done" then
            exports.logs:sendToDiscord(
                {
                    channel = "casino",
                    title = "Nákup žetonů",
                    description = "Nakoupil žetony za " .. exports.data:getFormattedCurrency(chipsValue),
                    color = "3066993"
                },
                client
            )

            exports.inventory:addCasinoChips(client, chipsValue)
            TriggerClientEvent("casino:boughtChips", client, chipsValue)
        else
            TriggerClientEvent("casino:notEnoughMoney", client)
        end
    end
)

RegisterNetEvent("casino:sellChips")
AddEventHandler("casino:sellChips",
    function(chipsValue)
        local client = source

        if chipsValue == -1 then
            chipsValue = exports.inventory:getCasinoChipsTotalValue(client)
        end
        local removeChops = exports.inventory:removeCasinoChipsByValue(client, chipsValue)

        if removeChops == "done" then
            exports.logs:sendToDiscord(
                {
                    channel = "casino",
                    title = "Prodej žetonů",
                    description = "Prodal žetony za " .. exports.data:getFormattedCurrency(chipsValue),
                    color = "2067276"
                },
                client
            )

            exports.inventory:forceAddPlayerItem(client, "cash", chipsValue, {}, nil, true)
            TriggerClientEvent("casino:soldChips", client, chipsValue)
        else
            TriggerClientEvent("casino:notEnoughChips", client)
        end
    end
)

RegisterCommand("resetCasinoChipsPed", function(source, args)
    if exports.data:getUserVar(source, "admin") == 3 then
        TriggerClientEvent("casino:reset", -1)
    end
end)

RegisterCommand("resetGambleAllPeds", function(source, args)
    if exports.data:getUserVar(source, "admin") == 3 then
        TriggerClientEvent("casino:resetAll", -1)
    end
end)