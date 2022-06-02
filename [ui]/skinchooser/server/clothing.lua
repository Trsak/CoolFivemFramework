RegisterNetEvent("skinchooser:pay")
AddEventHandler("skinchooser:pay", function(price)
    local client = source
    exports.inventory:removePlayerItem(client, "cash", price, {})
end)

RegisterNetEvent("skinchooser:takeoffCloth")
AddEventHandler("skinchooser:takeoffCloth", function(clothType, playerSex, playerOutfit, itemData, target)
    local client = source
    if not target then
        takeClothOff(client, clothType, playerSex, playerOutfit, itemData)
    else

        takeClothOff(client, clothType, playerSex, playerOutfit, itemData, target)
    end
end)

function takeClothOff(source, clothType, playerSex, playerOutfit, itemData, target)
    local client = source
    local component = Config.NakedComponents[clothType]

    if playerSex == -1 then
        TriggerClientEvent("notify:display", target or client, {
            type = "error",
            title = "Chyba",
            text = "Pro " .. (target and "jeho" or "tvůj") .. " model není možné sundavat oblečení!",
            icon = "fas fa-times",
            length = 5000
        })
    elseif component then
        local hasSomeClothes = false

        local components = {}
        local props = {}
        local id = ""

        if component.components then
            for i, compData in each(playerOutfit.components) do
                if component.components[tostring(compData.component_id)] then

                    local ignoredClothes = Config.IgnoreComponentsTakeOff[playerSex][tostring(compData.component_id)]

                    if not shouldIgnoreClothes(ignoredClothes, compData.drawable, compData.texture, false) then

                        id = id .. compData.component_id .. ":" .. compData.drawable .. "-" .. compData.texture
                        components[tostring(compData.component_id)] = {compData.drawable, compData.texture}
                        hasSomeClothes = true

                    end
                end
            end
        end

        if component.props then
            for i, propData in each(playerOutfit.props) do
                if component.props[tostring(propData.prop_id)] then

                    local ignoredClothes = Config.IgnorePropsTakeOff[playerSex][tostring(propData.prop_id)]

                    if not shouldIgnoreClothes(ignoredClothes, propData.drawable, propData.texture, true) then

                        id = id .. propData.prop_id .. ":" .. propData.drawable .. "-" .. propData.texture
                        props[tostring(propData.prop_id)] = {propData.drawable, propData.texture}
                        hasSomeClothes = true

                    end
                end
            end
        end

        if hasSomeClothes then
            local data = {}
            data.id = id
            data.sex = playerSex
            data.components = components
            data.props = props

            local addResult = exports.inventory:forceAddPlayerItem(target or client, clothType, 1, data)
            if addResult == "done" then
                TriggerClientEvent("skinchooser:takeoffCloth", client, clothType, itemData, target)
            else
                local text = "Tolik toho neuneseš!"
                if addResult == "weightExceeded" then
                    text = "Tolik toho neuneseš!"
                elseif addResult == "spaceExceeded" then
                    text = "Nemáš dostatek místa!"
                end
                TriggerClientEvent("notify:display", target or client, {
                    type = "error",
                    title = "Chyba",
                    text = text,
                    icon = "fas fa-times",
                    length = 5000
                })
            end
        else
            TriggerClientEvent("notify:display", target or client, {
                type = "error",
                title = "Chyba",
                text = (target and "Nemá" or "Nemáš") .. " na sobě žádnou část tohoto oblečení!",
                icon = "fas fa-times",
                length = 5000
            })
        end
    end
end

RegisterNetEvent("skinchooser:save")
AddEventHandler("skinchooser:save", function(appearance, tattoos)
    local client = source

    if appearance then
        exports.data:updateCharVar(client, "outfit", appearance)
    end

    if tattoos then
        exports.data:updateCharVar(client, "tattoos", tattoos)
    end
end)

function shouldIgnoreClothes(ignoredClothes, drawable, texture, isProp)
    for _, data in each(ignoredClothes) do
        if (data[1] == drawable and (data[2] == -1 or data[2] == texture)) or (isProp and drawable == -1) then
            return true
        end
    end

    return false
end

RegisterNetEvent("skinchooser:sendRequestForTakeoff")
AddEventHandler("skinchooser:sendRequestForTakeoff", function(target, component, playerSex, playerOutfit)
    local client = source
    local clientCoords = GetEntityCoords(GetPlayerPed(client))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if #(clientCoords - targetCoords) < 50.0 then

        TriggerClientEvent("skinchooser:sendRequestForTakeoff", target, component, playerSex, playerOutfit, client)
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "success",
            args = {"Odeslal/a jsi žádost o sundání " .. Config.NakedComponents[component].name .. "!"}
        })
    else
        exports.admin:banClientForCheating(client, "0", "Cheating", "skinchooser:sendRequestForTakeoff", "Hráč se pokusil sundat oblečení někomu, kdo není blízko!")
    end
end)

