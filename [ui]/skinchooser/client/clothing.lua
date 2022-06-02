local spamActionProtect = 0

Citizen.CreateThread(function()
    Citizen.Wait(500)
    exports.chat:addSuggestion("/sundat", "Sundat určitý druh oblečení", {{
        name = "druh",
        help = "Druh oblečení"
    }})
    exports.chat:addSuggestion("/takeoff", "Sundat určitý druh oblečení", {{
        name = "druh",
        help = "Druh oblečení"
    }})
end)

AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    local component = Config.NakedComponents[itemName]
    if not component then
        return
    end
    checkIfHasPedCloth(itemName, data, slot)
end)

function checkIfHasPedCloth(itemName, data, slot)
    local playerSex = getPlayerSex()
    local playerOutfit = getPlayerOutfit()

    local component = Config.NakedComponents[itemName]
    if component.restricted and component.restricted ~= playerSex or data.sex ~= playerSex then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Tohle není pro tvoje pohlaví!",
            icon = "fas fa-times",
            length = 3500
        })
    elseif playerSex == -1 then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Pro tvůj model není možné nandavat oblečení!",
            icon = "fas fa-times",
            length = 5000
        })
    else
        local hasComponent = false

        for _, componentData in each(playerOutfit.components) do
            if data.components[tostring(componentData.component_id)] then
                local playerValues = component.components[tostring(componentData.component_id)][playerSex]
                if componentData.drawable ~= playerValues[1] or componentData.texture ~= playerValues[2] then
                    hasComponent = true
                    break
                end
            end
        end

        for _, propData in each(playerOutfit.props) do
            if data.props[tostring(propData.prop_id)] then
                local playerValues = component.props[tostring(propData.prop_id)][playerSex]
                if (propData.drawable ~= playerValues[1] or propData.texture ~= playerValues[2]) and propData.drawable ~=
                    -1 then
                    hasComponent = true
                    break
                end
            end
        end

        local itemData = {
            name = itemName,
            slot = slot,
            data = data
        }

        if not hasComponent then
            useClothingComponentItem(itemData, playerSex, true)
        else
            TriggerServerEvent("skinchooser:takeoffCloth", itemName, playerSex, playerOutfit, itemData)
        end
    end
end

function useClothingComponentItem(itemData, playerSex, removeItem)
    local component = Config.NakedComponents[itemData.name]
    if component then
        exports.progressbar:startProgressBar({
            Duration = 500,
            Label = component.progress.text,
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = false,
                CarMovement = false,
                Mouse = false,
                Combat = true
            },
            Animation = {
                animDict = component.progress.animDict,
                anim = component.progress.anim
            }
        }, function(finished)
            if finished then
                local playerOutfit = {
                    components = {},
                    props = {}
                }

                for componentId, componentData in each(itemData.data.components) do
                    table.insert(playerOutfit.components, {
                        component_id = tonumber(componentId),
                        drawable = componentData[1],
                        texture = componentData[2]
                    })
                end

                if component.props then
                    for propId, propData in each(itemData.data.props) do
                        table.insert(playerOutfit.props, {
                            prop_id = tonumber(propId),
                            drawable = propData[1],
                            texture = propData[2]
                        })
                    end
                end

                setPlayerOutfit(playerOutfit, true)
                if removeItem then
                    TriggerServerEvent("inventory:removePlayerItem", itemData.name, 1, itemData.data, itemData.slot)
                end
            end
        end)
    end
end

