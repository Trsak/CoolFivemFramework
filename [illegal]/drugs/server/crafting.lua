local labs = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for pointId, pointData in each(Config.Labs) do
        labs[tostring(pointId)] = pointData
    end
    TriggerClientEvent("drugs:sendLabs", -1, labs)
end)

RegisterNetEvent("drugs:requestLabs")
AddEventHandler("drugs:requestLabs", function()
    local client = source
    while not next(labs) do
        Citizen.Wait(100)
    end
    TriggerClientEvent("drugs:sendLabs", client, labs)
end)

RegisterNetEvent("drugs:checkItems")
AddEventHandler("drugs:checkItems", function(id)
    local client = source
    local labData = labs[id]

    if not labData then
        return
    end

    local craftingData = ServerConfig.Crafting[labData.Drug][labData.Type]

    if not craftingData then
        return
    end

    local item = craftingData.item or craftingData[1].item
    local canCraft, ingredientsToUpdateData = false, {}

    if craftingData.ingredients then
        canCraft, ingredientsToUpdateData = checkIngredients(client, craftingData)

        if canCraft then
            canCraft = checkRequirements(client, craftingData)
        end
    else
        for i, data in each(craftingData) do
            canCraft, ingredientsToUpdateData = checkIngredients(client, data)
            if canCraft then
                canCraft = checkRequirements(client, data)
            end
            if canCraft then
                break
            end
        end

    end

    TriggerClientEvent("drugs:answerItemCheck", client, id, canCraft)
end)

RegisterNetEvent("drugs:craftItem")
AddEventHandler("drugs:craftItem", function(id)
    local client = source
    local labData = labs[id]

    if not labData then
        return
    end

    local craftingData = ServerConfig.Crafting[labData.Drug][labData.Type]

    if not craftingData then
        return
    end

    local item = craftingData.item or craftingData[1].item
    local canCraft, ingredientsToUpdateData = false, {}

    if craftingData.ingredients then
        canCraft, ingredientsToUpdateData = checkIngredients(client, craftingData)

        if canCraft then
            canCraft = checkRequirements(client, craftingData)
        end
    else
        for i, data in each(craftingData) do
            canCraft, ingredientsToUpdateData = checkIngredients(client, data)
            if canCraft then
                canCraft = checkRequirements(client, data)
            end
            if canCraft then
                break
            end
        end

    end

    if canCraft then
        for ingredient, ingredientData in pairs(craftingData.ingredients) do
            local itemData = ingredientData.data
            if ingredientsToUpdateData[ingredient] then
                itemData = ingredientsToUpdateData[ingredient].data
            end

            local removeItem = exports.inventory:removePlayerItem(client, ingredient, ingredientData.count,
                itemData or {})
            if removeItem ~= "done" then
                logCrafting(client, "missing", item)
                return
            elseif ingredientsToUpdateData[ingredient] then
                local item = ingredientsToUpdateData[ingredient]
                if not item.remove then
                    local newAmount = (item.data.amount - 1)
                    if ingredientData.type == "food" then
                        exports.food:giveItem(client, ingredient, ingredientData.count, nil, newAmount)
                    else
                        local newData = {}
                        local newAmount = (item.data.amount - ingredientData.data.amount)
                        if type(item.data.id) == "string" then
                            newData = {
                                id = ingredient .. "-" .. newAmount,
                                amount = newAmount,
                                label = "Zbývá: " .. newAmount
                            }
                        else
                            newData = {
                                id = newAmount,
                                amount = newAmount,
                                label = "Zbývá: " .. newAmount
                            }
                        end
                        exports.inventory:forceAddPlayerItem(client, ingredient, ingredientData.count, newData)
                    end
                end
            end
        end

        local countToAdd = getAddCount(craftingData.count)
        if craftingData.type == "food" then
            exports.food:giveItem(client, item, countToAdd)
        else
            exports.inventory:forceAddPlayerItem(client, item, countToAdd, craftingData.data or {})

        end
        if craftingData.additions then
            for addition, additionData in pairs(craftingData.additions) do
                exports.inventory:forceAddPlayerItem(client, addition, additionData.count, additionData.data or {})
            end
        end
        logCrafting(client, "success", item)
    else
        logCrafting(client, "missing", item)
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
    if state == "success" then
        TriggerClientEvent("notify:display", client, {
            type = "success",
            title = "Výroba drog",
            text = "Úspěšně vyrobeno!",
            icon = "fas fa-prescription-bottle",
            length = 3000
        })
    elseif state == "missing" then
        TriggerClientEvent("notify:display", client, {
            type = "warning",
            title = "Výroba drog",
            text = "Něco ti chybí!",
            icon = "fas fa-prescription-bottle",
            length = 3000
        })
    end
    exports.logs:sendToDiscord({
        channel = "crafting",
        title = "Výroba drog",
        description = "Vyrobil/a " .. exports.inventory:getItem(item).label,
        color = "5735736"
    }, client)
end

function checkIngredients(client, craftingData)
    local ingredientsToUpdateData = {}
    local playerInventory = exports.inventory:getPlayerInventory(client)
    for ingredient, ingredientData in pairs(craftingData.ingredients) do
        if ingredientData.data and ingredientData.data.amount then
            for _, item in each(playerInventory.data) do
                if item.name == ingredient and not ingredientsToUpdateData[ingredient] then
                    if item.data.amount and item.data.amount >= ingredientData.data.amount then
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

        local itemInfo = ingredientsToUpdateData[ingredient]
        local data = itemInfo and itemInfo.data or {}
        if not exports.inventory:checkPlayerItem(client, ingredient, ingredientData.count, data) then
            return false
        end
    end
    return true, ingredientsToUpdateData
end

function checkRequirements(client, craftingData)
    if craftingData.requirements then
        for requirement, requirementData in pairs(craftingData.requirements) do
            if not exports.inventory:checkPlayerItem(client, requirement, requirementData.count,
                requirementData.data or {}) then
                return false
            end
        end
    end
    return true
end
