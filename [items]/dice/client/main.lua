local isDead = false
local drawingClients = {}

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        if exports.data:getUserVar("status") == "dead" then
            isDead = true
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        isDead = (status == "dead")
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if itemName == "dice" then
            loadAnimDict("anim@mp_player_intcelebrationmale@wank")
            Citizen.Wait(500)
            TaskPlayAnim(PlayerPedId(), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
            Citizen.Wait(1500)
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent("dice:roll")
        end
    end
)

RegisterNetEvent("dice:roll")
AddEventHandler(
    "dice:roll",
    function(playerServerId, number)
        local player = GetPlayerFromServerId(playerServerId)
        if player ~= nil then
            local playerPed = GetPlayerPed(player)
            if playerPed then
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - GetEntityCoords(PlayerPedId()))

                if player == PlayerId() or (distance > 0.0 and distance < 20.0) then
                    local thisDrawing = math.random()
                    drawingClients[playerServerId] = thisDrawing

                    Citizen.CreateThread(
                        function()
                            local remainingTime = Config.DisplayTime * 100

                            while remainingTime > 0 do
                                if drawingClients[playerServerId] ~= thisDrawing then
                                    break
                                end

                                local playerCoords = GetEntityCoords(playerPed)
                                if not playerCoords then
                                    break
                                end

                                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z - 0.2, "Hod kostkou: ~h~" .. number)
                                remainingTime = remainingTime - 1
                                Citizen.Wait(1)

                                if remainingTime == 0 then
                                    drawingClients[playerServerId] = nil
                                end
                            end
                        end
                    )
                end
            end
        end
    end
)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end
