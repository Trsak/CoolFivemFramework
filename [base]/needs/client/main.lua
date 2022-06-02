playerNeeds = nil
currentStress = 0
isSpawned = false
isDead = false
local wasDead = false
local reportTimers = {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            setupNeeds()
            isSpawned = true
            isDead = (status == "dead")

            if isDead then
                setNeed("stress", 0)
            end
        end

        while true do
            if playerNeeds then
                Citizen.Wait(Config.ReduceTimer)

                for needName, needValue in pairs(playerNeeds) do
                    local needData = Config.Needs[needName]
                    local oldValue = needValue

                    if not needData then
                        playerNeeds[needName] = nil
                    else
                        local newValue = needValue - needData.reducer

                        if newValue < needData.min then
                            newValue = needData.min
                        elseif newValue > needData.max then
                            newValue = needData.max
                        end

                        if oldValue ~= newValue then
                            playerNeeds[needName] = newValue
                            TriggerEvent("needs:needChanged", needName, newValue)
                        end
                    end
                end
                TriggerServerEvent("needs:update", playerNeeds)
            else
                Citizen.Wait(500)
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        isDead = (status == "dead")

        if status == "choosing" then
            isSpawned = false
        end

        if not isSpawned and (status == "spawned" or status == "dead") then
            setupNeeds()
            isSpawned = true
        end

        if status == "spawned" and wasDead then
            if playerNeeds.thirst < 50.0 then
                changeNeed("thirst", 80.0)
            end

            if playerNeeds.hunger < 50.0 then
                changeNeed("hunger", 80.0)
            end
        end

        wasDead = (status == "dead")

        if isDead then
            setNeed("stress", 0)
        end
    end
)

function setupNeeds()
    local playerNeedsLoad = exports.data:getCharVar("needs")
    playerNeeds = {}

    for key, value in pairs(Config.Needs) do
        local needValue = tonumber(value.default)
        if playerNeedsLoad[key] then
            needValue = tonumber(playerNeedsLoad[key])
        end

        if needValue < value.min then
            needValue = value.min
        elseif needValue > value.max then
            needValue = value.max
        end

        playerNeeds[key] = needValue
        TriggerEvent("needs:needChanged", key, needValue)
    end

    TriggerServerEvent("needs:update", playerNeeds)
end

function setNeed(need, value)
    if playerNeeds and playerNeeds[need] then
        local needValue = tonumber(value)
        local needData = Config.Needs[need]

        if needValue < needData.min then
            needValue = needData.min
        elseif needValue > needData.max then
            needValue = needData.max
        end

        playerNeeds[need] = needValue
        TriggerEvent("needs:needChanged", need, needValue)
    elseif need == "stamina" then
        RestorePlayerStamina(PlayerId(), tonumber(value))
    end
end

function changeNeed(need, value)
    if playerNeeds and playerNeeds[need] then
        local needValue = playerNeeds[need] + tonumber(value)
        local needData = Config.Needs[need]

        if needValue < needData.min then
            needValue = needData.min
        elseif needValue > needData.max then
            needValue = needData.max
        end

        playerNeeds[need] = needValue
        TriggerEvent("needs:needChanged", need, needValue)
    elseif need == "stamina" then
        RestorePlayerStamina(PlayerId(), tonumber(value))
    end
end

function getNeed(need)
    if playerNeeds and playerNeeds[need] then
        return playerNeeds[need]
    end
    return nil
end

