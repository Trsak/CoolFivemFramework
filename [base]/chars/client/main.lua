local isSpawned = false
local createdNewChar = false
local randomPosition
local firstTime = true

Citizen.CreateThread(function()

    Citizen.Wait(400)
    if exports.data:getUserVar("status") == "choosing" then
        TriggerServerEvent("chars:charSelect", exports.data:getUserVar("identifier"))
        startChoosing()
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        TriggerServerEvent("chars:charSelect", exports.data:getUserVar("identifier"))
    end
end)

function ClearScreen()
    SetCloudHatOpacity(0.01)
    HideHudAndRadarThisFrame()
end

function preparePlayerPed(currentPosition)
    if currentPosition then
        randomPosition = currentPosition
    else
        randomPosition = Config.SwitchPositions[math.random(#Config.SwitchPositions)]
    end
    local playerPed = PlayerPedId()

    SetEntityVisible(playerPed, false)
    SetEntityCoords(playerPed, randomPosition)

    if not IsPlayerSwitchInProgress() then
        SwitchOutPlayer(playerPed, 0, 1)
    end

    while GetPlayerSwitchState() ~= 5 do
        Citizen.Wait(0)
        ClearScreen()
    end
end

function startChoosing()
    Citizen.CreateThread(function()
        SendNUIMessage({
            action = "show",
            locations = Config.SpawnLocations,
            firstTime = firstTime
        })

        firstTime = false

        ClearScreen()
        Citizen.Wait(0)
        ClearScreen()
        DoScreenFadeIn(500)
        while not IsScreenFadedIn() do
            Citizen.Wait(0)
            ClearScreen()
        end

        TriggerServerEvent("instance:joinInstance", "char_select_" .. GetPlayerServerId(PlayerId()))

        while true do
            ClearScreen()
            Citizen.Wait(0)

            if isSpawned then
                if createdNewChar then
                    local defaultModel = "mp_m_freemode_01"
                    if exports.data:getCharVar("sex") == 1 then
                        defaultModel = "mp_f_freemode_01"
                    end

                    exports['fivem-appearance']:setPlayerModel(defaultModel, true)
                    exports['fivem-appearance']:setPlayerModel(defaultModel, true)
                    TriggerServerEvent("skinchooser:save", exports['fivem-appearance']:getPedAppearance(PlayerPedId()))
                end

                SwitchInPlayer(PlayerPedId())

                ClearScreen()

                while GetPlayerSwitchState() ~= 12 do
                    Citizen.Wait(0)
                    ClearScreen()
                end

                if not createdNewChar then
                    TriggerServerEvent("instance:quitInstance")
                end
                break
            end
        end

        if createdNewChar then
            exports.skinchooser:openSkinMenu({
                ped = true,
                headBlend = true,
                faceFeatures = true,
                headOverlays = true,
                components = true,
                props = true,
                mask = true,
                tattoos = true,
                canLeave = false,
                vMenuPedsImportAllow = true
            }, {
                save = true,
                callback = function()
                    TriggerServerEvent("instance:quitInstance")
                end
            })
        end

        Wait(1000)
        TriggerEvent("chars:completelyLoaded")
        TriggerServerEvent("chars:completelyLoaded")
    end)
end

RegisterNetEvent("chars:charlist")
AddEventHandler("chars:charlist", function(chars, charsLeft, whitelisted)
    if not exports.base_jobs:checkJobs() then
        TriggerServerEvent("base_jobs:askForJobs")
    end

    while not exports.base_jobs:checkJobs() do
        Citizen.Wait(500)
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "setChars",
        charlist = chars,
        jobsData = exports.base_jobs:getJobs(),
        charsleft = charsLeft,
        isWhitelisted = whitelisted
    })
end)

RegisterNetEvent("chars:error")
AddEventHandler("chars:error", function(error)
    SendNUIMessage({
        action = "error",
        error = error
    })
end)

RegisterNUICallback("choosechar", function(data, cb)
    TriggerServerEvent("chars:chosenChar", data.char, data.location, false)
end)

RegisterNUICallback("removechar", function(data, cb)
    TriggerServerEvent("chars:removeChar", data.charId)
end)

