local logOffed = false

local health = 100
local armour = 0
local coords
local isNewChar = false
local spawnOnlastPosition = false

-- auto-spawn enabled flag
local autoSpawnEnabled = false
local autoSpawnCallback

-- changes the auto-spawn flag
function setAutoSpawn(enabled)
    autoSpawnEnabled = enabled
end

-- sets a callback to execute instead of 'native' spawning when trying to auto-spawn
function setAutoSpawnCallback(cb)
    autoSpawnCallback = cb
    autoSpawnEnabled = true
end

-- function as existing in original R* scripts
function freezePlayer(id, freeze)
    local player = id
    SetPlayerControl(player, not freeze, false)

    local ped = GetPlayerPed(player)
    if not freeze then
        if not IsEntityVisible(ped) then
            SetEntityVisible(ped, true)
        end

        if not IsPedInAnyVehicle(ped) then
            SetEntityCollision(ped, true)
        end

        FreezeEntityPosition(ped, false)
        --SetCharNeverTargetted(ped, false)
        SetPlayerInvincible(player, false)
        TriggerServerEvent("admin:playerGodModeWhitelist", false)
    else
        if IsEntityVisible(ped) then
            SetEntityVisible(ped, false)
        end

        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        --SetCharNeverTargetted(ped, true)
        TriggerServerEvent("admin:playerGodModeWhitelist", true)
        SetPlayerInvincible(player, true)
        --RemovePtfxFromPed(ped)

        if not IsPedFatallyInjured(ped) then
            ClearPedTasksImmediately(ped)
        end
    end
end

-- to prevent trying to spawn multiple times
local spawnLock = false

-- spawns the current player at a certain spawn point index (or a random one, for that matter)
function spawnPlayer()
    if spawnLock then
        return
    end

    spawnLock = true

    Citizen.CreateThread(
        function()
            freezePlayer(PlayerId(), true)

            local ped = PlayerPedId()

            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)

            SetEntityHeading(ped, coords.heading)

            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, true, false)

            ClearPedTasksImmediately(ped)

            while not HasCollisionLoadedAroundEntity(ped) do
                RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                Citizen.Wait(0)
            end

            exports.skinchooser:loadSavedOutfit()

            ShutdownLoadingScreen()

            TriggerEvent("playerSpawned", coords)

            if not spawnOnlastPosition and not isNewChar then
                Citizen.CreateThread(
                    function()
                        Citizen.Wait(5000)
                        TriggerServerEvent("instance:quitInstance")
                        TriggerServerEvent("s:updateInProperty", {})
                    end
                )
            end

            exports.inventory:setupPlayerWeapons()

            Citizen.CreateThread(
                function()
                    Citizen.Wait(5000)
                    local ped = PlayerPedId()
                    SetEntityHealth(ped, health)
                    SetPedArmour(ped, armour)
                    RemoveAllPedWeapons(ped)
                    ClearPlayerWantedLevel(PlayerId())
                    exports.inventory:setupPlayerWeapons()
                end
            )

            spawnLock = false
            freezePlayer(PlayerId(), false)

            if logOffed then
                Citizen.Wait(2500)
                SetEntityHealth(ped, 0)
                SetPedArmour(ped, 0)
                exports.notify:display({ type = "warning", title = "Úmrtí", text = "Odpojil jsi se při smrti!", icon = "fas fa-skull-crossbones", length = 8000 })
                logOffed = false

                TriggerServerEvent(
                    "logs:sendToLog",
                    {
                        channel = "combat-log",
                        title = "Spawn",
                        description = "Spawnul se jako dead",
                        color = "34749"
                    }
                )
            end
        end
    )
end

-- automatic spawning monitor thread, too
local respawnForced

Citizen.CreateThread(
    function()
        -- main loop thing
        while true do
            Citizen.Wait(50)

            local playerPed = PlayerPedId()

            if playerPed and playerPed ~= -1 then
                -- check if we want to autospawn
                if autoSpawnEnabled then
                    if NetworkIsPlayerActive(PlayerId()) then
                        if respawnForced then
                            if autoSpawnCallback then
                                autoSpawnCallback()
                            else
                                spawnPlayer()
                            end

                            respawnForced = false
                        end
                    end
                end
            end
        end
    end
)

function forceRespawn()
    spawnLock = false
    respawnForced = true
end

function spawnChar(data, x, y, z, heading, isNew, lastPosition, logOff)
    isNewChar = isNew

    health = data.health
    armour = data.armour
    coords = {}
    coords.x = x
    coords.y = y
    coords.z = z + 0.05
    coords.heading = heading

    logOffed = logOff == 1

    spawnOnlastPosition = lastPosition

    setAutoSpawn(true)
    forceRespawn()
end
