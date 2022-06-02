local shops = nil
local robbedShops = {}

local restartDelay = true

Citizen.CreateThread(function()
    shops = exports.base_shops:getShops()
    for i, shop in each(shops) do
        shop.alarm = false
        shop.robbed = false
        shop.rob_percent = 0
    end
    TriggerClientEvent("rob_shops:updateShops", -1, shops, robbedShops, restartDelay)

    Citizen.Wait(Config.delayDuration)
    restartDelay = false
    TriggerClientEvent("rob_shops:restartDelaySync", -1, restartDelay)
end)
RegisterNetEvent("data:recieveShops")
AddEventHandler("data:recieveShops", function(shopData)
    shops = shopData

    for i, shop in pairs(shops) do
        if not shop.robber then
            shop.alarm = false
            shop.robbed = false
            shop.rob_percent = 0
        end
    end
    TriggerClientEvent("rob_shops:updateShops", -1, shops, robbedShops)
end)

RegisterNetEvent("rob_shops:restartDelaySync")
AddEventHandler("rob_shops:restartDelaySync", function(status)
    restartDelay = status
    TriggerClientEvent("rob_shops:restartDelaySync", -1, restartDelay)
end)

RegisterNetEvent("rob_shops:askForShops")
AddEventHandler("rob_shops:askForShops", function()
    local _source = source
    while not shops do
        Wait(50)
    end

    TriggerClientEvent("rob_shops:updateShops", _source, shops, robbedShops, restartDelay)
end)

RegisterNetEvent("rob_shops:countCops")
AddEventHandler("rob_shops:countCops", function()
    local _source = source
    TriggerClientEvent("rob_shops:countCops", _source, exports.data:countEmployees(nil, "police", nil, true))
end)

RegisterNetEvent("rob_shops:beginRob")
AddEventHandler("rob_shops:beginRob", function(shop)
    shops[shop].robbed = true
    shops[shop].robber = source

    TriggerEvent("outlawalert:sendAlert", {
        Type = "shop",
        Coords = shops[shop].coords
    })
    exports.logs:sendToDiscord({
        channel = "rob_shops",
        title = "Vykrádání obchodů",
        description = "Začal vykrádat obchod!",
        color = "34749"
    }, source)
    robbedShops[shop] = true

    TriggerClientEvent("rob_shops:syncRobbed", -1, robbedShops)

    Citizen.SetTimeout(shops[shop].rob_details.baseDelay, function()
        shops[shop].robbed = false
        robbedShops[shop] = nil
        TriggerClientEvent("rob_shops:syncRobbed", -1, robbedShops)
    end)
end)

RegisterNetEvent("rob_shops:triggerAnim")
AddEventHandler("rob_shops:triggerAnim", function(shop, anim)
    local client = source
    TriggerClientEvent("rob_shops:triggerAnim", -1, shop, anim)
    if anim == "hidden" and shops[shop].robber == client then
        local choosedAmount = math.random(shops[shop].rob_details.loot.min, shops[shop].rob_details.loot.max)

        exports.logs:sendToDiscord({
            channel = "rob_shops",
            title = "Vykrádání obchodů",
            description = "Získal $" .. choosedAmount,
            color = "34749"
        }, client)
        exports.inventory:itemDropped({
            name = "cash",
            count = choosedAmount,
            data = {}
        }, choosedAmount, vec3(shops[shop].coords.x, shops[shop].coords.y, shops[shop].coords.z))
        recreateShop(shop)
    end
end)

RegisterNetEvent("rob_shops:cashierDeath")
AddEventHandler("rob_shops:cashierDeath", function(shop, ped)
    TriggerClientEvent("rob_shops:cashierDeath", -1, shop, ped)
    recreateShop(shop)
end)

RegisterNetEvent("rob_shops:robbed")
AddEventHandler("rob_shops:robbed", function(shop, result)
    TriggerClientEvent("rob_shops:robbed", -1, shop)
    if result then
        TriggerClientEvent("rob_shops:triggerAnim", -1, shop, result)
    end
end)

function recreateShop(shop)
    shops[shop].robber = 0
end