RegisterNUICallback("newchar", function(data, cb)
    TriggerServerEvent("chars:newchar", data)
end)

RegisterNetEvent("chars:spawnChar")
AddEventHandler("chars:spawnChar", function(data, coords, isNew, lastPosition, logoff)
    SendNUIMessage({
        action = "loadingChar",
        isNew = isNew
    })
    createdNewChar = isNew
    --exports.spawnmanager:spawnChar(data, x, y, z + 0.05, heading, isNew, lastPosition)
    spawnPlayer(data, coords, isNew, lastPosition)
    SetNuiFocus(false, false)
end)

RegisterNetEvent("playerSpawned")
AddEventHandler("playerSpawned", function(coords)
    TriggerServerEvent("chars:playerSpawned", coords)
end)

RegisterNetEvent("chars:playerSpawned")
AddEventHandler("chars:playerSpawned", function(coords)
    isSpawned = true
    SendNUIMessage({
        action = "hide"
    })

    local ped = GetPlayerPed(PlayerPedId())
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z + 0.05, false, false, false, true)
    SetEntityHeading(ped, coords.heading or coords.w)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z + 0.05, coords.heading or coords.w, true, true, false)
end)

RegisterNetEvent("chars:charSelectStart")
AddEventHandler("chars:charSelectStart", function()
    local currentPosition
    if isSpawned then
        currentPosition = GetEntityCoords(PlayerPedId())
    end

    TriggerServerEvent("chars:charSelect", exports.data:getUserVar("identifier"))
    freezePlayer(true)

    TriggerEvent("chat:clear")

    Citizen.Wait(50)

    isSpawned = false
    TriggerServerEvent("data:setStatusChoosing")

    Citizen.Wait(50)
    preparePlayerPed(currentPosition)

    Citizen.Wait(0)
    DoScreenFadeOut(0)

    startChoosing()
end)

function freezePlayer(state)
    local player = PlayerId()
    SetPlayerControl(player, not state, false)

    local playerPed = PlayerPedId()
    if not IsEntityVisible(playerPed) then
        SetEntityVisible(playerPed, not state)
    end

    if not IsPedInAnyVehicle(playerPed) then
        SetEntityCollision(playerPed, not state)
    end

    FreezeEntityPosition(playerPed, state)

    SetPlayerInvincible(player, state)
    TriggerServerEvent("admin:playerGodModeWhitelist", state)

    if not IsPedFatallyInjured(playerPed) then
        ClearPedTasksImmediately(playerPed)
    end
end

local canSpawn = true
function spawnPlayer(data, coords, isNew, lastPosition)
    if not canSpawn then
        return
    end
    canSpawn = false
    freezePlayer(true)

    local playerPed = PlayerPedId()

    SetEntityCoordsNoOffset(playerPed, coords.xyz, false, false, false, true)
    SetEntityHeading(playerPed, coords.w)

    NetworkResurrectLocalPlayer(coords.xyz, coords.w, true, true, false)
    ClearPedTasksImmediately(playerPed)

    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(coords.xyz)
        Citizen.Wait(0)
    end

    exports.skinchooser:loadSavedOutfit()

    ShutdownLoadingScreen()

    TriggerEvent("playerSpawned", coords)

    canSpawn = true
    freezePlayer(false)
    
    Citizen.Wait(2000)
    local playerPed = PlayerPedId()
    RemoveAllPedWeapons(playerPed)
    ClearPlayerWantedLevel(PlayerId())
    exports.inventory:setupPlayerWeapons()

    if not lastPosition and not isNew then
        TriggerServerEvent("instance:quitInstance")
        TriggerServerEvent("s:updateInProperty", {})
    end
    
    if data.logoff and data.logoff == 1 then
        Citizen.Wait(2500)
        SetEntityHealth(playerPed, 0)
        SetPedArmour(playerPed, 0)
        Citizen.Wait(2000)
        exports.chat:addMessage({
            templateId = "warning",
            args = {"Odpojil/a ses, když jsi byl/a mrtvý/á!"}
        })
    else
        SetEntityHealth(playerPed, data.health)
        SetPedArmour(playerPed, data.armour)
    end
end
