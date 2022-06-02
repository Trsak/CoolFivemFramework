local usingTester, cutting = false, false
local isSpawned, isDead = false, false

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == ("spawned" or "dead") then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == ("spawned" or "dead") then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("inventory:usedItem")
AddEventHandler("inventory:usedItem", function(itemName)
    if not isSpawned or isDead then
        return
    end
    if itemName == "alcoholtester" and not usingTester then
        TriggerEvent("util:closestPlayer", {
            radius = 2.0
        }, function(player)
            if player then
                usingTester = true
                exports.progressbar:startProgressBar({
                    Duration = 10000,
                    Label = "Měříš hodnotu alkoholu v dechu",
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = true,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = {
                        emotes = "alcoholtester"
                    }
                }, function(finished)
                    usingTester = false
                    if finished then
                        local playerCoords, targetCoords = GetEntityCoords(PlayerPedId()), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
                        if #(playerCoords - targetCoords) <= 5.0 then
                            TriggerServerEvent("alcoholtester:getPlayerDrunkLevel", player)
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Chyba",
                                text = "Osoba se oddálila!",
                                icon = "fas fa-times",
                                length = 4000
                            })

                        end
                    end
                end)
            end
        end)
    end
end)