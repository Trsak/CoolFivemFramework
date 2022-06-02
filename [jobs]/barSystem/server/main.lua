local TE, TCE,TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent,TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local consumables = {}
local loaded = false
Config.Debug = exports.control:isDev()
MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM consumables", {}, function(items)
        for _, v in each(Config.Categories) do
            consumables[v] = {}
        end
        for _, v in each(items) do
            consumables[v.type][v.label] = {
                id = v.id,
                capacity = v.capacity,
                volume = v.volume,
                img = v.img,
                description= v.description,
                unique = v.unique2,
                cost = json.decode(v.cost) or {},
                production = json.decode(v.production)[1] or false,
                restaurants =  json.decode(v.restaurants) or {}
            }
        end
    end)
    SetTimeout(Config.Wait, saveAll)
end)

function createMenu(restaurant)
    local menu = {}
    for type, item in each(consumables) do
        menu[type] = {}
        for name, data in each(item) do
            if data.restaurants and data.cost then
                if data.restaurants and data.cost then
                    menu[type][name] = {
                        id = data.id,
                        capacity = data.capacity,
                        volume = data.volume,
                        img = data.img,
                        description= data.description,
                        unique = data.unique,
                        cost = data.cost[restaurant] or false,
                        production = data.production,
                        restaurants = data.restaurants[restaurant] or false
                    }
                end
            end
        end
    end
    return menu
end

RSE(GetHandlerName('getMeConsumables'))
AEH(GetHandlerName('getMeConsumables'), function()
    TCE(GetHandlerName('getMeConsumables'), source, consumables)
end)

RSE(GetHandlerName('openMenu'))
AEH(GetHandlerName('openMenu'), function(itemName, restaurant)
    local _source = source
    local menu = createMenu(restaurant)
    if menu then
        SetTimeout(50, function()
            TCE(GetHandlerName('openMenu'), _source, restaurant, itemName, menu)
        end)
    end
end)

RSE(GetHandlerName('makeMenu'))
AEH(GetHandlerName('makeMenu'), function(item, data)
    local _source = source
    if item.data.id == nil then
        exports.inventory:updateItemDataBySlot(_source, item.slot, itemData)
    end
end)

RSE(GetHandlerName('UpdateItem'))
AEH(GetHandlerName('UpdateItem'), function(action, data, restaurant)
    local _source = source
    local drinkId = tonumber(data.drinkId)
    if action == "addToMenu" then
        for type, item in each(consumables) do
            for name, data2 in each(item) do
                if data2.id == drinkId then
                    if not consumables[type][name].restaurants[restaurant] then
                        consumables[type][name].restaurants[restaurant] = true
                        break
                    end
                end
            end
        end
    elseif action == "removeFromMenu" then
        for type, item in each(consumables) do
            for name, data2 in each(item) do
                if data2.id == tonumber(drinkId) then
                    if consumables[type][name].restaurants[restaurant] then
                        consumables[type][name].restaurants[restaurant] = false
                        break
                    end
                end
            end
        end
    elseif action == "changePrice" then
        local price = tonumber(data.price)
        for type, item in each(consumables) do
            for name, data2 in each(item) do
                if data2.id == drinkId then
                    consumables[type][name].cost[restaurant] = price
                    break
                end
            end
        end
    end
    local menu = createMenu(restaurant)
    if menu then
        SetTimeout(50, function()
            TCE(GetHandlerName('refreshMenu'), _source, restaurant, "alcohol_menu", menu)
        end)
    end
end)

RSE(GetHandlerName("CreateDrink"))
AEH(GetHandlerName("CreateDrink"), function(data)
    local Player = exports.data:getUser(source).nickname
    --webhookImage = 'https://i.imgur.com/6kaSkjJ.gifv'
    local webhookImage = 'https://www.realbookies.com/wp-content/uploads/2019/03/reporting-analytics_60.png'
    if exports.control:isDev() then
        webhookUrl = 'https://discord.com/api/webhooks/'
    else
        webhookUrl = "https://discord.com/api/webhooks/"
    end

    content = '```Chce vytvořit drink: \n name: ' .. data.name .. '\n type: ' .. data.type .. '\n description:' .. data.description .. '\n volume: ' .. data.volume .. '\n capacity: ' .. data.capacity .. '\n unique:' .. data.unique .. '```'

    PerformHttpRequest(webhookUrl, function(e, t, h) end, 'POST', json.encode({
        username = Player,
        content = content

    }), { ['Content-Type'] = 'application/json' })
    TCE("notify:display", _source, {type = "success", title = "Odesláno", text = "Tvůj návrh byl zaslán! 👿", icon = "fas fa-times", length = 5000})
end)

function saveAll()
    for _, consumable in each(consumables) do
        for _, drink in each(consumable) do
            MySQL.Async.fetchAll("UPDATE consumables SET restaurants=@restaurants, cost=@cost WHERE id=@id", {
                ["@restaurants"] = json.encode(drink.restaurants),
                ["@cost"] = json.encode(drink.cost),
                ["@id"] = drink.id
            })
            Wait(5)
        end
    end
    SetTimeout(Config.Wait, saveAll)
end

function getConsumable(drinkId)
    if type(drinkId) == "number" then
        for type, item in each(consumables) do
            for name, data in each(item) do
                if data.id == drinkId then
                    return consumables[type][name]
                end
            end
        end
    elseif type(drinkId) == "string" then
        for type, item in each(consumables) do
            for name, data in each(item) do
                if data.img == drinkId then
                    return consumables[type][name]
                end
            end
        end
    end
    return nil
end

function getConsumables()
    return consumables
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 180 then
        CreateThread(function()
            saveAll()
        end)
    end
end)

RegisterCommand('saveAllBarSystem', function(source, args)
    if exports.data:getUserVar(source, "admin") > 2 then
        saveAll()
    end
end, false)

RegisterCommand('givebaritem', function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        data = {
            item = args[2],
            id = args[3]
        }
        exports.inventory:addPlayerItem(tonumber(args[1]), data.item, 1, data)
    end
end, false)

--[[
local fileJson = nil
local dataJson = nil

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        fileJson = jsonLoadFile(GetResourcePath(GetCurrentResourceName()).."/consumables.json")
        dataJson = jsonLoadData(fileJson)
    end
end)

function jsonLoadFile(file)
    local file = io.open(file, "r" )
    return file
end

function jsonLoadData(file)
    local content = ""
    local dataTable = {}
    if file then
        content = file:read( "*a" )
        dataTable = json.decode(content);
        return dataTable
    end
    --io.close( file )
    return file
end

RegisterCommand('saveData', function(source, args)
    if exports.data:getUserVar(source, "admin") == 5 then
        --Utils.DumpTable(dataJson)
        for _, v in each(dataJson) do
            print(json.encode(v.production))
            MySQL.Async.execute(
                    "INSERT INTO consumables (label, type, description, img, unique2, production, capacity, volume, restaurants, cost) VALUES (@label, @type, @description, @img, @unique2, @production, @capacity, @volume, @restaurants, @cost)",
                    {
                        ["@label"] = v.label,
                        ["@type"] = v.type,
                        ["@description"] = v.description,
                        ["@img"] = v.img,
                        ["@unique2"] = v.unique2,
                        ["@production"] = json.encode(v.production),
                        ["@capacity"] = v.capacity,
                        ["@volume"] = v.volume,
                        ["@restaurants"] = json.encode(v.restaurants),
                        ["@cost"] = json.encode(v.cost)
                    })
        end
    end
end, false)]]
