function getCasinoChipsTotalValue()
    local chipValues = 0

    for index, item in each(Inventory.data) do
        if string.starts(item.name, "chip_") then
            local chipValue = tonumber(string.sub(item.name, 6))
            chipValues = chipValues + (chipValue * item.count)
        end
    end

    return chipValues
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end