Citizen.CreateThread(
    function()
        while true do
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
            Citizen.Wait(5000)

            for action, timer in pairs(reportTimers) do
                reportTimers[action] = timer - 1

                if reportTimers[action] <= 0 then
                    reportTimers[action] = nil
                end
            end
            if playerNeeds and isSpawned and not isDead then
                for needName, needValue in pairs(playerNeeds) do
                    if needName == "thirst" and needValue <= 0.0 then
                        local playerPed = PlayerPedId()
                        local currentHealth = GetEntityHealth(PlayerPedId())
                        local newHealth = currentHealth - Config.Needs.thirst.healthDamage
                        if newHealth < 0 then
                            newHealth = 0
                        end

                        newHealth = math.floor(newHealth)
                        SetEntityHealth(playerPed, newHealth)

                        if not reportTimers.thirst then
                            reportTimers.thirst = 50
                            exports.notify:display(
                                {
                                    type = "extreme",
                                    title = "Máš žízeň",
                                    text = "Pokud se nenapiješ, brzy omdlíš!",
                                    icon = "fas fa-wine-glass-alt",
                                    length = 10000
                                }
                            )
                        end
                    elseif needName == "hunger" and needValue <= 0.0 then
                        local playerPed = PlayerPedId()
                        local currentHealth = GetEntityHealth(PlayerPedId())
                        local newHealth = currentHealth - Config.Needs.hunger.healthDamage
                        if newHealth < 0 then
                            newHealth = 0
                        end

                        newHealth = math.floor(newHealth)
                        SetEntityHealth(playerPed, newHealth)

                        if not reportTimers.hunger then
                            reportTimers.hunger = 50
                            exports.notify:display(
                                {
                                    type = "extreme",
                                    title = "Máš hlad",
                                    text = "Pokud se nenajíš, brzy vyhladovíš!",
                                    icon = "fas fa-drumstick-bite",
                                    length = 10000
                                }
                            )
                        end
                    end
                end
                if playerNeeds.drunk > 50.0 then
                    local playerPed = PlayerPedId()
                    if IsPedInAnyVehicle(PlayerPed) or IsPedInAnyVehicle(PlayerPed) == 0 then
                        local vehicle = GetVehiclePedIsIn(PlayerPed, false)
                        if GetPedInVehicleSeat(vehicle, -1) == PlayerPed then
                            local class = GetVehicleClass(vehicle)

                            if class ~= 15 or 16 or 21 or 13 then
                                local eventData = randomEvent()
                                TaskVehicleTempAction(PlayerPed, vehicle, eventData.Int, eventData.Time)
                            end
                        end
                    end
                end
            end
        end
    end
)

function randomEvent()
    math.randomseed(GetGameTimer())

    local choosenEvent = math.random(1, #Config.DrunkVehActions)
    return Config.DrunkVehActions[choosenEvent]
end

RegisterNetEvent("needs:needChanged")
AddEventHandler(
    "needs:needChanged",
    function(need, needValue)
        if need == "drunk" then
            drunkEffect(needValue)
        elseif need == "stress" then
            currentStress = needValue
        end
    end
)

local wasDrunk = false

function drunkEffect(value)
    local anim = "move_m@drunk@verydrunk"

    if value < 60.0 then
        anim = nil
    elseif value >= 60.0 and value < 70.0 then
        anim = "move_m@drunk@slightlydrunk"
    elseif value >= 70.0 and value < 90.0 then
        anim = "move_m@drunk@moderatedrunk"
    elseif value >= 90.0 then
        anim = "move_m@drunk@verydrunk"
    end

    local PlayerPed = PlayerPedId()

    if anim then
        exports.emotes:DisableWalks(true)
        RequestAnimSet(anim)

        while not HasAnimSetLoaded(anim) do
            Citizen.Wait(100)
        end

        SetPedMovementClipset(PlayerPed, anim, true)
        RemoveAnimSet(anim)
    elseif wasDrunk then
        exports.emotes:DisableWalks(false)
        local walk = exports.data:getCharVar("emotes").walk

        if walk and walk == "reset" then
            while not HasAnimSetLoaded(walk) do
                RequestAnimSet(walk)
                Citizen.Wait(1)
            end

            SetPedMovementClipset(PlayerPed, walk, 0.2)
            RemoveAnimSet(walk)
        else
            ResetPedMovementClipset(PlayerPed)
        end
    end

    SetPedMotionBlur(PlayerPed, true)
    SetPedIsDrunk(PlayerPed, true)
    wasDrunk = true
    if wasDrunk then
        SetPedMotionBlur(PlayerPed, false)
        SetPedIsDrunk(PlayerPed, false)
        wasDrunk = false
    end
end
