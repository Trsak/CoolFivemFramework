local shops = {}
local specialShops = {}
local shopsForClient = {}
local vehicles = {}
local OpenedShops = {}
local loaded = false

function getShops()
    return shops
end

Citizen.CreateThread(
    function()
        Wait(1000)

        while not exports.inventory:getAreItemsLoaded() do
            Wait(500)
        end

        MySQL.Async.fetchAll(
            "SELECT * FROM shops",
            {},
            function(result)
                if #result > 0 then
                    for i, res in each(result) do
                        local coords = json.decode(res.coords)
                        local pedCoords = json.decode(res.ped_coords)

                        shops[tostring(res.id)] = {
                            coords = vec3(coords.x, coords.y, coords.z),
                            ped_coords = pedCoords or nil,
                            name = Config.Blips[res.type].Label,
                            rob_details = json.decode(res.rob_details),
                            items = json.decode(res.items) or {},
                            type = res.type,
                            available = true,
                            changed = false
                        }

                        shopsForClient[tostring(res.id)] = {
                            coords = vec3(coords.x, coords.y, coords.z),
                            name = Config.Blips[res.type].Label,
                            type = res.type,
                            available = true
                        }

                        local shouldUpdateShopItems = false
                        local itemsToOrder = {}

                        for itemName, _ in pairs(Config.Products[res.type]) do
                            itemsToOrder[itemName] = true
                        end

                        for itemName, itemData in pairs(shops[tostring(res.id)].items) do
                            local productDetails = Config.Products[res.type][itemName]
                            if productDetails == nil or exports.inventory:getItem(itemName) == nil then
                                shops[tostring(res.id)].items[itemName] = nil
                                shouldUpdateShopItems = true
                                itemsToOrder[itemName] = nil
                            elseif itemData.price ~= productDetails.BasePrice then
                                shops[tostring(res.id)].items[itemName].price = productDetails.BasePrice
                                shouldUpdateShopItems = true
                            end

                            if productDetails ~= nil and itemData.count > 1 then
                                itemsToOrder[itemName] = nil
                            end
                        end

                        if next(itemsToOrder) then
                            local orderItemsList = {}

                            for itemName, _ in pairs(itemsToOrder) do
                                local productDetails = Config.Products[res.type][itemName]

                                if not exports.inventory:getItem(itemName) then
                                    print("ERROR! STORE!", itemName, res.id)
                                elseif productDetails then
                                    orderItemsList[itemName] = {
                                        name = itemName,
                                        count = productDetails.OrderAmount,
                                        price = productDetails.BasePrice,
                                        label = exports.inventory:getItem(itemName).label,
                                        license = productDetails.License
                                    }
                                end
                            end

                            exports.orders:createOrder(
                                tonumber(res.id),
                                res.type,
                                orderItemsList,
                                0
                            )
                        end

                        if shouldUpdateShopItems then
                            shops[tostring(res.id)].changed = true
                        end
                    end
                end
                MySQL.Async.fetchAll(
                    "SELECT * FROM cardealer_vehicle",
                    {},
                    function(result)
                        if #result > 0 then
                            for i, res in each(result) do
                                vehicles[res.model] = res.baseprice
                            end
                        end
                    end
                )
                loaded = true

                TriggerLatentClientEvent("shops:sync", -1, 100000, shopsForClient)
                print("^3[BASE_SHOPS]^7 Successfully loaded with " .. tableLength(shops) .. " shops!")

                SetTimeout(3600000, saveChangedShops)
            end
        )
    end
)

function saveChangedShops()
    for shop, shopData in pairs(shops) do
        if shopData.changed then
            shopData.changed = false
            MySQL.Async.execute(
                "UPDATE shops SET rob_details = :rob, items = :items WHERE id = :shopid",
                {
                    shopid = tonumber(shop),
                    rob = json.encode(shopData.rob_details),
                    items = json.encode(shopData.items)
                }
            )
        end
    end

    SetTimeout(60000, saveChangedShops)
end

RegisterNetEvent("shops:sync")
AddEventHandler(
    "shops:sync",
    function()
        local client = source
        while not loaded do
            Wait(200)
        end
        TriggerLatentClientEvent("shops:sync", client, 100000, shopsForClient)
    end
)