RegisterNetEvent("skinchooser:answerRequestForTakeoff")
AddEventHandler("skinchooser:answerRequestForTakeoff", function(status, clothType, playerSex, playerOutfit, itemData, target)
    local client = source

    if status == "accept" then
        takeClothOff(client, clothType, playerSex, playerOutfit, itemData, target)
        TriggerClientEvent("chat:addMessage", target, {
            templateId = "success",
            args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " přijata!"}
        })
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "success",
            args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " jsi přijal/a!"}
        })
    elseif status == "decline" then
        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", target, {
                templateId = "warning",
                args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " odmítnuta!"}
            })
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " jsi odmítnul/a! "}
            })
        end
    elseif status == "away" then
        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", target, {
                templateId = "warning",
                args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " zrušena! Jste daleko od sebe!"}
            })
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " zrušena! Jste daleko od sebe!"}
            })
        end
    elseif status == "haveRequest" then
        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", target, {
                templateId = "warning",
                args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " zrušena! Hráč již má žádost!"}
            })
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Žádost o sundání " .. Config.NakedComponents[clothType].name .. " zrušena! Již máš žádost!"}
            })
        end
    end
end)

local sexs = {
    [GetHashKey("mp_m_freemode_01")] = 0,
    [GetHashKey("mp_f_freemode_01")] = 1
}

RegisterNetEvent("skinchooser:sendRequestForTakeon")
AddEventHandler("skinchooser:sendRequestForTakeon", function(target, itemName, itemSlot, itemData)
    local client = source

    local component = Config.NakedComponents[itemName]
    if not component or exports.inventory:getItem(itemName).class ~= "clothes" then
        return
    end

    local targetPed = GetPlayerPed(target)
    local clientCoords = GetEntityCoords(GetPlayerPed(client))
    local targetCoords = GetEntityCoords(targetPed)
    if #(clientCoords - targetCoords) < 50.0 then

        local playerSex = sexs[GetEntityModel(targetPed)]
        if not playerSex then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "warning",
                args = {"Hráčuv model nepodporuje nandavání oblečení!"}
            })
        elseif component.restricted and component.restricted ~= playerSex or itemData.sex ~= playerSex then
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Tohle není pro " .. (playerSex > 0 and "její" or "jeho") .. " pohlaví!",
                icon = "fas fa-times",
                length = 5000
            })
        else
            TriggerClientEvent("skinchooser:sendRequestForTakeon", target, itemName, playerSex, {name = itemName, slot = itemSlot, data = itemData}, client)
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Odeslal/a jsi žádost o nandání " .. component.name .. "!"}
            })
        end

    else
        exports.admin:banClientForCheating(client, "0", "Cheating", "skinchooser:sendRequestForTakeon", "Hráč se pokusil nandat oblečení někomu, kdo není blízko!")
    end
end)

RegisterNetEvent("skinchooser:answerRequestForTakeon")
AddEventHandler("skinchooser:answerRequestForTakeon", function(status, clothType, playerSex, playerOutfit, itemData, target)
    local client = source
    local component = Config.NakedComponents[clothType]
    if not component then
        return
    end

    if status == "accept" then
        TriggerClientEvent("chat:addMessage", target, {
            templateId = "success",
            args = {"Žádost o nandání " .. component.name .. " přijata!"}
        })
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "success",
            args = {"Žádost o nandání " .. component.name .. " jsi přijal/a!"}
        })

        local hasComponent = false

        for _, componentData in each(playerOutfit.components) do
            if itemData.data.components[tostring(componentData.component_id)] then
                local playerValues = component.components[tostring(componentData.component_id)][playerSex]
                if componentData.drawable ~= playerValues[1] or componentData.texture ~= playerValues[2] then
                    hasComponent = true
                    break
                end
            end
        end

        for _, propData in each(playerOutfit.props) do
            if itemData.data.props[tostring(propData.prop_id)] then
                local playerValues = component.props[tostring(propData.prop_id)][playerSex]
                if (propData.drawable ~= playerValues[1] or propData.texture ~= playerValues[2]) and propData.drawable ~=
                    -1 then
                    hasComponent = true
                    break
                end
            end
        end
        local removeItem = exports.inventory:removePlayerItem(target, itemData.name, 1, itemData.data, itemData.slot)
        if removeItem then
            if hasComponent then
                takeClothOff(client, clothType, playerSex, playerOutfit, itemData, target)
            else
                TriggerClientEvent("skinchooser:takeonCloth", client, itemData, playerSex)
            end
        end
    elseif status == "decline" then
        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", target, {
                templateId = "warning",
                args = {"Žádost o nandání " .. component.name .. " odmítnuta!"}
            })
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Žádost o nandání " .. component.name .. " jsi odmítnul/a! "}
            })
        end
    elseif status == "away" then
        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", target, {
                templateId = "warning",
                args = {"Žádost o nandání " .. component.name .. " zrušena! Jste daleko od sebe!"}
            })
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Žádost o nandání " .. component.name .. " zrušena! Jste daleko od sebe!"}
            })
        end
    elseif status == "haveRequest" then
        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", target, {
                templateId = "warning",
                args = {"Další žádost o nandání " .. component.name .. " zrušena! Hráč již má žádost!"}
            })
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = {"Další žádost o nandání " .. component.name .. " zrušena! Již máš žádost!"}
            })
        end
    end
end)

function dump(node, printing)
    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)
    if not printing then
        print(output_str)
    end
    return output_str
end