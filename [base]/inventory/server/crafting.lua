local crafting = {}

RegisterNetEvent("inventory:craftItem")
AddEventHandler("inventory:craftItem", function(id, targetAmount)
    local craftingData = CRAFTING_RECIPES[id]
    local client = source

    if not craftingData then
        return
    end
    local item = craftingData.item

    if not crafting[tostring(client)] then
        crafting[tostring(client)] = {
            remain = targetAmount,
            crafted = 0
        }
    end

    local canCraft, ingredientsToUpdateData = checkIngredients(client, craftingData)

    if canCraft then
        canCraft = checkRequirements(client, craftingData)
    end

    if canCraft then
        for ingredient, ingredientData in pairs(craftingData.ingredients) do
            local itemData = ingredientData.data
            if ingredientsToUpdateData[ingredient] then
                itemData = ingredientsToUpdateData[ingredient].data
            end

            local removeItem = removePlayerItem(client, ingredient, ingredientData.count, itemData or {})
            if removeItem ~= "done" then
                logCrafting(client, "missing", item)
                return
            elseif ingredientsToUpdateData[ingredient] then
                local item = ingredientsToUpdateData[ingredient]
                if not item.remove then
                    forceAddPlayerItem(client, ingredient, ingredientData.count, {
                        id = item.data.id - 1,
                        amount = item.data.id - 1,
                        label = "Zbývá: " .. (item.data.id - 1)
                    })
                end
            end
        end

        local countToAdd = getAddCount(craftingData.count)
        forceAddPlayerItem(client, item, countToAdd, craftingData.data or {})
        if craftingData.additions then
            for addition, additionData in pairs(craftingData.additions) do
                forceAddPlayerItem(client, addition, additionData.count, additionData.data or {})
            end
        end

        local client = tostring(client)
        if crafting[client] then
            crafting[client].remain = crafting[client].remain - 1
            crafting[client].crafted = crafting[client].crafted + countToAdd
            if crafting[client].remain <= 0 then
                logCrafting(client, "success", item)
            end
        end
    else
        logCrafting(client, "missing", item)
    end
end)

AddEventHandler("playerDropped", function(reason)
    local client = tostring(source)
    if crafting[client] then
        crafting[client] = nil
    end
end)

function getAddCount(count)
    if type(count) == "number" then
        return count
    else
        return math.random(count[1], count[2])
    end
end

function logCrafting(client, state, item)
    local client = tostring(client)
    if state == "success" then
        TriggerClientEvent("notify:display", tonumber(client), {
            type = "success",
            title = "Crafting",
            text = "Vše úspěšně vyrobeno!",
            icon = "fas fa-hammer",
            length = 3000
        })
    elseif state == "missing" then
        TriggerClientEvent("notify:display", tonumber(client), {
            type = "warning",
            title = "Crafting",
            text = "Na výrobu něco chybí!",
            icon = "fas fa-hammer",
            length = 3000
        })
    end
    if crafting[client].crafted > 0 then
        exports.logs:sendToDiscord({
            channel = "crafting",
            title = "Crafting",
            description = "Vycraftil/a " .. crafting[client].crafted .. "x " .. getItem(item).label,
            color = "5735736"
        }, tonumber(client))
    end
    crafting[client] = nil
end

RegisterNetEvent("inventory:stopCraft")
AddEventHandler("inventory:stopCraft", function()
    local client = tostring(source)
    if crafting[client] then
        crafting[client] = nil
    end
end)

function checkIngredients(client, craftingData)
    local ingredientsToUpdateData = {}
    local playerInventory = getPlayerInventory(client)
    for ingredient, ingredientData in pairs(craftingData.ingredients) do
        if ingredientData.data then
            for key, value in pairs(ingredientData.data) do
                for _, item in each(playerInventory.data) do
                    if item.name == ingredient and not ingredientsToUpdateData[ingredient] then
                        if item.data[key] then
                            if item.data[key] >= ingredientData.data[key] then
                                itemData, itemSlot = item.data, item.slot
                                ingredientsToUpdateData[ingredient] = {
                                    data = item.data,
                                    slot = item.slot,
                                    remove = ingredientData.remove
                                }
                                break
                            end
                        end
                    end
                end
            end
        end

        local itemInfo = ingredientsToUpdateData[ingredient]
        local data = itemInfo and itemInfo.data or {}
        local slot = itemInfo and itemInfo.slot or nil
        if not checkPlayerItem(client, ingredient, ingredientData.count, data) then
            return false
        end
    end
    return true, ingredientsToUpdateData
end

function checkRequirements(client, craftingData)
    if craftingData.requirements then
        for requirement, requirementData in pairs(craftingData.requirements) do
            if not checkPlayerItem(client, requirement, requirementData.count, requirementData.data or {}) then
                return false
            end
        end
    end
    return true
end
