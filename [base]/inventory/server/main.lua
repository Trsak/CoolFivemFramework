OpenedInventories = {}
OpenedStorages = {}

Items = {}
Timers = {}
Inventories = {}
Drops = {}
Storages = {}

local areItemsLoaded = false

MySQL.ready(
    function()
        Wait(500)

        MySQL.Async.fetchAll(
            "SELECT * FROM items",
            {},
            function(items)
                for _, item in each(items) do
                    Items[item.name] = item
                end

                for name, weapon in each(Config.Weapons) do
                    Items[name] = {
                        name = name,
                        label = weapon.label,
                        type = "weapon",
                        weight = weapon.weight,
                        ammoType = weapon.ammoType,
                        hasAmmo = weapon.hasAmmo,
                        isMelee = weapon.isMelee == true,
                        rarity = 0,
                        removable = true,
                        usable = true,
                        destroyable = false
                    }
                end

                print("^2[INVENTORY] ^5Succesfully loaded ^4" .. #items .. "^5 items")
            end
        )

        areItemsLoaded = true

        Wait(500)

        MySQL.Async.fetchAll(
            "SELECT * FROM `inventory` where `type` != 'char'",
            {},
            function(storages)
                Storages = {}

                for _, storage in each(storages) do
                    if not Storages[storage.type] then
                        Storages[storage.type] = {}
                    end

                    if not Storages[storage.type][storage.owner] then
                        Storages[storage.type][storage.owner] = {}
                    end

                    local props = json.decode(storage.props)

                    Storages[storage.type][storage.owner].type = storage.type
                    Storages[storage.type][storage.owner].name = storage.owner
                    local storageItems, decodedStorage = {}, json.decode(storage.data)
                    local storageChanged = false

                    for i, storageData in each(decodedStorage) do
                        if storageData and storageData.name and Items[storageData.name] then
                            table.insert(storageItems, storageData)
                        else
                            storageChanged = true
                        end
                    end
                    Storages[storage.type][storage.owner].data = storageItems

                    Storages[storage.type][storage.owner].changed = storageChanged
                    Storages[storage.type][storage.owner].shouldSave = true
                    Storages[storage.type][storage.owner].currentWeight = calculateWeight(Storages[storage.type][storage.owner].data)

                    if props.maxWeight then
                        Storages[storage.type][storage.owner].maxWeight = props.maxWeight
                    else
                        Storages[storage.type][storage.owner].maxWeight = Config.MaxWeight
                    end

                    if props.maxSpace then
                        Storages[storage.type][storage.owner].maxSpace = props.maxSpace
                    else
                        Storages[storage.type][storage.owner].maxSpace = Config.MaxSpace
                    end

                    if props.label then
                        Storages[storage.type][storage.owner].label = props.label
                    else
                        Storages[storage.type][storage.owner].label = ""
                    end
                end

                print("^2[INVENTORY] ^5Succesfully loaded ^4" .. #storages .. "^5 storages")
            end
        )

        Wait(500)

        MySQL.Async.fetchAll(
            "SELECT * FROM drops",
            {},
            function(drops)
                Drops = {}
                for _, drop in each(drops) do
                    local coords = json.decode(drop.coords)
                    drop.coords = vector3(coords.x, coords.y, coords.z)
                    drop.data = json.decode(drop.data)
                    drop.changed = false

                    table.insert(Drops, drop)
                end

                print("^2[INVENTORY] ^5Succesfully loaded ^4" .. #drops .. "^5 drops")
            end
        )
        SetTimeout(300000, syncDropsAndStorages)
    end
)

function syncDropsAndStorages()
    for i, drop in each(Drops) do
        if (tonumber(drop.lastused) <= (os.time() - (60 * 60 * 24))) or (#drop.data == 0) then
            MySQL.Async.execute(
                "DELETE FROM drops WHERE lastused = :lastused",
                {
                    lastused = drop.lastused
                }
            )

            TriggerClientEvent("inventory:removeDrop", -1, drop)
            table.remove(Drops, i)
        elseif drop.changed then
            drop.changed = false
            drop.lastused = os.time()

            MySQL.Async.execute(
                "INSERT INTO drops (coords, lastused, data) VALUES (:coords, :lastused, :data) ON DUPLICATE KEY UPDATE lastused = :lastused, data = :data",
                {
                    coords = '{"x":' ..
                        drop.coords.x .. ',"y":' .. drop.coords.y .. ',"z":' .. drop.coords.z .. "}",
                    data = json.encode(drop.data),
                    lastused = drop.lastused
                }
            )
        end
    end

    for type, storageType in each(Storages) do
        for storageName, storageData in each(Storages[type]) do
            if (storageData.shouldSave == nil or storageData.shouldSave == true) and storageData.changed then
                storageData.changed = false

                local props = {}
                props.maxWeight = storageData.maxWeight
                props.maxSpace = storageData.maxSpace
                props.label = storageData.label

                MySQL.Async.execute(
                    "INSERT INTO `inventory` (`type`, `owner`, `data`, `props`) VALUES (:type, :owner, :data, :props) ON DUPLICATE KEY UPDATE data = :data, props = :props",
                    {
                        type = type,
                        owner = storageName,
                        data = json.encode(storageData.data),
                        props = json.encode(props)
                    }
                )
            end
        end
    end

    SetTimeout(600000, syncDropsAndStorages)
end

AddEventHandler(
    "txAdmin:events:scheduledRestart",
    function(data)
        if data.secondsRemaining == 120 then
            syncDropsAndStorages()
        end
    end
)

RegisterNetEvent("inventory:loadCharInventory")
AddEventHandler(
    "inventory:loadCharInventory",
    function()
        local _source = source
        local identifier = exports.data:getUserVar(_source, "identifier")
        local char = exports.data:getUserVar(_source, "character").id

        local inventoryData = MySQL.Sync.fetchScalar(
            "SELECT data FROM inventory WHERE type = 'char' AND owner = :char LIMIT 1",
            { char = char }
        )

        if inventoryData == nil then
            MySQL.Async.execute(
                "INSERT INTO `inventory`(`type`, `owner`, `data`) VALUES ('char', :char, '{}')",
                { char = char }
            )

            Inventories[identifier] = {}
            Inventories[identifier].data = {}
            Inventories[identifier].char = char
            Inventories[identifier].maxWeight = calculateCharMaxWeight(_source)
            Inventories[identifier].maxSpace = Config.MaxSpace
            Inventories[identifier].currentWeight = 0.0

            addPlayerItem(
                _source,
                "idcard",
                1,
                {
                    id = char,
                    label = exports.data:getCharVar(_source, "firstname") ..
                        " " ..
                        exports.data:getCharVar(_source, "lastname") ..
                        "<br>" .. exports.data:getCharVar(_source, "birth")
                }
            )
            addPlayerItem(_source, "cash", Config.defaultCash, {})
            exports.food:giveItem(_source, "water_raine", 3)
            exports.food:giveItem(_source, "energyfood_egochaser", 2)
            exports.phone:create({ _source, "IFruit" })
            exports.phone:create({ _source, "Basic" })
        else
            local loadedData = json.decode(inventoryData)
            if not loadedData or loadedData == "null" then
                loadedData = {}
            end
            local inventoryToLoad = {}
            for i, item in each(loadedData) do
                if item and item.name and Items[item.name] then
                    table.insert(inventoryToLoad, item)
                end
            end

            Inventories[identifier] = {}
            Inventories[identifier].data = inventoryToLoad
            Inventories[identifier].char = char
            Inventories[identifier].maxWeight = calculateCharMaxWeight(_source)
            Inventories[identifier].maxSpace = Config.MaxSpace
            Inventories[identifier].currentWeight = calculateWeight(Inventories[identifier].data)
        end

        TriggerClientEvent("inventory:loadedCharInventory", _source, Inventories[identifier], Items)
        TriggerClientEvent("inventory:loadDrops", _source, Drops)
    end
)

RegisterNetEvent("inventory:activateWeapon")
AddEventHandler(
    "inventory:activateWeapon",
    function(itemName, slot)
        local _source = source
        local identifier = GetPlayerIdentifier(_source, 0)

        if not checkAndSetTimer(_source, "activateWeapon", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        if Inventories[identifier] ~= nil then
            local itemData = Items[itemName]

            for index, item in each(Inventories[identifier].data) do
                local currentItemData = Items[item.name]
                if currentItemData.type == "weapon" and currentItemData.ammoType == itemData.ammoType then
                    
                    if item.slot == tonumber(slot) then
                        item.data.activeWeapon = not item.data.activeWeapon
                    else
                        item.data.activeWeapon = false
                    end
                end
            end

            setCharInventory(_source, Inventories[identifier])
        end
    end
)

RegisterNetEvent("inventory:activateMobile")
AddEventHandler(
    "inventory:activateMobile",
    function(itemName, slot)
        local _source = source
        local identifier = GetPlayerIdentifier(_source, 0)

        if not checkAndSetTimer(_source, "activateMobile", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        if Inventories[identifier] ~= nil then
            local itemData = Items[itemName]

            for index, item in each(Inventories[identifier].data) do
                local currentItemData = Items[item.name]
                if currentItemData.type == "mobile" then
                    if item.slot == tonumber(slot) then
                        item.data.activeMobile = not item.data.activeMobile
                    else
                        item.data.activeMobile = false
                    end
                end
            end

            setCharInventoryMobile(_source, Inventories[identifier])
        end
    end
)

RegisterNetEvent("inventory:sortItems")
AddEventHandler(
    "inventory:sortItems",
    function(from, to)
        local _source = source
        sortItems(_source, from, to)
    end
)

function sortItems(_source, from, to)
    local identifier = GetPlayerIdentifier(_source, 0)

    if not checkAndSetTimer(_source, "sortItems", 150) then
        TriggerClientEvent("inventory:timerError", _source)
        return
    end

    if Inventories[identifier] ~= nil then
        if isSlotEmpty(Inventories[identifier].data, from) or not isSlotEmpty(Inventories[identifier].data, to) then
            return
        elseif from == to then
            return
        end

        for index, item in each(Inventories[identifier].data) do
            if item.slot == from then
                item.slot = to
                break
            end
        end

        reloadInventory(_source, Inventories[identifier])
    end
end

RegisterNetEvent("inventory:swapItem")
AddEventHandler(
    "inventory:swapItem",
    function(from, to)
        local _source = source
        swapItem(_source, from, to)
    end
)

function swapItem(_source, from, to)
    local identifier = GetPlayerIdentifier(_source, 0)
    local fromDone, toDone = false, false

    if not checkAndSetTimer(_source, "swapItem", 150) then
        TriggerClientEvent("inventory:timerError", _source)
        return
    end

    if Inventories[identifier] ~= nil then
        if isSlotEmpty(Inventories[identifier].data, from) or isSlotEmpty(Inventories[identifier].data, to) then
            return
        elseif from == to then
            return
        end

        for index, item in each(Inventories[identifier].data) do
            if item.slot == from then
                item.slot = to
                fromDone = true
            elseif item.slot == to then
                item.slot = from
                toDone = true
            end

            if toDone and fromDone then
                break
            end
        end

        removeZeroCountItems(identifier)
        reloadInventory(_source, Inventories[identifier])
    end
end

RegisterNetEvent("inventory:joinItem")
AddEventHandler(
    "inventory:joinItem",
    function(from, to, count, data)
        local _source = source
        joinItem(_source, from, to, count, data)
    end
)

function joinItem(_source, from, to, count, data)
    local identifier = GetPlayerIdentifier(_source, 0)

    local fromDone, toDone = false, false
    local itemCount = false

    if not checkAndSetTimer(_source, "joinItem", 150) then
        TriggerClientEvent("inventory:timerError", _source)
        return
    end

    if Inventories[identifier] ~= nil then
        if isSlotEmpty(Inventories[identifier].data, from) or isSlotEmpty(Inventories[identifier].data, to) then
            return
        elseif not isItemOnSlotWithCount(Inventories[identifier].data, from, count) then
            return
        elseif not checkSameItemsOnSlots(Inventories[identifier].data, from, to) then
            return
        elseif from == to then
            return
        end

        for index, item in each(Inventories[identifier].data) do
            if item.slot == from then
                itemCount = item.count
                item.count = 0
                fromDone = true
            elseif item.slot == to then
                item.count = item.count + count
                toDone = true
            end

            if toDone and fromDone then
                break
            end
        end

        removeZeroCountItems(identifier)
        reloadInventory(_source, Inventories[identifier])
    end
end

RegisterNetEvent("inventory:splitItem")
AddEventHandler(
    "inventory:splitItem",
    function(from, to, count)
        local _source = source
        splitItem(_source, from, to, count)
    end
)

function splitItem(_source, from, to, count)
    local identifier = GetPlayerIdentifier(_source, 0)

    if not checkAndSetTimer(_source, "splitItem", 150) then
        TriggerClientEvent("inventory:timerError", _source)
        return
    end

    if Inventories[identifier] ~= nil then
        if isSlotEmpty(Inventories[identifier].data, from) or not isSlotEmpty(Inventories[identifier].data, to) then
            return
        elseif not isItemOnSlotWithCount(Inventories[identifier].data, from, count) then
            return
        elseif from == to then
            return
        end

        for index, item in each(Inventories[identifier].data) do
            if item.slot == from then
                item.count = item.count - tonumber(count)

                local newItem = {}
                newItem.name = item.name
                newItem.count = tonumber(count)
                newItem.data = item.data
                newItem.slot = to

                table.insert(Inventories[identifier].data, newItem)
                break
            end
        end

        removeZeroCountItems(identifier)
        reloadInventory(_source, Inventories[identifier])
    end
end

AddEventHandler(
    "playerDropped",
    function(reason)
        local _source = source
        local identifier = GetPlayerIdentifier(_source, 0)

        if Inventories[identifier] then
            Inventories[identifier].needsSave = true
        end

        Timers[_source] = nil

        if OpenedInventories[_source] then
            OpenedInventories[_source] = nil
        end

        if OpenedStorages[_source] then
            OpenedStorages[_source] = nil
        end

        if Inventories[identifier] then
            while Inventories[identifier] ~= nil and not Inventories[identifier].isSaved do
                Wait(2000)
            end

            Inventories[identifier] = nil
        end
    end
)

function compareNumbers(a, b)
    return a[1] < b[1]
end

function savePlayerInventory(identifier)
    if Inventories[identifier] ~= nil then
        removeZeroCountItems(identifier)

        MySQL.Sync.execute(
            "UPDATE inventory SET data = :data WHERE type = 'char' AND owner = :char",
            {
                data = json.encode(Inventories[identifier].data),
                char = Inventories[identifier].char
            }
        )

        if Inventories[identifier].needsSave then
            Inventories[identifier].isSaved = true
        end
    end
end

function getFreeSlot(slots)
    local found = false

    for i = 1, 10000 do
        found = false

        for _, v in each(slots) do
            if tonumber(v) == tonumber(i) then
                found = true
                break
            end
        end

        if not found then
            return i
        end
    end

    return nil
end

function calculateWeight(inventory)
    local total = 0.0

    for _, item in each(inventory) do
        if item.count == nil or item.name == nil then
            print("DEBUG THIS: calculateWeight", json.encode(inventory), item.name)
        else
            if Items[item.name] ~= nil then
                total = item.count * Items[item.name].weight + total
            end
        end
    end

    return total
end

function removeZeroCountItems(identifier)
    if Config.Debug then
        print("removeZeroCountItems", identifier)
    end

    for index, item in each(Inventories[identifier].data) do
        if item.count == nil then
            print("DEBUG THIS: removeZeroCountItems", identifier)
        end

        if item.count == nil or math.floor(item.count) <= 0 then
            table.remove(Inventories[identifier].data, index)
        end
    end

    Inventories[identifier].currentWeight = calculateWeight(Inventories[identifier].data)
end

function getPlayerCurrentWeight(client)
    local identifier = exports.data:getUserVar(client, "identifier")
    return Inventories[identifier].currentWeight
end

function getPlayerMaxWeight(client)
    local identifier = exports.data:getUserVar(client, "identifier")
    return Inventories[identifier].maxWeight
end

function getPlayerInventory(client)
    local identifier = exports.data:getUserVar(client, "identifier")
    return Inventories[identifier]
end

function forceAddPlayerItem(client, itemName, count, data, slot, dropIfNeeded)
    local addResult = addPlayerItem(client, itemName, count, data, slot, dropIfNeeded)

    if addResult ~= "done" then
        itemDropped(
            { name = itemName, count = count, data = {} },
            count,
            GetEntityCoords(GetPlayerPed(client)),
            exports.instance:getPlayerInstance(client),
            nil
        )
    end

    return addResult
end

function addPlayerItem(client, itemName, count, data, slot, dropIfNeeded)

    local identifier = exports.data:getUserVar(client, "identifier")
    local itemData = Items[itemName]

    if Config.Magazines[itemName] then
        data.isMagazine = true
    end

    if Config.Ammo[itemName] then
        data.isAmmo = true
    end

    local actualCount = count
    if itemData.type == "weapon" or itemData.type == "mobile" or itemData.type == "sim" or data.isMagazine then
        actualCount = 1
    end

    if
    (Inventories[identifier].currentWeight + Items[itemName].weight * actualCount) >
        Inventories[identifier].maxWeight
    then
        return "weightExceeded"
    end

    local found = false
    local usedSlots = {}

    for _, item in each(Inventories[identifier].data) do
        table.insert(usedSlots, item.slot)

        if itemData.type ~= "weapon" and itemData.type ~= "mobile" and itemData.type ~= "sim" and not data.isMagazine then
            if
            not found and itemName == item.name and (not slot or item.slot == slot) and item.data.id == data.id
            then
                if item.data.restaurant == nil then
                    item.count = tonumber(item.count + count)
                    found = true
                    break
                end
            end
        end
    end

    if not found then
        local freeSlot = tonumber(getFreeSlot(usedSlots))
        if freeSlot > Inventories[identifier].maxSpace then
            return "spaceExceeded"
        end

        if slot then
            local isSlotUsed = false

            for _, v in each(usedSlots) do
                if tonumber(v) == tonumber(slot) then
                    isSlotUsed = true
                    break
                end
            end

            if not isSlotUsed then
                freeSlot = slot
            end
        end

        local newItem = {}
        newItem.name = itemName
        newItem.count = tonumber(count)
        newItem.data = data
        newItem.slot = freeSlot

        if data.isAmmo then
            newItem.data.isAmmo = data.isAmmo
            newItem.data.ammoType = Config.Ammo[itemName].ammoType
        end

        if data.isMagazine then
            newItem.data.isMagazine = data.isMagazine
            newItem.data.maxAmmo = Config.Magazines[itemName].ammo
            newItem.data.ammoType = Config.Magazines[itemName].ammoType

            if newItem.data.currentAmmo == nil then
                newItem.data.currentAmmo = newItem.data.maxAmmo
            end

            newItem.data.id = itemName .. "-" .. math.random(1111111, 9999999)
            newItem.data.label = "Počet nábojů: " .. newItem.data.currentAmmo
            newItem.data.amount = newItem.data.currentAmmo
            newItem.count = 1
        end

        if itemData.type == "mobile" then
            newItem.data.activeMobile = false
        end

        if itemData.type == "weapon" then
            newItem.data.ammoType = itemData.ammoType
            newItem.data.hasAmmo = itemData.hasAmmo
            newItem.count = 1
            newItem.data.activeWeapon = false
            if exports.weapons_scripts:hasWeaponFireMods(itemName) ~= "disabled" then
                newItem.data.fireMode = (data.fireMode or 0)
            else
                newItem.data.fireMode = nil
            end
            if data.ammo == nil then
                if Config.Weapons[itemName].isTank then
                    newItem.data.ammo = 5000
                else
                    newItem.data.ammo = 0
                end

                if Config.Weapons[itemName].isThrowable then
                    data.ammo = count
                end
            end
        end

        table.insert(Inventories[identifier].data, newItem)
    end

    Inventories[identifier].currentWeight = calculateWeight(Inventories[identifier].data)

    setCharInventory(client, Inventories[identifier])
    return "done"
end

RegisterNetEvent("inventory:destroyPlayerItem")
AddEventHandler(
    "inventory:destroyPlayerItem",
    function(slot, count)
        local _source = source
        local identifier = exports.data:getUserVar(_source, "identifier")

        for index, item in each(Inventories[identifier].data) do
            if item.slot == slot then
                local itemData = Items[item.name]

                if itemData.destroyable then
                    removePlayerItem(_source, item.name, count, item.data, slot)
                    TriggerClientEvent("inventory:destroySuccess", _source)
                end
                break
            end
        end
    end
)

RegisterNetEvent("inventory:removePlayerItem")
AddEventHandler(
    "inventory:removePlayerItem",
    function(itemName, count, data, slot)
        local _source = source
        removePlayerItem(_source, itemName, count, data, slot)
    end
)

function removePlayerItem(client, itemName, count, data, slot)
    if not count then
        return "noCount"
    end

    if Config.Debug then
        print("removePlayerItem")
        print(client)
        print(itemName)
        print(count)
        print(data)
        print(slot)
    end

    local identifier = exports.data:getUserVar(client, "identifier")

    local enough = false
    local itemsToRemove = {}
    local itsPhone = false

    for index, item in each(Inventories[identifier].data) do
        if item.name == itemName and item.data.id == data.id and (not slot or item.slot == slot) then
            if count > item.count then
                count = count - item.count

                local removeData = {}
                removeData.index = index
                removeData.count = tonumber(item.count)
                table.insert(itemsToRemove, removeData)
                if item.name == "phone" and item.data and item.data.activeMobile then
                    itsPhone = item
                end
            else
                if item.name == "phone" and item.data and item.data.activeMobile then
                    itsPhone = item
                end
                enough = true

                local removeData = {}
                removeData.index = index
                removeData.count = tonumber(count)
                table.insert(itemsToRemove, removeData)
                break
            end
        end
    end

    if not enough then
        return "notEnoughItems"
    end

    for i = 1, #itemsToRemove do
        Inventories[identifier].data[itemsToRemove[i].index].count = tonumber(Inventories[identifier].data[itemsToRemove[i].index].count - itemsToRemove[i].count)
    end

    removeZeroCountItems(identifier)
    Inventories[identifier].currentWeight = calculateWeight(Inventories[identifier].data)

    setCharInventory(client, Inventories[identifier], itsPhone)
    return "done"
end

RegisterNetEvent("inventory:removeMultiplePlayerItems")
AddEventHandler(
    "inventory:removeMultiplePlayerItems",
    function(items)
        local _source = source
        removeMultiplePlayerItems(_source, items)
    end
)

function removeMultiplePlayerItems(client, items)
    if Config.Debug then
        print("removeMultiplePlayerItem")
        print(client)
    end

    local identifier = exports.data:getUserVar(client, "identifier")
    local enough = false
    local itemsToRemove = {}

    for itemName, itemData in each(items) do
        for index, item in each(Inventories[identifier].data) do
            if
            item.name == itemName and item.data.id == itemData.data.id and
                (not itemData.slot or item.slot == itemData.slot)
            then
                if itemData.count > item.count then
                    itemData.count = itemData.count - item.count

                    local removeData = {}
                    removeData.index = index
                    removeData.count = tonumber(item.count)
                    table.insert(itemsToRemove, removeData)
                else
                    enough = true

                    local removeData = {}
                    removeData.index = index
                    removeData.count = tonumber(itemData.count)
                    table.insert(itemsToRemove, removeData)
                    break
                end
            end
        end
    end

    if not enough then
        return "notEnoughItems"
    end

    for i = 1, #itemsToRemove do
        Inventories[identifier].data[itemsToRemove[i].index].count = tonumber(Inventories[identifier].data[itemsToRemove[i].index].count - itemsToRemove[i].count)
    end

    removeZeroCountItems(identifier)
    Inventories[identifier].currentWeight = calculateWeight(Inventories[identifier].data)

    setCharInventory(client, Inventories[identifier])
    return "done"
end

function checkPlayerItem(client, itemName, count, data)
    local identifier = exports.data:getUserVar(client, "identifier")
    local usedSlots = {}
    local totalCount = 0

    for _, item in each(Inventories[identifier].data) do
        if item.name == itemName and item.data.id == data.id then
            totalCount = item.count + totalCount
            if totalCount >= count then
                return true
            end
        end
    end

    return false
end

function getPlayerItemCount(client, itemName, data)
    local identifier = exports.data:getUserVar(client, "identifier")
    local totalCount = 0

    for _, item in each(Inventories[identifier].data) do
        if item.name == itemName and item.data.id == data.id then
            totalCount = item.count + totalCount
        end
    end

    return totalCount
end

function getItem(itemName)
    return Items[itemName]
end

function getItems()
    return Items
end


RegisterNetEvent("inventory:clearPlayerInventory")
AddEventHandler(
    "inventory:clearPlayerInventory",
    function()
        local _source = source
        clearPlayerInventory(_source)
    end
)

function clearPlayerInventory(client)
    local identifier = exports.data:getUserVar(client, "identifier")

    Inventories[identifier].data = {}
    Inventories[identifier].currentWeight = 0.0

    setCharInventory(client, Inventories[identifier])
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end

    return copy
end

function findItemById(data, id)
    for _, item in each(data) do
        if item.data.id == id then
            return item
        end
    end

    return nil
end

function findItemBySlot(data, slot)
    for _, item in each(data) do
        if item.slot == slot then
            return item
        end
    end

    return nil
end

function updateItemData(client, id, data)
    local identifier = exports.data:getUserVar(client, "identifier")

    for _, item in each(Inventories[identifier].data) do
        if item.data and item.data.id == id then
            for k, v in each(data) do
                item.data[k] = v
            end
            break
        end
    end
    removeZeroCountItems(identifier)
    setCharInventoryWithoutReload(client, Inventories[identifier])
end

function updateItemDataBySlot(client, slot, data)
    local identifier = exports.data:getUserVar(client, "identifier")

    for _, item in each(Inventories[identifier].data) do
        if item.data and item.slot == slot then
            for k, v in each(data) do
                item.data[k] = v
            end
            break
        end
    end

    setCharInventoryWithoutReload(client, Inventories[identifier])
end

function isSlotEmpty(data, slot)
    for _, item in each(data) do
        if item.slot == slot then
            return false
        end
    end

    return true
end

function isItemOnSlotWithCount(data, slot, count)
    for _, item in each(data) do
        if item.slot == slot then
            if item.count >= count then
                return true
            else
                return false
            end
        end
    end

    return false
end

function checkSameItemsOnSlots(data, slot1, slot2)
    local item1, item2 = nil, nil

    for _, item in each(data) do
        if item.slot == slot1 then
            item1 = item
        elseif item.slot == slot2 then
            item2 = item
        end
    end

    if item1 == nil or item2 == nil then
        return false
    end

    if item1.name == item2.name and item1.id == item2.id then
        return true
    end

    return false
end

function checkAndSetTimer(client, timer, time)
    if Timers[client] == nil then
        Timers[client] = {}
    end

    if Timers[client][timer] ~= nil then
        return false
    else
        Timers[client][timer] = tonumber(time)
    end

    return true
end

Citizen.CreateThread(
    function()
        while true do
            for client, timers in pairs(Timers) do
                for timer, value in pairs(timers) do
                    Timers[client][timer] = value - 50

                    if Timers[client][timer] <= 0 then
                        Timers[client][timer] = nil
                    end
                end
            end

            Citizen.Wait(250)
        end
    end
)

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

RegisterNetEvent("inventory:setOpenedInventory")
AddEventHandler(
    "inventory:setOpenedInventory",
    function(openedInventory)
        local client = source
        OpenedInventories[client] = openedInventory
    end
)

function setCharInventory(client, inventoryData, itsPhone)
    TriggerClientEvent("inventory:setCharInventory", client, client, inventoryData, itsPhone)

    for openedClient, openedInventory in pairs(OpenedInventories) do
        if openedInventory == client and openedClient ~= client then
            TriggerClientEvent("inventory:setCharInventory", openedClient, client, inventoryData, itsPhone)
        end
    end
end

function setCharInventoryMobile(client, inventoryData)
    TriggerClientEvent("inventory:setCharInventoryMobile", client, client, inventoryData)

    for openedClient, openedInventory in pairs(OpenedInventories) do
        if openedInventory == client and openedClient ~= client then
            TriggerClientEvent("inventory:setCharInventoryMobile", openedClient, client, inventoryData)
        end
    end
end

function setCharInventoryWithoutReload(client, inventoryData)
    TriggerClientEvent("inventory:setCharInventoryWithoutReload", client, client, inventoryData)

    for openedClient, openedInventory in pairs(OpenedInventories) do
        if openedInventory == client and openedClient ~= client then
            TriggerClientEvent("inventory:setCharInventoryWithoutReload", openedClient, client, inventoryData)
        end
    end
end

function reloadInventory(client, inventoryData)
    TriggerClientEvent("inventory:reloadInventory", client, client, inventoryData)

    for openedClient, openedInventory in pairs(OpenedInventories) do
        if openedInventory == client and openedClient ~= client then
            TriggerClientEvent("inventory:reloadInventory", openedClient, client, inventoryData)
        end
    end
end

function getAreItemsLoaded()
    return areItemsLoaded
end

function calculateCharMaxWeight(client)
    local skills = exports.data:getCharVar(client, "skills")
    local strength = 0

    if skills and skills.strength then
        strength = skills.strength
    end

    return Config.MaxWeight + 10 * strength / 100
end

AddEventHandler(
    "skills:updated",
    function(client, skills)
        local identifier = GetPlayerIdentifier(client, 0)
        local strength = 0

        if skills and skills.strength then
            strength = skills.strength
        end
        if identifier and Inventories[identifier] then
            Inventories[identifier].maxWeight = Config.MaxWeight + 10 * strength / 100
        end
    end
)
