RegisterNetEvent("inventory:openStorage")
AddEventHandler(
    "inventory:openStorage",
    function(type, name, data)
        local _source = source

        if not checkAndSetTimer(_source, "openStorage", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        if type == nil or name == nil then
            return
        end

        openStorage(_source, type, name, data)
    end
)

RegisterNetEvent("inventory:sortStorageItems")
AddEventHandler(
    "inventory:sortStorageItems",
    function(storageData, from, to)
        if not checkAndSetTimer(source, "sortStorageItems", 150) then
            TriggerClientEvent("inventory:timerError", source)
            return
        end

        local storage = loadStorage(storageData.type, storageData.name, {})

        if isSlotEmpty(storage.data, from) or not isSlotEmpty(storage.data, to) then
            return
        elseif from == to then
            return
        end

        for index, item in each(storage.data) do
            if item.slot == from then
                item.slot = to
                storage.changed = true
                break
            end
        end

        storageChanged(storage.type, storage.name, Storages[storage.type][storage.name])
    end
)

RegisterNetEvent("inventory:swapStorageItem")
AddEventHandler(
    "inventory:swapStorageItem",
    function(storageData, from, to, count)
        if not checkAndSetTimer(source, "swapStorageItem", 150) then
            TriggerClientEvent("inventory:timerError", source)
            return
        end

        local storage = loadStorage(storageData.type, storageData.name, {})

        local fromDone, toDone = false, false

        if isSlotEmpty(storage.data, from) or isSlotEmpty(storage.data, to) then
            return
        elseif from == to then
            return
        end

        for index, item in each(storage.data) do
            if item.slot == from then
                item.slot = to
                fromDone = true
            elseif item.slot == to then
                item.slot = from
                toDone = true
            end

            if toDone and fromDone then
                storage.changed = true
                break
            end
        end

        removeZeroCountStorageItems(storage)

        storageChanged(storage.type, storage.name, Storages[storage.type][storage.name])
    end
)

RegisterNetEvent("inventory:joinStorageItem")
AddEventHandler(
    "inventory:joinStorageItem",
    function(storageData, from, to, count, data)
        if not checkAndSetTimer(source, "joinStorageItem", 150) then
            TriggerClientEvent("inventory:timerError", source)
            return
        end

        local storage = loadStorage(storageData.type, storageData.name, {})

        local fromDone, toDone = false, false
        local itemCount = false

        if isSlotEmpty(storage.data, from) or isSlotEmpty(storage.data, to) then
            return
        elseif not isItemOnSlotWithCount(storage.data, from, count) then
            return
        elseif not checkSameItemsOnSlots(storage.data, from, to) then
            return
        elseif from == to then
            return
        end

        for index, item in each(storage.data) do
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

        removeZeroCountStorageItems(storage)

        storageChanged(storage.type, storage.name, Storages[storage.type][storage.name])
    end
)

RegisterNetEvent("inventory:takeFromStorage")
AddEventHandler(
    "inventory:takeFromStorage",
    function(storageData, from, to, count)
        local _source = source

        if not count then
            return
        end

        if not checkAndSetTimer(_source, "joinStorageItem", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local storage = loadStorage(storageData.type, storageData.name, {})

        local identifier = GetPlayerIdentifier(_source, 0)

        if Inventories[identifier] ~= nil then
            for index, item in each(storage.data) do
                if item.slot == from then
                    local removeResult = removeItemFromStorage(storage, item.name, count, item.data, item.slot)

                    if removeResult == "done" then
                        local addResult = addPlayerItem(_source, item.name, count, item.data, to)

                        if addResult ~= "done" then
                            TriggerClientEvent("inventory:error", _source, addResult)
                            addItemToStorage(storage, item.name, count, item.data, item.slot)
                        else
                            logStorageActionToDiscord("take", storage.type, storage.name, count, item.name, _source)
                        end
                    end
                    break
                end
            end
        end
    end
)

RegisterNetEvent("inventory:splitStorageItems")
AddEventHandler(
    "inventory:splitStorageItems",
    function(storageData, from, to, count)
        if not checkAndSetTimer(source, "splitStorageItems", 150) then
            TriggerClientEvent("inventory:timerError", source)
            return
        end

        local storage = loadStorage(storageData.type, storageData.name, {})

        if isSlotEmpty(storage.data, from) or not isSlotEmpty(storage.data, to) then
            return
        elseif not isItemOnSlotWithCount(storage.data, from, count) then
            return
        elseif from == to then
            return
        end

        for index, item in each(storage.data) do
            if item.slot == from then
                item.count = item.count - tonumber(count)

                local newItem = {}
                newItem.name = item.name
                newItem.count = tonumber(count)
                newItem.data = item.data
                newItem.slot = to

                table.insert(storage.data, newItem)
                storage.changed = true
                break
            end
        end

        removeZeroCountStorageItems(storage)

        storageChanged(storage.type, storage.name, Storages[storage.type][storage.name])
    end
)

RegisterNetEvent("inventory:putIntoStorage")
AddEventHandler(
    "inventory:putIntoStorage",
    function(storageData, from, to, count)
        local _source = source

        if not checkAndSetTimer(_source, "putIntoStorage", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local storage = loadStorage(storageData.type, storageData.name, {})
        local identifier = GetPlayerIdentifier(_source, 0)

        if Inventories[identifier] ~= nil then
            local item = findItemBySlot(Inventories[identifier].data, from)

            if item then
                if item.name == "evidencebag" and storageData.type == "evidencebag" then
                    TriggerClientEvent("inventory:storageError", _source, "notGoodItem")
                    return
                end

                local removeResult = removePlayerItem(_source, item.name, count, item.data, item.slot)

                if removeResult == "done" then
                    local addresult = addItemToStorage(storage, item.name, count, item.data, to)

                    if addresult ~= "done" then
                        addPlayerItem(_source, item.name, count, item.data, item.slot)
                        TriggerClientEvent("inventory:storageError", _source, addresult)
                    else
                        logStorageActionToDiscord("put", storage.type, storage.name, count, item.name, _source)
                    end
                end
            end
        end
    end
)

function addItemToStorage(storage, itemName, count, data, slot)
    local itemData = Items[itemName]

    if Config.Magazines[itemName] ~= nil then
        data.isMagazine = true
    end

    if Config.Ammo[itemName] ~= nil then
        data.isAmmo = true
    end

    local actualCount = count
    if itemData.type == "weapon" or itemData.type == "mobile" or itemData.type == "sim" or data.isMagazine then
        actualCount = 1
    end

    if (storage.currentWeight + Items[itemName].weight * actualCount) > storage.maxWeight then
        return "weightExceeded"
    end

    local found = false
    local usedSlots = {}

    for _, item in each(storage.data) do
        table.insert(usedSlots, item.slot)

        if itemData.type ~= "weapon" and itemData.type ~= "mobile" and itemData.type ~= "sim" and not data.isMagazine then
            if
            not found and itemName == item.name and (not slot or item.slot == slot) and
                (data.id == nil or item.data.id == data.id)
            then
                item.count = tonumber(item.count + count)
                found = true
                break
            end
        end
    end

    if not found then
        local freeSlot = tonumber(getFreeSlot(usedSlots))
        if freeSlot > storage.maxSpace then
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

            if count >= newItem.data.maxAmmo then
                newItem.data.currentAmmo = newItem.data.maxAmmo
            else
                if data.currentAmmo == nil then
                    newItem.data.currentAmmo = 0
                end
            end

            newItem.data.label = "Počet nábojů: " .. newItem.data.currentAmmo

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

        table.insert(Storages[storage.type][storage.name].data, newItem)
    end

    Storages[storage.type][storage.name].currentWeight = calculateWeight(storage.data)
    Storages[storage.type][storage.name].changed = true

    storageChanged(storage.type, storage.name, Storages[storage.type][storage.name])
    return "done"
end

function removeItemFromStorage(storage, itemName, count, data, slot)
    local enough = false
    local itemsToRemove = {}

    for index, item in each(storage.data) do
        if item.name == itemName and (data.id == nil or item.data.id == data.id) and (not slot or item.slot == slot) then
            if count == nil then
                print("DEBUG THIS: removeItemFromStorage", storage, itemName, count, data, slot)
            end

            if count ~= nil and count > item.count then
                count = count - item.count

                local removeData = {}
                removeData.index = index
                removeData.count = tonumber(item.count)
                table.insert(itemsToRemove, removeData)
            elseif count ~= nil then
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
        storage.data[itemsToRemove[i].index].count = tonumber(storage.data[itemsToRemove[i].index].count - itemsToRemove[i].count)
    end

    removeZeroCountStorageItems(storage)
    Storages[storage.type][storage.name].currentWeight = calculateWeight(storage.data)
    Storages[storage.type][storage.name].changed = true

    storageChanged(storage.type, storage.name, Storages[storage.type][storage.name])
    return "done"
end

function openStorage(client, type, name, data)
    if type == "trunk" then
        local vehicle = exports.base_vehicles:getVehicle(name)
        if vehicle then
            if not exports.base_vehicles:isStateJob(vehicle.owner, client) then
                TriggerClientEvent("inventory:trunkDenied", client)
                return
            end
            data.shouldSave = true
        else
            data.shouldSave = false
        end
    elseif type == "glovebox" then
        data.shouldSave = exports.base_vehicles:doesVehicleExist(name)
    end

    local storage = loadStorage(type, name, data)
    TriggerClientEvent("inventory:openedStorage", client, type, name, storage)
end

function loadStorage(type, name, data)
    if type == nil then
        return
    end

    if not Storages[type] or not Storages[type][name] then
        if not Storages[type] then
            Storages[type] = {}
        end

        if not type or not name then
            print("STORAGE ERROR:", type, name)
            return
        end

        if not Storages[type][name] then
            Storages[type][name] = {}
        end

        Storages[type][name].data = {}
        Storages[type][name].currentWeight = 0.0
        Storages[type][name].type = type
        Storages[type][name].name = name

        if data.maxWeight then
            Storages[type][name].maxWeight = data.maxWeight
        else
            Storages[type][name].maxWeight = Config.MaxWeight
        end

        if data.maxSpace then
            Storages[type][name].maxSpace = data.maxSpace
        else
            Storages[type][name].maxSpace = Config.MaxSpace
        end

        if data.shouldSave then
            Storages[type][name].shouldSave = data.shouldSave
        else
            Storages[type][name].shouldSave = true
        end

        if data.label then
            Storages[type][name].label = data.label
        else
            Storages[type][name].label = ""
        end

        Storages[type][name].changed = true
    else
        if data.maxWeight and Storages[type][name].maxWeight ~= data.maxWeight then
            Storages[type][name].maxWeight = data.maxWeight
            Storages[type][name].changed = true
        end

        if data.maxSpace and Storages[type][name].maxSpace ~= data.maxSpace then
            Storages[type][name].maxSpace = data.maxSpace
            Storages[type][name].changed = true
        end

        if data.label and Storages[type][name].label ~= data.label then
            Storages[type][name].label = data.label
            Storages[type][name].changed = true
        end

        if data.shouldSave and Storages[type][name].shouldSave ~= data.shouldSave then
            Storages[type][name].shouldSave = data.shouldSave
            Storages[type][name].changed = true
        end
    end

    return Storages[type][name]
end

function removeZeroCountStorageItems(storage)
    for index, item in each(storage.data) do
        if item.count <= 0 then
            table.remove(storage.data, index)
        end
    end

    storage.currentWeight = calculateWeight(storage.data)
end

RegisterNetEvent("inventory:setOpenedStorage")
AddEventHandler(
    "inventory:setOpenedStorage",
    function(openedStorageType, openedStorageName)
        local client = source
        OpenedStorages[client] = {
            type = openedStorageType,
            name = openedStorageName
        }
    end
)

function storageChanged(type, name, storageData)
    for openedClient, openedStorage in pairs(OpenedStorages) do
        if openedStorage.type == type and openedStorage.name == name then
            if openedStorage.type == "evidencebag" then
                updateItemData(
                    openedClient,
                    openedStorage.name,
                    {
                        items = #Storages[type][name].data,
                        weight = Storages[type][name].currentWeight
                    }
                )
            end

            TriggerClientEvent("inventory:storageChanged", openedClient, storageData)
        end
    end
end

function changeVehicleTrunkToNewPlate(oldPlate, newPlate)
    if Storages["trunk"][oldPlate] then
        Storages["trunk"][newPlate] = Storages["trunk"][oldPlate]
        Storages["trunk"][newPlate].changed = true

        MySQL.Async.execute(
            "DELETE FROM inventory WHERE `type` = 'trunk' and owner = @owner",
            {
                ["@owner"] = oldPlate
            }
        )
    end
end

function logStorageActionToDiscord(action, storageType, storageName, itemCount, itemName, client)
    local text, title = "Vložil do přihrádky vozidla s SPZ ", "Přihrádka vozidla"
    if action == "put" then
        if storageType == "trunk" then
            text, title = "Vložil do kufru vozidla s SPZ ", "Kufr vozidla"
        elseif storageType == "fridge" then
            text, title = "Vložil do lednice ", "Lednice"
        elseif storageType == "storage" then
            text, title = "Vložil do skladu ", "Sklad"
        elseif storageType == "evidencebag" then
            text, title = "Vložil do sáčku s důkazy ", "Sáček s důkazy"
        elseif storageType == "personalCloset" then
            text, title = "Vložil do osobní skříňky ", "Osobní skříňka"
        end
    elseif action == "take" then
        text, title = "Vzal z přihrádky vozidla s SPZ ", "Přihrádka vozidla"
        if storageType == "trunk" then
            text, title = "Vzal z kufru vozidla s SPZ ", "Kufr vozidla"
        elseif storageType == "fridge" then
            text, title = "Vzal z lednice ", "Lednice"
        elseif storageType == "storage" then
            text, title = "Vzal ze skladu ", "Sklad"
        elseif storageType == "evidencebag" then
            text, title = "Vzal ze sáčku s důkazy ", "Sáček s důkazy"
        elseif storageType == "personalCloset" then
            text, title = "Vložil do osobní skříňky ", "Osobní skříňka"
        end
    end
    local itemLabel = getItem(itemName).label
    exports.logs:sendToDiscord(
        {
            channel = "storages",
            title = title,
            description = text .. storageName .. " -> " .. itemCount .. "x " .. itemLabel,
            color = "34749"
        },
        client
    )
    if not exports.control:isDev() and string.find(storageName, "-") then
        if storageType ~= "storage" then
            return
        end
        if string.starts(storageName, "house_") then
            return
        end
        if string.starts(storageName, "property-") then
            return
        end
        if exports.base_vehicles:getVehicle(storageName) then
            return
        end
        local storageNameInfoSplit = {}

        for part in storageName:gmatch("([^-]+)") do
            table.insert(storageNameInfoSplit, part)
        end

        local job = storageNameInfoSplit[1]
        if not ServerConfig.Webhooks[job] or not exports.base_jobs:getJob(job) then
            return
        end
        local storageNumber = storageNameInfoSplit[2]
        if not tonumber(storageNumber) then
            storageNumber = tonumber(storageNameInfoSplit[3])
        end
        local charName = exports.data:getCharNameById(exports.data:getCharVar(client, "id"))
        PerformHttpRequest(
            ServerConfig.Webhooks[job],
            function(err, text, headers)
            end,
            "POST",
            json.encode(
                {
                    embeds = {
                        {
                            color = 34749,
                            title = "Sklad",
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                            description = "Zaměstanec: " .. charName .. "\n" .. text .. "č. " .. storageNumber .. " " .. itemCount .. "x " .. itemLabel,
                            footer = {
                                text = exports.base_jobs:getJobVar(job, "label"),
                                icon_url = "https://dunb17ur4ymx4.cloudfront.net/webstore/logos/d0083345917107dd3df76a3a0872c4cd6aa22ef6.png"
                            }
                        }
                    }
                }
            ),
            { ["Content-Type"] = "application/json" }
        )
    end
end
