function addCasinoChips(client, count)
    for _, value in each(Config.CasinoChips) do
        local numberOfChips = count // value

        if numberOfChips > 0 then
            local itemName = "chip_" .. tostring(value)
            forceAddPlayerItem(client, itemName, numberOfChips, {}, nil, true)

            count = count - (numberOfChips * value)
        end
    end
end

function removeCasinoChipsByValue(client, chipsValue)
    local chipsTotalValue = getCasinoChipsTotalValue(client)

    if chipsValue == -1 then
        chipsValue = chipsTotalValue
    end

    if chipsValue > chipsTotalValue then
        return "notEnoughChips"
    elseif chipsValue % 10 ~= 0 then
        return "wrongChipsValue"
    elseif chipsValue <= 0 then
        return "noneToRemove"
    end

    local valueLeft = chipsValue
    local chipsToRemove = {}
    local chipValues = getCasinoChipsValuesReversed()
    local currentCasinoChips = getCasinoChips(client)

    for _, value in each(chipValues) do
        local count = currentCasinoChips[value]
        local numberOfChips = math.ceil(valueLeft / value)

        if numberOfChips > 0 then
            if numberOfChips > count then
                numberOfChips = count
            end

            chipsToRemove[value] = numberOfChips
            valueLeft = valueLeft - (numberOfChips * value)
        end

        if valueLeft <= 0 then
            break
        end
    end
    if valueLeft <= 0 then
        removeCasinoChips(client, chipsToRemove)

        if valueLeft < 0 then
            addCasinoChips(client, valueLeft * -1)
        end
        return "done"
    else
        return "notEnoughChips"
    end
end

function removeCasinoChips(client, chipsToRemove)
    local identifier = GetPlayerIdentifier(client, 0)
    local currentCasinoChips = getCasinoChips(client)

    for chipValue, count in pairs(chipsToRemove) do
        if count > currentCasinoChips[chipValue] then
            return false
        end
    end

    for chipValue, count in pairs(chipsToRemove) do
        local itemName = "chip_" .. tostring(chipValue)
        removePlayerItem(client, itemName, count, {})
    end

    removeZeroCountItems(identifier)
    TriggerClientEvent("inventory:reloadInventory", -1, client, Inventories[identifier])
    return true
end

function getCasinoChips(client)
    local identifier = exports.data:getUserVar(client, "identifier")
    local chips = {}

    for i = #Config.CasinoChips, 1, -1 do
        chips[Config.CasinoChips[i]] = 0
    end

    for _, item in each(Inventories[identifier].data) do
        if string.starts(item.name, "chip_") then
            local chipValue = tonumber(string.sub(item.name, 6))
            chips[chipValue] = chips[chipValue] + item.count
        end
    end

    return chips
end

function getCasinoChipsTotalValue(client)
    local identifier = exports.data:getUserVar(client, "identifier")
    local chipValues = 0

    for index, item in each(Inventories[identifier].data) do
        if string.starts(item.name, "chip_") then
            local chipValue = tonumber(string.sub(item.name, 6))
            chipValues = chipValues + (chipValue * item.count)
        end
    end

    return chipValues
end

function getCasinoChipsValues()
    return Config.CasinoChips
end

function getCasinoChipsValuesReversed()
    local chips = table.copy(Config.CasinoChips)
    table.sort(chips, function(a, b)
        return a < b
    end)
    return chips
end

function table.copy(t)
    local u = { }
    for k, v in pairs(t) do
        u[k] = v
    end
    return setmetatable(u, getmetatable(t))
end