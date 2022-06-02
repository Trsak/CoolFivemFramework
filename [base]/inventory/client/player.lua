RegisterNetEvent("inventory:openPlayerInventory")
AddEventHandler(
    "inventory:openPlayerInventory",
    function(player, maxDistance, animation)
        if GetPlayerName(player) then
            TriggerServerEvent("inventory:openPlayerInventory", player, maxDistance, animation)
        end
    end
)

RegisterNetEvent("inventory:playerInventory")
AddEventHandler(
    "inventory:playerInventory",
    function(playerId, playerInventory, maxDistance, animation)
        TriggerServerEvent("inventory:setOpenedInventory", playerId)
        openedPlayer = playerId

        isOpened = true
        SetNuiFocus(true, true)

        SendNUIMessage(
            {
                action = "openPlayer",
                inventory = Inventory,
                otherPlayer = playerInventory
            }
        )

        if maxDistance then
            Citizen.CreateThread(
                function()
                    if animation then
                        exports.emotes:playEmoteByName(animation, true)
                    end

                    while isOpened and openedPlayer do
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local targetCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(openedPlayer)))
                        local dist = #(playerCoords - targetCoords)

                        if dist > maxDistance then
                            closeInventory()
                            exports.notify:display({type = "error", title = "Chyba", text = "Hráč se od tebe příliš vzdálil!", icon = "fas fa-times", length = 4000})
                            break
                        end
                        Citizen.Wait(500)
                    end

                    if animation then
                        exports.emotes:cancelEmote()
                    end
                end
            )
        end
    end
)

RegisterNUICallback(
    "takeFromPlayer",
    function(data, cb)
        TriggerServerEvent("inventory:takeFromPlayer", openedPlayer, data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "giveToPlayer",
    function(data, cb)
        TriggerServerEvent("inventory:giveToPlayer", openedPlayer, data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "sortPlayerItems",
    function(data, cb)
        TriggerServerEvent("inventory:sortPlayerItems", openedPlayer, data.from, data.to)
    end
)

RegisterNUICallback(
    "splitPlayerItems",
    function(data, cb)
        TriggerServerEvent("inventory:splitPlayerItems", openedPlayer, data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "swapPlayerItem",
    function(data, cb)
        TriggerServerEvent("inventory:swapPlayerItem", openedPlayer, data.from, data.to)
    end
)

RegisterNUICallback(
    "joinPlayerItem",
    function(data, cb)
        TriggerServerEvent("inventory:joinPlayerItem", openedPlayer, data.from, data.to, data.count)
    end
)
