local timers = {}

AddEventHandler(
    "CEventGunShot",
    function(entities, eventEntity, args)
        if not eventEntity or not DoesEntityExist(eventEntity) then
            return
        end

        if timers.CEventGunShot then
            return
        end

        local distance = #(GetEntityCoords(eventEntity) - GetEntityCoords(PlayerPedId()))

        if distance > 0.01 and distance <= 70.0 then
            changeNeed("stress", 0.5)
            timers.CEventGunShot = true

            Citizen.CreateThread(
                function()
                    Wait(750)
                    timers.CEventGunShot = nil
                end
            )
        end
    end
)

AddEventHandler(
    "CEventOnFire",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end

        if timers.CEventOnFire then
            return
        end

        local distance = #(GetEntityCoords(eventEntity) - GetEntityCoords(PlayerPedId()))

        if distance > 0.01 and distance <= 70.0 then
            changeNeed("stress", 0.5)
            timers.CEventOnFire = true

            Citizen.CreateThread(
                function()
                    Wait(750)
                    timers.CEventOnFire = nil
                end
            )
        end
    end
)

AddEventHandler(
    "CEventRanOverPed",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end

        if timers.CEventRanOverPed then
            return
        end

        local distance = #(GetEntityCoords(eventEntity) - GetEntityCoords(PlayerPedId()))

        if distance > 0.01 and distance <= 70.0 then
            changeNeed("stress", 0.5)
            timers.CEventRanOverPed = true

            Citizen.CreateThread(
                function()
                    Wait(750)
                    timers.CEventRanOverPed = nil
                end
            )
        end
    end
)

AddEventHandler(
    "CEventShocking",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end

        if timers.CEventShocking then
            return
        end

        local distance = #(GetEntityCoords(eventEntity) - GetEntityCoords(PlayerPedId()))

        if distance > 0.01 and distance <= 70.0 then
            changeNeed("stress", 0.5)
            timers.CEventShocking = true

            Citizen.CreateThread(
                function()
                    Wait(750)
                    timers.CEventShocking = nil
                end
            )
        end
    end
)

AddEventHandler(
    "CEventShockingCarCrash",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end

        if eventEntity == PlayerId() and not timers.CEventShockingCarCrash then
            changeNeed("stress", 0.5)

            timers.CEventShockingCarCrash = true

            Citizen.CreateThread(
                function()
                    Wait(750)
                    timers.CEventShockingCarCrash = nil
                end
            )
        end
    end
)

Citizen.CreateThread(
    function()
        while not isSpawned do
            Citizen.Wait(1000)
        end

        while true do
            Citizen.Wait(1000)

            if not isDead and isSpawned then
                local ped = PlayerPedId()
                local totalChange = 0

                if IsPedShooting(ped) then
                    -- Shooting
                    totalChange = totalChange + 0.95
                end

                local isAlerted = GetPedAlertness(ped)
                if isAlerted > 0 then
                    -- Ped is alerted because of some events
                    totalChange = totalChange + (0.95 * isAlerted)
                end

                if IsPedInMeleeCombat(ped) then
                    -- Melee combat
                    totalChange = totalChange + 0.5
                end

                local currentVehicle = GetVehiclePedIsIn(ped, false)
                if currentVehicle ~= 0 then
                    local vehicleClass = GetVehicleClass(currentVehicle)
                    if vehicleClass ~= 14 and vehicleClass ~= 15 and vehicleClass ~= 16 then
                        local vehicleSpeed = math.ceil(GetEntitySpeed(currentVehicle) * 2.237)
                        if vehicleSpeed > 110 then
                            totalChange = totalChange + (0.025 * (3.0 + (vehicleSpeed / 100)))
                        end
                    end
                end

                if totalChange ~= 0.0 then
                    currentStress = currentStress + totalChange
                    changeNeed("stress", totalChange)
                end

                if currentStress >= 20.0 then
                    local shake = 0.0
                    local shakeType = "MEDIUM_EXPLOSION_SHAKE"

                    if currentStress < 20.0 then
                        shake = 0.0
                    elseif currentStress < 30.0 then
                        shake = 0.005
                    elseif currentStress < 40.0 then
                        shake = 0.01
                    elseif currentStress < 50.0 then
                        shake = 0.015
                    elseif currentStress < 60.0 then
                        shake = 0.02
                    elseif currentStress < 70.0 then
                        shake = 0.025
                    elseif currentStress < 75.0 then
                        shake = 0.03
                    elseif currentStress < 80.0 then
                        shake = 0.035
                    elseif currentStress < 85.0 then
                        shake = 0.04
                    elseif currentStress < 90.0 then
                        shake = 0.05
                    elseif currentStress < 95.0 then
                        shake = 0.06
                    else
                        shake = 0.07
                    end

                    if shake > 0 then
                        ShakeGameplayCam(shakeType, shake)
                    end
                end
            end
        end
    end
)
