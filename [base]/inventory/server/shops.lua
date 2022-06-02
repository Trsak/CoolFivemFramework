RegisterNetEvent("inventory:buyShopItem")
AddEventHandler(
    "inventory:buyShopItem",
    function(shop, item, slot, count, isSpecial)
        local _source = source

        if not checkAndSetTimer(_source, "buyShopItem", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local buyResult = exports.base_shops:buyItem(_source, shop, item, count, slot, isSpecial)
        if buyResult ~= "done" then
            TriggerClientEvent("inventory:error", _source, buyResult)
        else
            local identifier = GetPlayerIdentifier(_source, 0)
            reloadInventory(_source, Inventories[identifier])
        end
    end
)