function openClothingMenu(target)
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("clothingmenu", "Sundat oblečení", "Zvolte akci")
        WarMenu.OpenMenu("clothingmenu")

        local playerSex = getPlayerSex()
        local playerOutfit = getPlayerOutfit(target)
        local targetPed = nil

        if target then
            targetPed = GetPlayerPed(GetPlayerFromServerId(target))
            playerSex = getPlayerSex(targetPed)
            playerOutfit = getPlayerOutfit(targetPed)
        end

        if playerSex == -1 then
            TriggerEvent("chat:addMessage", {
                templateId = "warning",
                args = {(targetPed and "Hráčův" or "Tvůj") .. " model nepodporuje sundavání oblečení!"}
            })
            return
        end

        local playerPed = PlayerPedId()
        while WarMenu.IsMenuOpened("clothingmenu") do
            if target and targetPed and #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed)) > 5.0 then
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Osoba se přilíš vzdálila!",
                    icon = "fas fa-times",
                    length = 3500
                })
                WarMenu.CloseMenu()
            end
            for _, component in each(Config.ComponentsMenuPosition) do
                local data = Config.NakedComponents[component]
                if not data.restricted or data.restricted == playerSex then
                    if WarMenu.Button(data.label) then
                        if spamActionProtect <= 0 then
                            spamActionProtect = 500
                            if target then
                                -- if data.takeoff then
                                --     loadAnimDict(data.takeoff.animDict)
                                --     TaskPlayAnim(PlayerPedId(), data.takeoff.animDict, data.takeoff.anim, 8.0, 1.0, 500,
                                --         49, 0, 0, 0, 0)
                                --     Citizen.Wait(500)
                                -- end
                                TriggerServerEvent("skinchooser:sendRequestForTakeoff", target, component, playerSex,
                                    playerOutfit)
                            else
                                TriggerServerEvent("skinchooser:takeoffCloth", component, playerSex, playerOutfit)
                            end
                        end
                    end
                end
            end

            WarMenu.Display()
            Citizen.Wait(1)
        end
    end)
end

local hasRequest = false
RegisterNetEvent("skinchooser:sendRequestForTakeoff")
AddEventHandler("skinchooser:sendRequestForTakeoff", function(component, playerSex, playerOutfit, target)
    if hasRequest then
        TriggerServerEvent("skinchooser:answerRequestForTakeoff", "haveRequest", component, nil, nil, nil, target)
        return
    end
    hasRequest = true

    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
    TriggerEvent("chat:addMessage", {
        templateId = "warning",
        args = {"Přišla ti žádost o sundání " .. Config.NakedComponents[component].name ..
            ". Stiskni Z pro přijetí a L pro odmítnutí."}
    })

    while hasRequest do
        Citizen.Wait(5)
        if IsControlJustPressed(0, 246) then
            local closestPlayers = exports.control:getClosestPlayersInDistance(3.5)
            local foundPlayer = false

            for i, player in each(closestPlayers) do
                if player.playerid == target then
                    foundPlayer = true
                    break
                end
            end

            if foundPlayer then
                TriggerServerEvent("skinchooser:answerRequestForTakeoff", "accept", component, playerSex, playerOutfit,
                    nil, target)
            else
                TriggerServerEvent("skinchooser:answerRequestForTakeoff", "away", component, nil, nil, nil, target)
            end
            hasRequest = false
        elseif IsControlJustPressed(0, 182) then
            TriggerServerEvent("skinchooser:answerRequestForTakeoff", "decline", component, nil, nil, nil, target)
            hasRequest = false
        end
    end
end)

RegisterNetEvent("skinchooser:sendRequestForTakeon")
AddEventHandler("skinchooser:sendRequestForTakeon", function(component, playerSex, itemData, target)
    if hasRequest then
        TriggerServerEvent("skinchooser:answerRequestForTakeon", "haveRequest", component, nil, nil, nil, target)
        return
    end
    hasRequest = true

    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
    TriggerEvent("chat:addMessage", {
        templateId = "warning",
        args = {"Přišla ti žádost o nandání " .. Config.NakedComponents[component].name ..
            ". Stiskni Z pro přijetí a L pro odmítnutí."}
    })

    while hasRequest do
        Citizen.Wait(5)
        if IsControlJustPressed(0, 246) then
            local closestPlayers = exports.control:getClosestPlayersInDistance(3.5)
            local foundPlayer = false

            for i, player in each(closestPlayers) do
                if player.playerid == target then
                    foundPlayer = true
                    break
                end
            end

            if foundPlayer then
                local playerOutfit = getPlayerOutfit()
                TriggerServerEvent("skinchooser:answerRequestForTakeon", "accept", component, playerSex, playerOutfit, itemData, target)
            else
                TriggerServerEvent("skinchooser:answerRequestForTakeon", "away", component, nil, nil, nil, target)
            end
            hasRequest = false
        elseif IsControlJustPressed(0, 182) then
            TriggerServerEvent("skinchooser:answerRequestForTakeon", "decline", component, nil, nil, nil, target)
            hasRequest = false
        end
    end
end)

