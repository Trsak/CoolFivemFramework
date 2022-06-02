RegisterNetEvent("inventory:openPlayerInventory")
AddEventHandler(
    "inventory:openPlayerInventory",
    function(target, maxDistance, animation)
        local _source = source

        if not checkAndSetTimer(_source, "openPlayerInventory", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local sourcePed = GetPlayerPed(_source)
        local targetPed = GetPlayerPed(target)
        local distance = #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed))

        if distance >= 10.0 and exports.data:getUserVar(_source, "admin") <= 1 then
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "inventory:openPlayerInventory",
                "Hráč se pokusil otevřít inventář na vzdálenost " .. distance .. " od hráče " .. GetPlayerName(target) .. " (" .. target .. ")"
            )
            return
        end

        local identifier = GetPlayerIdentifier(_source, 0)
        local targetIdentifier = GetPlayerIdentifier(target, 0)

        if Inventories[identifier] ~= nil and Inventories[targetIdentifier] ~= nil then
            Inventories[targetIdentifier].maxWeight = calculateCharMaxWeight(target)

            TriggerClientEvent(
                "inventory:playerInventory",
                _source,
                target,
                Inventories[targetIdentifier],
                maxDistance,
                animation
            )
        end
    end
)

RegisterNetEvent("inventory:takeFromPlayer")
AddEventHandler(
    "inventory:takeFromPlayer",
    function(target, from, to, count)
        local _source = source

        if not checkAndSetTimer(_source, "takeFromPlayer", 150) then
            TriggerClientEvent("inventory:timerError", _source)
            return
        end

        local sourcePed = GetPlayerPed(_source)
        local targetPed = GetPlayerPed(target)
        local distance = #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed))

        if distance >= 20.0 and exports.data:getUserVar(_source, "admin") <= 1 then
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "inventory:takeFromPlayer",
                "Hráč se pokusil vzít item na vzdálenost " .. distance .. " od hráče " .. GetPlayerName(target) .. " (" .. target .. ")"
            )
            return
        end

        local identifier = GetPlayerIdentifier(_source, 0)
        local targetIdentifier = GetPlayerIdentifier(target, 0)

        if Inventories[identifier] ~= nil and Inventories[targetIdentifier] ~= nil then
            for index, item in each(Inventories[targetIdentifier].data) do
                if item.slot == from then
                    local removeResult = removePlayerItem(target, item.name, count, item.data, item.slot)

                    if removeResult == "done" then
                        local addResult = addPlayerItem(_source, item.name, count, item.data, to)

                        if addResult ~= "done" then
                            addPlayerItem(target, item.name, count, item.data, item.slot)
                        else
                            exports.logs:sendToDiscord(
                                {
                                    channel = "rob_players",
                                    title = "Hráči",
                                    description = "Vzal hráči " ..
                                        GetPlayerName(target) ..
                                        " (" ..
                                        exports.data:getCharNameById(
                                            exports.data:getCharVar(tonumber(target), "id")
                                        ) ..
                                        ") - " .. count .. "x " .. getItem(item.name).label,
                                    color = "34749"
                                },
                                _source
                            )
                        end
                    end
                    break
                end
            end
        end
    end
)

RegisterNetEvent("inventory:giveToPlayer")
AddEventHandler(
    "inventory:giveToPlayer",
    function(_source, from, to, count)
        local target = source

        if not checkAndSetTimer(target, "giveToPlayer", 150) then
            TriggerClientEvent("inventory:timerError", target)
            return
        end

        local identifier = GetPlayerIdentifier(_source, 0)
        local targetIdentifier = GetPlayerIdentifier(target, 0)

        if Inventories[identifier] ~= nil and Inventories[targetIdentifier] ~= nil then
            for index, item in each(Inventories[targetIdentifier].data) do
                if item.slot == from then
                    local removeResult = removePlayerItem(target, item.name, count, item.data, item.slot)

                    if removeResult == "done" then
                        local addResult = addPlayerItem(_source, item.name, count, item.data, to)

                        if addResult ~= "done" then
                            addPlayerItem(target, item.name, count, item.data, item.slot)
                        else
                            exports.logs:sendToDiscord(
                                {
                                    channel = "rob_players",
                                    title = "Hráči",
                                    description = "Dal hráči do inventáře " ..
                                        GetPlayerName(_source) ..
                                        " (" ..
                                        exports.data:getCharNameById(
                                            exports.data:getCharVar(tonumber(_source), "id")
                                        ) ..
                                        ") - " .. count .. "x " .. getItem(item.name).label,
                                    color = "34749"
                                },
                                target
                            )
                        end
                    end
                    break
                end
            end
        end
    end
)

RegisterNetEvent("inventory:sortPlayerItems")
AddEventHandler(
    "inventory:sortPlayerItems",
    function(target, from, to)
        local targetIdentifier = GetPlayerIdentifier(target, 0)

        if Inventories[targetIdentifier] ~= nil then
            sortItems(target, from, to)
        end
    end
)

RegisterNetEvent("inventory:splitPlayerItems")
AddEventHandler(
    "inventory:splitPlayerItems",
    function(target, from, to, count)
        splitItem(target, from, to, count)
    end
)

RegisterNetEvent("inventory:swapPlayerItem")
AddEventHandler(
    "inventory:swapPlayerItem",
    function(target, from, to)
        swapItem(target, from, to)
    end
)

RegisterNetEvent("inventory:joinPlayerItem")
AddEventHandler(
    "inventory:joinPlayerItem",
    function(target, from, to, count)
        joinItem(target, from, to, count)
    end
)

RegisterNetEvent("inventory:giveToSelectedPlayer")
AddEventHandler(
    "inventory:giveToSelectedPlayer",
    function(_source, from, count)
        local target = source

        if not checkAndSetTimer(target, "giveToSelectedPlayer", 150) then
            TriggerClientEvent("inventory:timerError", target)
            return
        end

        local identifier = GetPlayerIdentifier(_source, 0)
        local targetIdentifier = GetPlayerIdentifier(target, 0)

        if Inventories[identifier] ~= nil and Inventories[targetIdentifier] ~= nil then
            for index, item in each(Inventories[targetIdentifier].data) do
                if item.slot == from then
                    local removeResult = removePlayerItem(target, item.name, count, item.data, item.slot)

                    if removeResult == "done" then
                        local addResult = addPlayerItem(_source, item.name, count, item.data, to)

                        if addResult ~= "done" then
                            addPlayerItem(target, item.name, count, item.data, item.slot)
                            TriggerClientEvent("inventory:giveError", target, addResult)
                        else
                            TriggerClientEvent("inventory:giveSuccess", target, "gave", item.name, count)
                            TriggerClientEvent("inventory:giveSuccess", _source, "obtained", item.name, count)
                            exports.logs:sendToDiscord(
                                {
                                    channel = "rob_players",
                                    title = "Hráči",
                                    description = "Dal hráči " ..
                                        GetPlayerName(_source) ..
                                        " (" ..
                                        exports.data:getCharNameById(
                                            exports.data:getCharVar(tonumber(_source), "id")
                                        ) ..
                                        ") - " .. count .. "x " .. getItem(item.name).label,
                                    color = "34749"
                                },
                                target
                            )
                        end
                    else
                        TriggerClientEvent("inventory:giveError", target, removeResult)
                    end
                    break
                end
            end
        end
    end
)
