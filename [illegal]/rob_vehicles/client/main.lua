local cops = 0
local isSpawned, isDead, isDuty = false, false, false
local isCop = false
local pCoords = nil

local stealing = false 

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then 
        isSpawned = true
        isDead = (status == "dead")
        isDuty = exports.data:getCharVar("duty")
        isCop = (Config.ignoreJobType[exports.base_jobs:getJobVar(exports.data:getCharVar("job"), "type")])
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false 
        elseif status == "spawned" or status == "dead" then  
            isSpawned = true
            isDead = (status == "dead")

            if isCop == nil then 
                isDuty = exports.data:getCharVar("duty")
                isCop = (Config.ignoreJobType[exports.base_jobs:getJobVar(exports.data:getCharVar("job"), "type")])
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated",
    function(job, grade, duty)
        isDuty = duty
        isCop = (Config.ignoreJobType[exports.base_jobs:getJobVar(job, "type")])
    end
)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(2000)
        if isSpawned and not isDead then 
            pCoords = GetEntityCoords(GetPlayerPed(-1), false)
        end
    end
end)

-- local lastPed = nil 
-- Citizen.CreateThread(function()
--     while true do 
--         Citizen.Wait(500)
--         if isSpawned and not isDead and not stealing and not isCop then 
--             if IsPlayerFreeAiming(PlayerId()) and not stealing and IsPedArmed(PlayerPedId(), 7) then 
--                 local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
--                 if targetPed ~= 0 and lastPed ~= targetPed and not IsPedDeadOrDying(targetPed, 1) and not IsPedAPlayer(targetPed) then 
--                     stealing = true 
--                     lastPed = targetPed
--                     local coords = GetEntityCoords(PlayerPedId())
--                     local targetCoords = GetEntityCoords(lastPed)
--                     if GetDistanceBetweenCoords(coords, targetCoords, true) < 10.0 then 
--                         local inVeh = GetVehiclePedIsIn(lastPed, false) 
--                         if inVeh ~= 0 then 
--                             local random, action = math.random(100), ""
--                             if GetEntitySpeed(veh) > 10.0 then random = 60 end 

--                             if random >= 0 and random < 25 then 
--                                 action = "leave" 
--                                 SetVehicleCanBeUsedByFleeingPeds(inVeh, false)
--                                 TaskLeaveVehicle(lastPed, inVeh, 256)
--                                 Citizen.Wait(2000)
--                                 TaskReactAndFleePed(lastPed, PlayerPedId())
--                                 SetVehicleEngineOn(inVeh, false, true, false)
--                             elseif random >= 25 and random < 45 then 
--                                 action = "locked"
--                                 SetVehicleDoorsLocked(inVeh, true)
--                                 SetVehicleDoorsLockedForAllPlayers(inVeh, true)
--                             elseif random >= 45 and random < 60 then
--                                 action = "leaveRunning"
--                                 SetVehicleCanBeUsedByFleeingPeds(inVeh, false) 
--                                 TaskLeaveVehicle(lastPed, inVeh, 256)
--                                 Citizen.Wait(2000)
--                                 TaskReactAndFleePed(lastPed, PlayerPedId())
--                                 SetVehicleEngineOn(inVeh, true, true, false)
--                             elseif random >= 60 and random < 80 then 
--                                 action = "driveAway" 
--                                 TaskReactAndFleePed(lastPed, PlayerPedId())
--                             elseif random >= 80 and random < 100 then 
--                                 action = "shoot" 
--                                 GiveWeaponToPed(lastPed, GetHashKey("WEAPON_PISTOL"), 10, false, true)
--                                 TaskLeaveVehicle(lastPed, inVeh, 256)
--                                 Citizen.Wait(2000)
--                                 TaskShootAtEntity(lastPed, PlayerPedId(), 5000, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
--                             end
--                             SetBlockingOfNonTemporaryEvents(lastPed, true)

--                             print(action)
--                         end
--                     end

--                     stealing = false 
--                 end
--             end
--         end
--     end
-- end)

local hotwiring, dword = nil, false   
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(500)
        if isSpawned and not isDead and hotwiring == nil and not dword then 
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 and hotwiring ~= veh and GetPedInVehicleSeat(veh, -1) == PlayerPedId() then 
                if GetVehicleClass(veh) ~= 16 and GetVehicleClass(veh) ~= 15 and GetVehicleClass(veh) ~= 13 then 
                    local spz = exports.data:getVehicleActualPlateNumber(veh)
                    if Config.ignoreLicense[spz] == nil then 
                        local hasKeys = exports.inventory:checkCarKey(spz)
                        if (IsVehicleNeedsToBeHotwired(veh) and hasKeys) then 
                            SetVehicleNeedsToBeHotwired(veh, false)
                        end
                        if (IsVehicleNeedsToBeHotwired(veh) and not hasKeys) or (not GetIsVehicleEngineRunning(veh) and not hasKeys) and GetVehicleEngineHealth(veh) >= 101.0 then 
                            hotwiring = veh
                            dword = true 
                            
                            local plcBone = GetEntityBoneIndexByName(veh, "seat_dside_f")
                            if GetVehicleClass(veh) == 8 then plcBone = GetEntityBoneIndexByName(veh, "handlebars") end
                            local plcPos = GetWorldPositionOfEntityBone(veh, plcBone)
                            Citizen.Wait(500)
                            while hotwiring do 
                                Citizen.Wait(1)
                                if GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then 
                                    hotwiring = nil 
                                    dword = false 
                                end
                                plcPos = GetWorldPositionOfEntityBone(veh, plcBone)
                                DrawText3D(plcPos.x, plcPos.y, plcPos.z, "~y~[MEZERNIK]~w~ NASTARTOVAT KABELY")
                                if IsControlJustReleased(1, 22) then 
                                    hotwire(1)
                                    break
                                end
                            end
                        else 
                            hotwiring = nil 
                        end
                    end
                end
            end
        end 
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(100)

        if isSpawned and not isDead then 
            while hotwiring ~= nil do 
                Citizen.Wait(250)
                SetVehicleNeedsToBeHotwired(hotwiring, true)
                SetVehicleEngineOn(hotwiring, false, true, false)

                if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then 
                    hotwiring = nil 
                    dword = false 
                end
            end
        end
    end
end)


function hotwire(try)
    if GetVehicleEngineHealth(hotwiring) >= 101.0 then 
        TriggerEvent(
            "mythic_progbar:client:progress",
            {
                name = "hotwire",
                duration = 8000,
                label = "Pokoušíš se nastartovat s kabely [" .. try .. "]",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true
                }
            },
            function(status)
                if not status then
                    local chance = math.random(10)
                    if chance >= 8 then 
                        hotwire((try + 1))
                    else 
                        local veh = hotwiring
                        hotwiring = nil 
                        SetVehicleNeedsToBeHotwired(veh, false)
                        SetVehicleEngineOn(veh, true, false, false)
                        Citizen.SetTimeout(2000, function()
                            dword = false 
                        end)
                    end
                else 
                    SetVehicleNeedsToBeHotwired(hotwiring, true)
                    SetVehicleEngineOn(hotwiring, false, true, false)
                    hotwiring = nil 
                    dword = false 
                end
            end
        )
    else 
        hotwiring = nil 
        Citizen.SetTimeout(2000, function()
            dword = false 
        end)
    end
end