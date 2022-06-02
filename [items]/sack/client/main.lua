local isSpawned, isDead = false, false
local sackNetId = nil

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
AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    if not isDead and itemName == "sack" then
        if canDoAction() then
            takeOnSack()
        end
    end
end)

function takeOnSack()
    TriggerEvent("util:closestPlayer", {
        radius = 2.0
    }, function(player)
        if player then
            checkHasBag(player)
        end
    end)
end

function checkHasBag(player)
    WarMenu.CloseMenu()
    if not Player(player).state.hasSack then
        exports.progressbar:startProgressBar({
            Duration = 2000,
            Label = "Nandaváš osobě pytel..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = false,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                animDict = "anim@gangops@facility@servers@",
                anim = "hotwire",
                flags = 51
            }
        }, function(finished)
            if finished then
                local playerCoords, targetCoords = GetEntityCoords(PlayerPedId()),
                    GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
                if #(playerCoords - targetCoords) <= 5.0 then
                    TriggerServerEvent("sack:putSackOnPlayer", player)
                else
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Hráč se oddálil!",
                        icon = "fas fa-times",
                        length = 4000
                    })

                end
            end
        end)
    else
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Hráč již pytel má!",
            icon = "fas fa-times",
            length = 4000
        })
    end
end

RegisterNetEvent("sack:putSackOnPlayer")
AddEventHandler("sack:putSackOnPlayer", function(source)

    local playerPed = PlayerPedId()
    local tPed = GetPlayerPed(GetPlayerFromServerId(source))

    if not hasSack then
        hasSack = true
        exports.emotes:cancelEmote()

        SendNUIMessage({
            action = "takeon"
        })
        local hash = GetHashKey("p_cs_sack_01_s")
        while not HasModelLoaded(hash) do
            Citizen.Wait(100)
            RequestModel(hash)
        end
        local boneIndex = GetPedBoneIndex(playerPed, 12844)
        local prop = CreateObject(hash, GetEntityCoords(playerPed), true, true, true)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0.01, 0.01, 0.0, -1.0, -88.0, 89.0, true, true, false, false,
            1, true)
        SetEntityCollision(prop, false, true)
        sackNetId = NetworkGetNetworkIdFromEntity(prop)
    end
end)

function takeOffSack()
    if LocalPlayer.state.hasSack and not LocalPlayer.state.isCuffed then
        exports.progressbar:startProgressBar({
            Duration = 2000,
            Label = "Sundaváš si pytel..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = false,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                animDict = "missheist_agency2ahelmet",
                anim = "take_off_helmet_stand",
                flags = 51
            }
        }, function(finished)
            if finished then
                TriggerServerEvent("sack:takeOffSackFromPlayer")
            end
        end)
        return
    end
    TriggerEvent("util:closestPlayer", {
        radius = 2.0
    }, function(player)
        if player then
            if Player(player).state.hasSack then
                TriggerServerEvent("sack:takeOffSackFromPlayer", player)
            else
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Hráč nemá pytel na hlavě!",
                    icon = "fas fa-times",
                    length = 4000
                })
            end
        end
    end)
end

RegisterNetEvent("sack:takeOffSackFromPlayer")
AddEventHandler("sack:takeOffSackFromPlayer", function(source)
    local playerPed = PlayerPedId()
    local tPed = GetPlayerPed(GetPlayerFromServerId(source))

    if hasSack then
        hasSack = false
        SendNUIMessage({
            action = "takeoff"
        })
        DeleteEntity(NetworkGetEntityFromNetworkId(sackNetId))
        sackNetId = false
    end
end)

function canDoAction()
    if not LocalPlayer.state.isCuffed and GetVehiclePedIsIn(PlayerPedId()) == 0 then
        return true
    end
    exports.notify:display({
        type = "error",
        title = "Akce",
        text = "Nelze momentálně provést akci!",
        icon = "fas fa-times",
        length = 3000
    })
    return false
end
