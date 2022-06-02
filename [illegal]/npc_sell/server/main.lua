math.randomseed(os.time())

RegisterNetEvent("npc_sell:confirmBuy")
AddEventHandler(
    "npc_sell:confirmBuy",
    function(netId, betterPrice)
        local client = source
        local targetPed = NetworkGetEntityFromNetworkId(netId)

        if DoesEntityExist(targetPed) then
            local ent = Entity(targetPed)

            if ent.state.sellPlayer == client then
                local sellPrice = ent.state.sellPrice

                if betterPrice == nil then
                    sellWeed(client, netId, sellPrice)

                    if ent.state.isFriendlyRelationship then
                        exports.daily_limits:addLimitCount(client, "weed_npc_sell", 1)
                    end
                else
                    local betterPrices = {
                        math.ceil(sellPrice + sellPrice * 0.1),
                        math.ceil(sellPrice + sellPrice * 0.2),
                        math.ceil(sellPrice + sellPrice * 0.3),
                        math.ceil(sellPrice + sellPrice * 0.4),
                        math.ceil(sellPrice + sellPrice * 0.5)
                    }

                    local betterPriceIndex = 1
                    for i, betterPriceAmount in each(betterPrices) do
                        if betterPriceAmount == betterPrice then
                            betterPriceIndex = i
                            break
                        end
                    end

                    if Config.BetterPriceChances[betterPriceIndex] >= math.random(0, 100) then
                        sellWeed(client, netId, betterPrice)

                        if ent.state.isFriendlyRelationship then
                            exports.daily_limits:addLimitCount(client, "weed_npc_sell", 1)
                        end
                    else
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "error",
                                title = "Neúspěch",
                                text = Config.DeclineBetterPriceMessages[math.random(#Config.DeclineBetterPriceMessages)] .. "!",
                                icon = "fas fa-cannabis",
                                length = 3000
                            }
                        )
                    end
                end
            end
        end
    end
)

RegisterNetEvent("npc_sell:startTalk")
AddEventHandler(
    "npc_sell:startTalk",
    function(netId, pedRelationshipGroupHash, relationship)
        local client = source
        local identifier = GetPlayerIdentifier(client, 0)
        local targetPed = NetworkGetEntityFromNetworkId(netId)

        if DoesEntityExist(targetPed) then
            local playerPed = GetPlayerPed(client)
            local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed))

            if distance > 15.0 then
                exports.admin:banClientForCheating(client, "0", "Cheating", "npc_sell:startTalk", "Pokusil se prodat trávu na vzdálenost " .. distance)
                return
            end

            ClearPedTasks(playerPed)

            if exports.data:countEmployees(nil, "police", nil, true) < Config.RequiredCops then
                TriggerClientEvent(
                    "chat:addMessage",
                    client,
                    {
                        templateId = "error",
                        args = {
                            "Pro prodej trávy musí být na serveru alespoň " .. Config.RequiredCops .. " policistů!"
                        }
                    }
                )
                return
            end

            local hasWeedToSell = exports.inventory:checkPlayerItem(client, "weedbag", 1, {})
            local isFriendlyRelationship = isFriendlyRelationship(relationship)

            if hasWeedToSell then
                local ent = Entity(targetPed)
                local pedData = getDataByRelationshipGroupHash(pedRelationshipGroupHash)

                if isFriendlyRelationship and exports.daily_limits:checkIfIsOverLimit(client, "weed_npc_sell") then
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Neúspěch",
                            text = "Prodal si až moc trávy, dej si pauzu...",
                            icon = "fas fa-user",
                            length = 3000
                        }
                    )
                elseif not canPedBeInteracted(ent.state.lastInteraction) then
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Neúspěch",
                            text = "Této osobě se již někdo nedávno pokoušel trávu prodat...",
                            icon = "fas fa-user",
                            length = 3000
                        }
                    )
                elseif pedData ~= nil then
                    ent.state.lastInteraction = os.time()

                    if pedData.ShootingStartChance >= math.random(0, 100) and not isFriendlyRelationship then
                        TaskCombatPed(targetPed, playerPed, 0, 16)

                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "error",
                                title = "Neúspěch",
                                text = "Podařilo se ti tuto osobu pěkně naštvat!",
                                icon = "fas fa-user",
                                length = 3000
                            }
                        )
                    elseif pedData.PoliceReportChance >= math.random(0, 100) and not isFriendlyRelationship then
                        TriggerClientEvent("npc_sell:callPolice", NetworkGetEntityOwner(targetPed), netId)

                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "error",
                                title = "Neúspěch",
                                text = Config.DeclineMessages[math.random(#Config.DeclineMessages)] .. "!",
                                icon = "fas fa-user",
                                length = 3000
                            }
                        )
                    elseif pedData.DeclineChance >= math.random(0, 100) then
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "error",
                                title = "Neúspěch",
                                text = Config.DeclineMessages[math.random(#Config.DeclineMessages)] .. "!",
                                icon = "fas fa-user",
                                length = 3000
                            }
                        )
                    else
                        local sellPrice = math.random(pedData.Reward[1], pedData.Reward[2])

                        if not isFriendlyRelationship then
                            sellPrice = sellPrice + 30
                        end

                        ent.state.sellPlayer = client
                        ent.state.sellPrice = sellPrice
                        ent.state.isFriendlyRelationship = isFriendlyRelationship

                        TriggerClientEvent("npc_sell:sellToPlayer", client, netId, sellPrice, isFriendlyRelationship)
                    end
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Nemáš trávu",
                        text = "Nemáš u sebe zabalenou trávu k prodeji!",
                        icon = "fas fa-cannabis",
                        length = 3000
                    }
                )
            end
        end
    end
)

function isFriendlyRelationship(relationship)
    return relationship <= 2
end

function getDataByRelationshipGroupHash(pedRelationshipGroupHash)
    for pedGroup, pedGroupData in pairs(Config.PedGroups) do
        if GetHashKey(pedGroup) == pedRelationshipGroupHash then
            return pedGroupData
        end
    end

    return nil
end

function canPedBeInteracted(lastInteraction)
    return lastInteraction == nil or lastInteraction + Config.PedTimeout < os.time()
end

function sellWeed(client, netId, price)
    local removeWeedBag = exports.inventory:removePlayerItem(client, "weedbag", 1, {})
    if removeWeedBag == "done" then
        exports.inventory:forceAddPlayerItem(client, "cash", math.ceil(price), {})
        TriggerClientEvent("npc_sell:sold", client, netId, price)

        exports.logs:sendToDiscord(
            {
                channel = "weed-npc-sell",
                title = "Prodej balíčku weedu",
                description = "Prodal balíček trávy za " .. price .. "$",
                color = "2067276"
            },
            client
        )
    else
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "error",
                title = "Nemáš trávu",
                text = "Nemáš u sebe zabalenou trávu k prodeji!",
                icon = "fas fa-cannabis",
                length = 3000
            }
        )
    end
end
