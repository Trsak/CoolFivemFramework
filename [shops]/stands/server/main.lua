local buying = {}

RegisterNetEvent("stands:buyItem")
AddEventHandler(
    "stands:buyItem",
    function(data)
        local client = source
        local price = Config.TrackedEntities[data.type].Selling[data.item].Price

        local removedMoney = "done"
        if price > 0 then
            removedMoney = exports.inventory:removePlayerItem(client, "cash", price, {})
        end

        if removedMoney == "done" then
            buying[tostring(client)] = data.item
            TriggerClientEvent("stands:Random", client, data, Config.TrackedEntities[data.type].Selling[data.item])
        else
            TriggerClientEvent("stands:notEnoughMoney", client, price)
        end
    end
)

RegisterNetEvent("stands:giveItem")
AddEventHandler(
    "stands:giveItem",
    function()
        local client = source
        if buying[tostring(client)] then
            exports.food:giveItem(client, buying[tostring(client)], 1)
            buying[tostring(client)] = nil
        end
    end
)