RegisterNetEvent("base_shops:openShop")
AddEventHandler(
    "base_shops:openShop",
    function(shopId)
        local client = source
        TriggerClientEvent("inventory:loadShop", client, shopId, shops[shopId])
    end
)

function addItemToShop(shop, itemName, count, price, license)
    if shops[shop] == nil then
        return
    end

    local item = exports.inventory:getItem(itemName)
    if item then
        local found = false
        if shops[shop].items[itemName] then
            shops[shop].items[itemName].count = shops[shop].items[itemName].count + count
            found = true
        end

        if not found then
            shops[shop].items[itemName] = {
                name = itemName,
                count = count,
                price = price,
                label = item.label,
                license = license
            }
        end
        shops[shop].changed = true

        updateShopData(shop, false)
    end
end

function buyItem(client, shop, itemName, count, slot, isSpecial)
    local item
    if isSpecial then
        item = specialShops[shop].items[itemName]
    else
        item = shops[shop].items[itemName]
    end

    local itemData = exports.inventory:getItem(itemName)
    local itemType = itemData.type
    if not item then
        return "notInShop"
    end

    if item.count < count then
        return "notInStock"
    end
    if item.name == "phone" or item.name == "sim" or itemType == "weapon" or string.match(itemName, "magazine_") then
        count = 1
    end

    local hasCash = exports.inventory:checkPlayerItem(client, "cash", (count * item.price), {})
    if hasCash then
        local data, number = {}, ""
        if itemType == "weapon" then
            data = {
                id = os.time() .. math.random(100000, 999999)
            }

            if itemData.isMelee ~= nil and not itemData.isMelee then
                if isSpecial then
                    data = {
                        id = os.time() .. math.random(100000, 999999),
                        label = "Zbraň nemá sériové číslo"
                    }
                else
                    number = generateSerialNumber()

                    local registerResult = exports.register_weapons:registerWeapon(number, exports.data:getCharVar(client, "id"), item.label, os.time())

                    while registerResult ~= "done" do
                        Wait(1)
                        number = generateSerialNumber()
                        registerResult = exports.register_weapons:registerWeapon(number, exports.data:getCharVar(client, "id"), item.label, os.time())
                    end

                    data = {
                        id = number,
                        number = number,
                        time = os.time(),
                        label = "Seriové číslo: " .. number .. "<br>Datum vydání: " .. os.date("%x", os.time())
                    }
                end
            end
        elseif itemName == "joint_paper" then
            data = {
                id = 10,
                amount = 10,
                label = "Zbývá: 10",
            }
        end

        local addResult = "error"
        if not string.match(itemName, "_glass") and itemName ~= "shot" and exports.food:getItem(itemName) then
            addResult = exports.food:giveItem(client, itemName, count, slot)
        elseif string.match(itemName, "cigs_") or string.match(itemName, "cigars_") then
            addResult = exports.smokable:givePack(client, itemName, count, slot)
        elseif itemName == "phone" or itemName == "sim" then
            addResult = exports.phone:create({ client, (itemName == "phone" and "IFruit" or "Basic") })
        else
            addResult = exports.inventory:addPlayerItem(client, itemName, count, data, slot)
        end

        if addResult == "done" then
            exports.inventory:removePlayerItem(client, "cash", (count * item.price), {})
            if isSpecial then
                specialShops[shop].items[itemName].count = specialShops[shop].items[itemName].count - count
            else
                shops[shop].items[itemName].count = shops[shop].items[itemName].count - count
            end

            local text = "Zakoupil " ..
                count ..
                "x " ..
                item.label ..
                "\nCelková cena: $" .. count * item.price .. " \nCena jednoho itemu: $" .. item.price

            if number ~= "" then
                text = text .. " \nSériové číslo: " .. number
            end

            exports.logs:sendToDiscord(
                {
                    channel = "shops",
                    title = isSpecial and shop or Config.Blips[shops[shop].type].Label,
                    description = text,
                    color = "34749"
                },
                client
            )

            if isSpecial then
                if specialShops[shop].items[itemName].count <= 0 then
                    specialShops[shop].items[itemName] = nil
                end
            else
                local type = shops[shop].type
                if Config.Products[type][itemName] then
                    if shops[shop].items[itemName].count <= 0 then
                        exports.orders:createOrder(
                            tonumber(shop),
                            type,
                            {
                                [itemName] = {
                                    name = itemName,
                                    count = Config.Products[type][itemName].OrderAmount,
                                    price = Config.Products[type][itemName].BasePrice,
                                    label = itemData.label,
                                    license = Config.Products[type][itemName].License
                                }
                            },
                            0
                        )
                    end
                end

                if shops[shop].items[itemName].count <= 0 then
                    shops[shop].items[itemName] = nil
                end

                shops[shop].changed = true
            end

            updateShopData(shop, isSpecial)

            if isSpecial and not next(specialShops[shop].items) then
                TriggerEvent("base_shops:specialShopEmpty", shop)
            end

            return "done"
        else
            return addResult
        end
    else
        return "noMoney"
    end
