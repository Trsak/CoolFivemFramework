local usingTintmeter, cutting = false, false
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
    if itemName == "tintmeter" and not usingTintmeter then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = GetClosestVehicle(playerCoords, 5.0, 0, 23)

        if not DoesEntityExist(vehicle) then
            vehicle = getVehicleInDirection()
        end
        if DoesEntityExist(vehicle) then
            usingTintmeter = true
            exports.progressbar:startProgressBar({
                Duration = 10000,
                Label = "Měříš zatmavení skla..",
                CanBeDead = false,
                CanCancel = true,
                DisableControls = {
                    Movement = true,
                    CarMovement = true,
                    Mouse = false,
                    Combat = true
                },
                Animation = {
                    emotes = "tintmeter"
                }
            }, function(finished)
                usingTintmeter = false
                if finished then
                    local checkVeh = GetClosestVehicle(playerCoords, 5.0, 0, 70)

                    if not DoesEntityExist(checkVeh) then
                        checkVeh = getVehicleInDirection()
                    end
                    if checkVeh == vehicle then
                        local level = GetVehicleWindowTint(checkVeh)
                        exports.notify:display({
                            type = "info",
                            title = "Propustnost skla",
                            text = "Úroveň zatmavení skla je " .. GetTintLevel(level),
                            icon = "fas fa-car",
                            length = 3000
                        })
                    else
                        exports.notify:display({
                            type = "warning",
                            title = "Propustnost skla",
                            text = "Vozidlo se vzdálilo",
                            icon = "fas fa-car",
                            length = 3000
                        })
                    end
                end
            end)
        else
            exports.notify:display({
                type = "error",
                title = "Propustnost skla",
                text = "Nejsi poblíž žádného vozidla",
                icon = "fas fa-car",
                length = 3000
            })
        end
    end
end)

function getVehicleInDirection()
    local playerPed = PlayerPedId()
    local coordA = GetEntityCoords(playerPed)
    local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 6.0, 0.0)

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordA, coordB, 10, playerPed, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

function GetTintLevel(index)
    if index == -1 then
        return "základní"
    elseif index == 0 then
        return "čistá"
    elseif index == 1 then
        return "čistě tmavá"
    elseif index == 2 then
        return "tmavá"
    elseif index == 3 then
        return "lehce tmavá"
    elseif index == 4 then
        return "úplně čistá"
    elseif index == 5 then
        return "zelená"
    else
        return "Unknown"
    end
end
