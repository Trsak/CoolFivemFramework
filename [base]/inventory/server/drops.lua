RegisterNetEvent("inventory:dropItemToGround")
AddEventHandler(
    "inventory:dropItemToGround",
    function(from, count, position, instance, slot)
        if Config.Debug then
            print("dropItemToGround", from, count, position, slot)
        end

        local _source = source
        local identifier = GetPlayerIdentifier(_source, 0)

        if not checkAndSetTimer(_source, "dropItemToGround", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        if not count then
            return
        end

        if Inventories[identifier] ~= nil then
            if isSlotEmpty(Inventories[identifier].data, from) then
                return
            elseif not isItemOnSlotWithCount(Inventories[identifier].data, from, count) then
                return
            end

            for index, item in each(Inventories[identifier].data) do
                if item.slot == from then
                    item.count = item.count - count

                    if item.data.activeWeapon then
                        item.data.activeWeapon = false
                    end

                    if item.data.activeMobile then
                        item.data.activeMobile = false
                    end

                    itemDropped(item, count, position, instance, slot)
                    exports.logs:sendToDiscord(
                        {
                            channel = "drops",
                            title = "Drop",
                            description = "Hodil na zem " .. " - " .. count .. "x " .. getItem(item.name).label,
                            color = "34749"
                        },
                        _source
                    )
                    break
                end
            end

            removeZeroCountItems(identifier)
            reloadInventory(_source, Inventories[identifier])
        end
    end
)

function dropAddItem(inventory, newItem, slot)
    if Config.Debug then
        print("dropAddItem", inventory, newItem, slot)
    end

    if Config.Magazines[newItem.name] ~= nil then
        newItem.data.isMagazine = true
    end

    if Config.Ammo[newItem.name] ~= nil then
        newItem.data.isAmmo = true
    end

    local itemData = Items[newItem.name]

    local actualCount = newItem.count
    if itemData.type == "weapon" or itemData.type == "mobile" or itemData.type == "sim" or newItem.data.isMagazine then
        actualCount = 1
    end

    local found = false
    local usedSlots = {}

    for _, item in each(inventory) do
        table.insert(usedSlots, item.slot)

        if
        itemData.type ~= "weapon" and itemData.type ~= "mobile" and itemData.type ~= "sim" and
            not newItem.data.isMagazine
        then
            if
            not found and (not slot or item.slot == slot) and newItem.name == item.name and
                (newItem.data.id == nil or item.data.id == newItem.data.id)
            then
                item.count = tonumber(item.count + actualCount)
                found = true
                break
            end
        end
    end

    if not found then
        local freeSlot = tonumber(getFreeSlot(usedSlots))
        newItem.slot = freeSlot

        if slot then
            local isSlotUsed = false

            for _, v in each(usedSlots) do
                if tonumber(v) == tonumber(slot) then
                    isSlotUsed = true
                    break
                end
            end

            if not isSlotUsed then
                newItem.slot = slot
            end
        end

        table.insert(inventory, newItem)
    end
end

function itemDropped(item, count, position, instance, slot)
    if Config.Debug then
        print("itemDropped", item, count, position, slot)
    end
    local newItem = deepcopy(item)
    newItem.count = count

    local found = false
    for _, drop in each(Drops) do
        if drop.instance == instance then
            local dist = #(position - drop.coords)
            if dist <= 3.0 then
                found = true
                dropAddItem(drop.data, newItem, slot)
                drop.changed = true
                TriggerClientEvent("inventory:changedDrop", -1, drop)
                break
            end
        end
    end

    if not found then
        local drop = {}
        drop.coords = position
        drop.lastused = os.time()
        drop.data = {}
        drop.instance = instance
        drop.changed = true

        newItem.slot = 1

        table.insert(drop.data, newItem)
        table.insert(Drops, drop)

        TriggerClientEvent("inventory:newDrop", -1, drop)
    end
end

function dropRemoveZeroCountItems(drop)
    for index, item in each(drop.data) do
        if item.count <= 0 then
            table.remove(drop.data, index)
        end
    end
end

RegisterNetEvent("inventory:takeFromDrop")
AddEventHandler(
    "inventory:takeFromDrop",
    function(dropItem, from, slot, count)
        if not count then
            return
        end

        local _source = source
        local foundDrop = nil
        local successDrop = false

        if not checkAndSetTimer(_source, "takeFromDrop", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        for _, drop in each(Drops) do
            if drop.coords == dropItem.coords then
                foundDrop = drop
            end
        end

        if foundDrop then
            if isSlotEmpty(foundDrop.data, from) then
                return
            elseif not isItemOnSlotWithCount(foundDrop.data, from, count) then
                return
            end

            for index, item in each(foundDrop.data) do
                if item.slot == from then
                    if count == nil then
                        print("DEBUG THIS: inventory:takeFromDrop", _source, from, slot, count)
                    end

                    if count ~= nil and item.count >= count then
                        item.count = item.count - count

                        local result = addPlayerItem(_source, item.name, count, item.data, slot)
                        if result == "done" then
                            successDrop = true
                            exports.logs:sendToDiscord(
                                {
                                    channel = "drops",
                                    title = "Drop",
                                    description = "Vzal ze země " .. " - " .. count .. "x " .. getItem(item.name).label,
                                    color = "34749"
                                },
                                _source
                            )
                        else
                            TriggerClientEvent("inventory:error", _source, result)
                            item.count = item.count + count
                        end
                    end

                    break
                end
            end

            if successDrop then
                dropRemoveZeroCountItems(foundDrop)
                foundDrop.changed = true
                TriggerClientEvent("inventory:changedDrop", -1, foundDrop)
            end
        end
    end
)

RegisterNetEvent("inventory:sortDropItems")
AddEventHandler(
    "inventory:sortDropItems",
    function(dropItem, from, to)
        if not checkAndSetTimer(source, "takeFromDrop", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local foundDrop = nil

        for _, drop in each(Drops) do
            if drop.coords == dropItem.coords then
                foundDrop = drop
            end
        end

        if foundDrop then
            if isSlotEmpty(foundDrop.data, from) or not isSlotEmpty(foundDrop.data, to) then
                return
            elseif from == to then
                return
            end

            for index, item in each(foundDrop.data) do
                if item.slot == from then
                    item.slot = to
                    break
                end
            end

            dropRemoveZeroCountItems(foundDrop)
            foundDrop.changed = true
            TriggerClientEvent("inventory:changedDrop", -1, foundDrop)
        end
    end
)

RegisterNetEvent("inventory:splitDropItem")
AddEventHandler(
    "inventory:splitDropItem",
    function(dropItem, from, to, count)
        if not checkAndSetTimer(source, "takeFromDrop", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local foundDrop = nil

        for _, drop in each(Drops) do
            if drop.coords == dropItem.coords then
                foundDrop = drop
            end
        end

        if foundDrop then
            if isSlotEmpty(foundDrop.data, from) or not isSlotEmpty(foundDrop.data, to) then
                return
            elseif not isItemOnSlotWithCount(foundDrop.data, from, count) then
                return
            elseif from == to then
                return
            end

            for index, item in each(foundDrop.data) do
                if item.slot == from then
                    item.count = item.count - tonumber(count)

                    local newItem = {}
                    newItem.name = item.name
                    newItem.count = tonumber(count)
                    newItem.data = item.data
                    newItem.slot = to

                    table.insert(foundDrop.data, newItem)
                    break
                end
            end

            dropRemoveZeroCountItems(foundDrop)
            foundDrop.changed = true
            TriggerClientEvent("inventory:changedDrop", -1, foundDrop)
        end
    end
)

RegisterNetEvent("inventory:joinDropItem")
AddEventHandler(
    "inventory:joinDropItem",
    function(dropItem, from, to, count, data)
        if not checkAndSetTimer(source, "takeFromDrop", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local foundDrop = nil

        for _, drop in each(Drops) do
            if drop.coords == dropItem.coords then
                foundDrop = drop
            end
        end

        local fromDone, toDone = false, false
        local itemCount = false

        if foundDrop then
            if isSlotEmpty(foundDrop.data, from) or isSlotEmpty(foundDrop.data, to) then
                return
            elseif not isItemOnSlotWithCount(foundDrop.data, from, count) then
                return
            elseif not checkSameItemsOnSlots(foundDrop.data, from, to) then
                return
            elseif from == to then
                return
            end

            for index, item in each(foundDrop.data) do
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

            dropRemoveZeroCountItems(foundDrop)
            foundDrop.changed = true
            TriggerClientEvent("inventory:changedDrop", -1, foundDrop)
        end
    end
)

RegisterNetEvent("inventory:swapDropItem")
AddEventHandler(
    "inventory:swapDropItem",
    function(dropItem, from, to)
        if not checkAndSetTimer(source, "takeFromDrop", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local foundDrop = nil

        for _, drop in each(Drops) do
            if drop.coords == dropItem.coords then
                foundDrop = drop
            end
        end

        local fromDone, toDone = false, false
        if foundDrop then
            if isSlotEmpty(foundDrop.data, from) or isSlotEmpty(foundDrop.data, to) then
                return
            elseif from == to then
                return
            end

            for index, item in each(foundDrop.data) do
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

            dropRemoveZeroCountItems(foundDrop)
            foundDrop.changed = true
            TriggerClientEvent("inventory:changedDrop", -1, foundDrop)
        end
    end
)