end

function generateSerialNumber()
    local number = ""
    for i = 1, 15 do
        number = number .. Config.SerialChars[math.random(#Config.SerialChars)]
    end
    return number
end

RegisterNetEvent("shops:buyItem")
AddEventHandler(
    "shops:buyItem",
    function(shopid, itemname, count)
        local client = source
        buyItem(client, shopid, itemname, count)
    end
)

RegisterNetEvent("base_shops:create")
AddEventHandler(
    "base_shops:create",
    function(data)
        local client = source
        if exports.data:getUserVar(client, "admin") > 2 then
            MySQL.Async.insert(
                "INSERT INTO shops (coords, ped_coords, rob_details, items, type) VALUES (:coords, :ped_coords , :rob_details, :items, :type)",
                {
                    coords = json.encode({ x = data.Coords.x, y = data.Coords.y, z = data.Coords.z }),
                    ped_coords = json.encode(
                        data.PedCoords and
                            { x = data.PedCoords.x, y = data.PedCoords.y, z = data.PedCoords.z, h = data.PedCoords.w } or
                            {}
                    ),
                    rob_details = json.encode(Config.defaultRobDetails),
                    items = "",
                    type = data.Type
                },
                function(shopId)
                    if shopId then
                        shops[tostring(shopId)] = {
                            coords = data.Coords,
                            ped_coords = data.PedCoords,
                            rob_details = Config.defaultRobDetails,
                            items = {},
                            type = data.Type
                        }
                    end
                end
            )

            TriggerClientEvent("shops:sync", client, shops, vehicles)
        end
    end
)

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

RegisterCommand(
    "restockShop",
    function(source, args)
        local client = source
        if (client == 0 or exports.data:getUserVar(client, "admin") > 2) and args[1] and shops[args[1]] then
            shops[args[1]].items = {}
            for itemName, itemData in pairs(Config.Products[shops[args[1]].type]) do
                addItemToShop(args[1], itemName, itemData.OrderAmount, itemData.BasePrice, itemData.License)
            end
        end
    end
)

function createSpecialShop(name, items)
    specialShops[name] = {
        name = name,
        items = items or {},
        available = true,
        changed = false
    }

    updateShopData(name, true)
end

RegisterNetEvent("base_shops:openSpecialShop")
AddEventHandler(
    "base_shops:openSpecialShop",
    function(shopId)
        local client = source
        TriggerClientEvent("inventory:loadShop", client, shopId, specialShops[shopId], true)
    end

)

function updateShopData(shop, isSpecial)
    for openedClient, openedShop in pairs(OpenedShops) do
        if openedShop == shop then
            if isSpecial then
                TriggerClientEvent("inventory:shopUpdated", openedClient, shop, specialShops[shop])
            else
                TriggerClientEvent("inventory:shopUpdated", openedClient, shop, shops[shop])
            end
        end
    end
end

RegisterNetEvent("inventory:setOpenedShop")
AddEventHandler(
    "inventory:setOpenedShop",
    function(openedShop)
        local client = source
        OpenedShops[client] = openedShop
    end
)

AddEventHandler(
    "playerDropped",
    function()
        local client = source

        if OpenedShops[client] then
            OpenedShops[client] = nil
        end
    end
)
