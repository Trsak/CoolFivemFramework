RegisterNetEvent("vending_machine:buyItem")
AddEventHandler(
    "vending_machine:buyItem",
    function(entity, type)
        local _source = source
        local price = Config.TrackedEntities[type].price

        local removedMoney = "done"
        if price > 0 then
            removedMoney = exports.inventory:removePlayerItem(_source, "cash", price, {})
        end

        if removedMoney == "done" then
            TriggerClientEvent("vending_machine:Random", _source, entity, Config.TrackedEntities[type], type)
        else
            TriggerClientEvent("vending_machine:notEnoughMoney", _source, price)
        end
    end
)

RegisterNetEvent("vending_machine:giveItem")
AddEventHandler(
    "vending_machine:giveItem",
    function(type)
        local _source = source
        local items = Config.TrackedEntities[type].items

        exports.food:giveItem(_source, items[math.random(#items)], 1)
    end
)