RegisterNetEvent("skinchooser:takeonCloth")
AddEventHandler("skinchooser:takeonCloth", function(itemData, playerSex)
    useClothingComponentItem(itemData, playerSex, false)
end)

-- SHITS
RegisterNetEvent("skinchooser:takeoffCloth")
AddEventHandler("skinchooser:takeoffCloth", function(clothType, itemData, player)
    local component = Config.NakedComponents[clothType]
    local playerSex = getPlayerSex()

    if component then
        if component.restricted and component.restricted ~= playerSex then
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Tohle není pro tvoje pohlaví!",
                icon = "fas fa-times",
                length = 3500
            })
        else
            if component.takeoff and not player then
                loadAnimDict(component.takeoff.animDict)
                TaskPlayAnim(PlayerPedId(), component.takeoff.animDict, component.takeoff.anim, 8.0, 1.0, 500, 49, 0, 0,
                    0, 0)
                Citizen.Wait(500)
            end

            if not itemData then
                local playerOutfit = {
                    components = {},
                    props = {}
                }

                if component.components then
                    for componentId, componentData in each(component.components) do
                        table.insert(playerOutfit.components, {
                            component_id = tonumber(componentId),
                            drawable = componentData[playerSex][1],
                            texture = componentData[playerSex][2]
                        })
                    end
                end

                if component.props then
                    for propId, propData in each(component.props) do
                        table.insert(playerOutfit.props, {
                            prop_id = tonumber(propId),
                            drawable = propData[playerSex][1],
                            texture = propData[playerSex][2]
                        })
                    end
                end

                setPlayerOutfit(playerOutfit, true)
            else
                useClothingComponentItem(itemData, playerSex, true)
            end
        end
    end
end)

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

inShop = false

RegisterCommand("sundat", function(source, args, rawCommand)
    takeOffCommand(args[1])
end)

RegisterCommand("takeoff", function(source, args, rawCommand)
    takeOffCommand(args[1])
end)

function takeOffCommand(arg)
    if not inShop then
        if not arg then
            openClothingMenu()
        elseif arg == "nearby" then
            openClosestMenu()
        else
            local component = findComponentByCommand(arg)
            if not component then
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Špatně zadaná část oblečení!",
                    icon = "fas fa-times",
                    length = 3500
                })
            else
                local data = Config.NakedComponents[component]
                local playerSex = getPlayerSex()

                if data.restricted and data.restricted ~= playerSex then
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Tohle není pro tvoje pohlaví!",
                        icon = "fas fa-times",
                        length = 3500
                    })
                elseif playerSex == -1 then
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Pro tvůj model není možné sundavat oblečení!",
                        icon = "fas fa-times",
                        length = 3500
                    })
                elseif spamActionProtect <= 0 then
                    spamActionProtect = 500
                    local playerOutfit = getPlayerOutfit()
                    TriggerServerEvent("skinchooser:takeoffCloth", component, playerSex, playerOutfit)
                end
            end
        end
    end
end

function findComponentByCommand(arg)
    if arg == nil then
        return nil
    end

    for component, data in pairs(Config.NakedComponents) do
        for i, command in each(data.commands) do
            if command == arg then
                return component
            end
        end
    end

    return nil
end

Citizen.CreateThread(function()
    while true do
        if spamActionProtect > 0 then
            spamActionProtect = spamActionProtect - 100
        end
        Wait(100)
    end
end)

function openClosestMenu()
    TriggerEvent("util:closestPlayer", {
        radius = 2.0
    }, function(player)
        if player then
            openClothingMenu(player)
        end
    end)
end
