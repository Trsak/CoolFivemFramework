local isSpawned, isDead = false, false
local inVehicle = false
local inTrunkVehicle
local pCoords = nil
local window = true

local movingSeat = false

local isSeatBeltOn = false

local vehicleDoors = {{
    name = "seat_dside_f",
    seat = -1,
    door = 0,
    openAction = "Otevřít dveře (0)",
    closeAction = "Zavřít dveře (0)",
    useAction = "Nastoupit dveřmi (0)",
    icon = "game-icon game-icon-car-door"
}, {
    name = "seat_pside_f",
    seat = 0,
    door = 1,
    openAction = "Otevřít dveře (1)",
    closeAction = "Zavřít dveře (1)",
    useAction = "Nastoupit dveřmi (1)",
    icon = "game-icon game-icon-car-door"
}, {
    name = "seat_dside_r",
    seat = 1,
    door = 2,
    openAction = "Otevřít dveře (2)",
    closeAction = "Zavřít dveře (2)",
    useAction = "Nastoupit dveřmi (2)",
    icon = "game-icon game-icon-car-door"
}, {
    name = "seat_pside_r",
    seat = 2,
    door = 3,
    openAction = "Otevřít dveře (3)",
    closeAction = "Zavřít dveře (3)",
    useAction = "Nastoupit dveřmi (3)",
    icon = "game-icon game-icon-car-door"
}, {
    name = "bonnet",
    seat = nil,
    door = 4,
    openAction = "Otevřít kapotu",
    closeAction = "Zavřít kapotu",
    icon = "game-icon game-icon-car-door"
}, {
    name = "boot",
    seat = nil,
    door = 5,
    openAction = "Otevřít kufr",
    closeAction = "Zavřít kufr",
    icon = "game-icon game-icon-car-door"
}}

local tires = {{
    bone = "wheel_lf",
    index = 0
}, {
    bone = "wheel_rf",
    index = 1
}, {
    bone = "wheel_lm",
    index = 2
}, {
    bone = "wheel_rm",
    index = 3
}, {
    bone = "wheel_lr",
    index = 4
}, {
    bone = "wheel_rr",
    index = 5
}}

local knifes = {
    ["weapon_dagger"] = true,
    ["weapon_knife"] = true,
    ["weapon_machete"] = true,
    ["weapon_switchblade"] = true
}

Citizen.CreateThread(function()
    exports.chat:addSuggestion("/shuffle", "Přesednout si na druhé sedadlo", {})
    exports.chat:addSuggestion("/presednout", "Přesednout si na druhé sedadlo", {})
    exports.chat:addSuggestion("/hood", "Otevřít/zavřít kapotu", {})
    exports.chat:addSuggestion("/kapota", "Otevřít/zavřít kapotu", {})
    exports.chat:addSuggestion("/trunk", "Otevřít/zavřít kufr", {})
    exports.chat:addSuggestion("/kufr", "Otevřít/zavřít kufr", {})
    exports.chat:addSuggestion("/engine", "Zapne/vypne motor", {})
    exports.chat:addSuggestion("/motor", "Zapne/vypne motor", {})
    exports.chat:addSuggestion("/anchor", "Spustí/Vytáhne kotvu", {})
    exports.chat:addSuggestion("/kotva", "Spustí/Vytáhne kotvu", {})
    exports.chat:addSuggestion("/window", "Otevře/Zavře okénko ve vozidle", {})
    exports.chat:addSuggestion("/okno", "Otevře/Zavře okénko ve vozidle", {})
    exports.chat:addSuggestion("/flipcar", "Otočí převrácené vozidlo", {})

    for _, vehicleDoor in each(vehicleDoors) do
        local actions = {
            openDoor = {
                cb = function(vehicleDoorData)
                    actionVehicleDoor(true, vehicleDoorData.entity, vehicleDoorData.door, vehicleDoorData.seat)
                end,
                icon = vehicleDoor.icon,
                label = vehicleDoor.openAction,
                cbData = vehicleDoor
            },
            closeDoor = {
                cb = function(vehicleDoorData)
                    actionVehicleDoor(false, vehicleDoorData.entity, vehicleDoorData.door, vehicleDoorData.seat)
                end,
                icon = vehicleDoor.icon,
                label = vehicleDoor.closeAction,
                cbData = vehicleDoor
            }
        }

        if vehicleDoor.useAction ~= nil then
            actions["useDoor"] = {
                cb = function(vehicleDoorData)
                    useVehicleDoor(vehicleDoorData.entity, vehicleDoorData.seat)
                end,
                icon = "game-icon game-icon-car-seat",
                label = vehicleDoor.useAction,
                cbData = vehicleDoor
            }
        end

        if vehicleDoor.door == 5 then
            actions["useTrunk"] = {
                cb = function(vehicleDoorData)
                    exports.rp:openTrunk(vehicleDoorData.entity)
                end,
                icon = "fas fa-box",
                label = "Použít kufr",
                cbData = vehicleDoor
            }
            actions["hideInTrunk"] = {
                cb = function(vehicleDoorData)
                    hideInTrunk(vehicleDoorData.entity)
                end,
                icon = "game-icon game-icon-city-car",
                label = "Schovat se do kufru",
                cbData = vehicleDoor
            }
        end

        exports["target"]:AddTargetVehicleBone({vehicleDoor.name}, {
            actions = actions,
            distance = 2.0
        })
        for i, data in each(tires) do
            exports.target:AddTargetVehicleBone({data.bone}, {
                actions = {
                    useKnife = {
                        cb = function(vehicleTireData)
                            local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
                            local inventoryWeapon = exports.inventory:getWeaponFromHash(weaponHash)
                            if not inventoryWeapon then
                                inventoryWeapon = exports.inventory:getWeaponFromHash(weaponHash % 0x100000000)
                            end
                            if inventoryWeapon and knifes[inventoryWeapon.name] then
                                if not IsVehicleTyreBurst(vehicleTireData.entity, vehicleTireData.Index, false) then
                                    exports.progressbar:startProgressBar({
                                        Duration = 5000,
                                        Label = "Propícháváš gumu..",
                                        CanBeDead = false,
                                        CanCancel = true,
                                        DisableControls = {
                                            Movement = true,
                                            CarMovement = true,
                                            Mouse = false,
                                            Combat = true
                                        },
                                        Animation = {
                                            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                            anim = "machinic_loop_mechandplayer"
                                        }
                                    }, function(finished)
                                        if finished then

                                            if #(GetEntityCoords(PlayerPedId()) -
                                                GetEntityCoords(vehicleTireData.entity)) <= 5.0 then
                                                TriggerServerEvent("vehiclecontrol:destroyTire",
                                                    NetworkGetNetworkIdFromEntity(vehicleTireData.entity),
                                                    vehicleTireData.Index)
                                            else
                                                exports.notify:display({
                                                    type = "error",
                                                    title = "Chyba",
                                                    text = "Vozidlo se vzdálilo!",
                                                    icon = "fas fa-car",
                                                    length = 3000
                                                })
                                            end
                                        end
                                    end)
                                else
                                    exports.notify:display({
                                        type = "error",
                                        title = "Chyba",
                                        text = "Guma už propíchnutá je!",
                                        icon = "fas fa-car",
                                        length = 3000
                                    })
                                end
                            else
                                exports.notify:display({
                                    type = "error",
                                    title = "Chyba",
                                    text = "Nemáš jak propíchnout gumu!",
                                    icon = "fas fa-car",
                                    length = 3000
                                })
                            end
                        end,
                        icon = "fas fa-crosshairs",
                        label = "Propíchnout gumu",
                        cbData = {
                            Index = data.index
                        }
                    }
                },
                distance = 1.0,
                weapons = knifes
            })
        end
    end

    while not exports.data:isUserLoaded() do
        Citizen.Wait(100)
    end

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("vehicle:seatBeltStatus")
AddEventHandler("vehicle:seatBeltStatus", function(status)
    isSeatBeltOn = status
end)

function useVehicleDoor(vehicle, seat)
    if GetVehicleDoorLockStatus(vehicle) > 1 then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Vozidlo je zamčené!",
            icon = "fas fa-car",
            length = 2500
        })
        return
    end

    TaskEnterVehicle(PlayerPedId(), vehicle, 2500.0, seat, 1.0, 1, 0)
end

function hideInTrunk(vehicle)
    if not (GetVehicleDoorAngleRatio(vehicle, 5) > 0.0) then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Kufr není otevřený!",
            icon = "fas fa-car",
            length = 2500
        })
        return
    end

    local playerPed = PlayerPedId()
    if not IsEntityAttached(playerPed) then
        SetEntityVisible(PlayerPedId(), true, false)
        AttachEntityToEntity(playerPed, vehicle, -1, 0.0, -2.1, 0.35, 0.0, 0.0, 0.0, false, false, false, false, 20,
            true)
        loadDict("timetable@floyd@cryingonbed@base")
        TaskPlayAnim(playerPed, "timetable@floyd@cryingonbed@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

        Wait(50)

        inTrunkVehicle = vehicle

        Wait(1500)
    end
end

Citizen.CreateThread(function()
    local wasInTrunk = false

    while true do
        if inTrunkVehicle ~= nil then
            if not wasInTrunk then
                exports.key_hints:displayBottomHint({
                    name = "trunk_leave",
                    key = "~INPUT_FRONTEND_RRIGHT~",
                    text = "Vylézt z kufru"
                })
                exports.key_hints:displayBottomHint({
                    name = "trunk_open",
                    key = "~INPUT_PICKUP~",
                    text = "Otevřít kufr"
                })
                exports.key_hints:displayBottomHint({
                    name = "trunk_close",
                    key = "~INPUT_RELOAD~",
                    text = "Zabouchnout kufr"
                })
                wasInTrunk = true
            end

            if IsControlJustReleased(0, 194) then
                if GetVehicleDoorAngleRatio(inTrunkVehicle, 5) <= 0.0 then
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Kufr není otevřený!",
                        icon = "fas fa-car",
                        length = 2500
                    })
                elseif LocalPlayer.state.isCuffed then
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Jsi spoutaný!",
                        icon = "fas fa-car",
                        length = 2500
                    })
                else
                    SetEntityCollision(PlayerPedId(), true, true)

                    Wait(50)

                    inTrunkVehicle = nil
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    ClearPedTasks(PlayerPedId())
                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -1.2, -0.75))

                    Wait(50)
                    SetEntityCollision(PlayerPedId(), true, true)
                end
            elseif IsControlJustReleased(0, 38) then
                if LocalPlayer.state.isCuffed then
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Jsi spoutaný!",
                        icon = "fas fa-car",
                        length = 2500
                    })
                elseif GetVehicleDoorAngleRatio(inTrunkVehicle, 5) <= 0.0 then
                    SetCarBootOpen(inTrunkVehicle)
                    SetEntityVisible(PlayerPedId(), true, false)
                end
            elseif IsControlJustReleased(0, 45) then
                if LocalPlayer.state.isCuffed then
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Jsi spoutaný!",
                        icon = "fas fa-car",
                        length = 2500
                    })
                elseif GetVehicleDoorAngleRatio(inTrunkVehicle, 5) > 0.0 then
                    SetVehicleDoorShut(inTrunkVehicle, 5)
                    Wait(100)
                    SetEntityVisible(PlayerPedId(), false, false)
                end
            end
        elseif wasInTrunk then
            exports.key_hints:hideBottomHint({
                name = "trunk_leave"
            })
            exports.key_hints:hideBottomHint({
                name = "trunk_open"
            })
            exports.key_hints:hideBottomHint({
                name = "trunk_close"
            })
            wasInTrunk = false
        end

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if inTrunkVehicle ~= nil then
            if IsEntityVisible(PlayerPedId()) and GetVehicleDoorAngleRatio(inTrunkVehicle, 5) <= 0.0 then
                SetEntityVisible(PlayerPedId(), false, false)
            elseif not IsEntityVisible(PlayerPedId()) and GetVehicleDoorAngleRatio(inTrunkVehicle, 5) > 0.0 then
                SetEntityVisible(PlayerPedId(), true, false)
            end

            if not IsEntityPlayingAnim(PlayerPedId(), "timetable@floyd@cryingonbed@base", "base", 3) then
                TaskPlayAnim(PlayerPedId(), "timetable@floyd@cryingonbed@base", "base", 8.0, -8.0, -1, 1, 0, false,
                    false, false)
            end
        end

        Citizen.Wait(200)
    end
end)

function loadDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
        RequestAnimDict(dict)
    end
end

function actionVehicleDoor(openDoor, vehicle, door, seat)
    if GetVehicleDoorLockStatus(vehicle) > 1 then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Vozidlo je zamčené!",
            icon = "fas fa-car",
            length = 2500
        })
        return
    end

    if openDoor and GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
        return
    end

    if not openDoor and not (GetVehicleDoorAngleRatio(vehicle, door) > 0.0) then
        return
    end

    if not openDoor then
        SetVehicleDoorShut(vehicle, door, false)
    else
        if seat then
            TaskOpenVehicleDoor(PlayerPedId(), vehicle, 2500.0, seat, 1.0)
        else
            SetVehicleDoorOpen(vehicle, door, false, false)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isSpawned and not isDead then
            pCoords = GetEntityCoords(PlayerPedId())
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                inVehicle = true
            else
                inVehicle = false
                movingSeat = false
            end
        end
    end
end)

function getVehicleInDirection(range)
    local coordA = GetEntityCoords(PlayerPedId(), 1)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, range, 0.0)

    local rayHandle = CastRayPointToPoint(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 10, PlayerPedId(),
        0)
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isSpawned and not isDead and inVehicle then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if DoesEntityExist(veh) and not IsEntityDead(veh) then
                local model = GetEntityModel(veh)
                if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and
                    not IsThisModelABike(model) and not IsThisModelABicycle(model) and IsEntityInAir(veh) then
                    DisableControlAction(0, 59) -- leaning left/right
                    DisableControlAction(0, 60) -- leaning up/down
                end

                if IsControlJustReleased(0, 297) and inVehicle then
                    local engineon = GetIsVehicleEngineRunning(veh)
                    SetVehicleEngineOn(veh, not engineon, false, true)
                end

                if GetPedInVehicleSeat(veh) == PlayerPedId() and not movingSeat then
                    if GetIsTaskActive(PlayerPedId(), 165) then
                        SetPedIntoVehicle(PlayerPedId(), veh, 0)
                    end
                end
            end
        end
    end
end)

RegisterCommand("flipcar", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local inDirection = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
        local rayHandle = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
        local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
        if hit == 1 and GetEntityType(entityHit) == 2 then
            veh = entityHit
        end
    end
    if IsEntityAVehicle(veh) and DoesEntityExist(veh) then
        SetVehicleOnGroundProperly(veh)
    end
end)

RegisterCommand("motor", function()
    ExecuteCommand("engine")
end)

RegisterCommand("engine", function()
    if inVehicle then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        local engineon = GetIsVehicleEngineRunning(veh)
        SetVehicleEngineOn(veh, not engineon, false, true)
    end
end)

RegisterCommand("presednout", function()
    ExecuteCommand("shuffle")
end)

RegisterCommand("shuffle", function()
    if inVehicle and not isSeatBeltOn then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if GetPedInVehicleSeat(veh, 0) == PlayerPedId() then
            SetPedConfigFlag(PlayerPedId(), 184, false)
            movingSeat = true
            Citizen.Wait(3000)
            movingSeat = false
            SetPedConfigFlag(PlayerPedId(), 184, true)
        else
            TaskShuffleToNextVehicleSeat(PlayerPedId(), veh)
        end
    end
end)

RegisterCommand("kapota", function()
    ExecuteCommand("hood")
end)

RegisterCommand("hood", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local isInVehicle = true

    if not DoesEntityExist(veh) then
        isInVehicle = false
        veh = getVehicleInDirection(2.0)

        if not DoesEntityExist(veh) then
            veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, 0, 70)
        end
    elseif not (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) and not (GetPedInVehicleSeat(veh, 0) == PlayerPedId()) then
        return
    end

    if veh ~= nil and DoesEntityExist(veh) then
        if GetVehicleDoorLockStatus(veh) > 1 then
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Vozidlo je zamčené!",
                icon = "fas fa-car",
                length = 2500
            })
            return
        end

        local plcBone = GetEntityBoneIndexByName(veh, vehicleDoors[5].name)
        local plcPos = GetWorldPositionOfEntityBone(veh, plcBone)
        if isInVehicle or #(pCoords - plcPos) < 2.5 then
            if GetVehicleDoorAngleRatio(veh, 4) > 0.0 then
                SetVehicleDoorShut(veh, 4, false)
            else
                SetVehicleDoorOpen(veh, 4, false, false)
            end
        else
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Jsi daleko od kapoty, nebo ji vozidlo nemá",
                icon = "fas fa-car",
                length = 3000
            })
        end
    else
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Není u tebe žádné vozidlo!",
            icon = "fas fa-car",
            length = 3000
        })
    end
end)

RegisterCommand("kufr", function()
    ExecuteCommand("trunk")
end)

RegisterCommand("trunk", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local isInVehicle = true

    if not DoesEntityExist(veh) then
        isInVehicle = false
        veh = getVehicleInDirection(2.0)

        if not DoesEntityExist(veh) then
            veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, 0, 70)
        end
    elseif not (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) and not (GetPedInVehicleSeat(veh, 0) == PlayerPedId()) then
        return
    end

    if veh ~= nil and DoesEntityExist(veh) then
        if GetVehicleDoorLockStatus(veh) > 1 then
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Vozidlo je zamčené!",
                icon = "fas fa-car",
                length = 2500
            })
            return
        end

        local plcBone = GetEntityBoneIndexByName(veh, vehicleDoors[6].name)
        local plcPos = GetWorldPositionOfEntityBone(veh, plcBone)
        if isInVehicle or #(pCoords - plcPos) < 2.5 then
            if GetVehicleDoorAngleRatio(veh, 5) > 0.0 then
                SetVehicleDoorShut(veh, 5, false)
            else
                SetVehicleDoorOpen(veh, 5, false, false)
            end
        else
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Jsi daleko od kufru, nebo jej vozidlo nemá!",
                icon = "fas fa-car",
                length = 3000
            })
        end
    else
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Není u tebe žádné vozidlo!",
            icon = "fas fa-car",
            length = 3000
        })
    end
end)

RegisterCommand("kotva", function()
    toggleAnchor()
end)

RegisterCommand("anchor", function()
    toggleAnchor()
end)

function toggleAnchor()
    if IsPedInAnyBoat(PlayerPedId()) then
        local boat = GetVehiclePedIsIn(PlayerPedId(), true)

        if IsBoatAnchoredAndFrozen(boat) then
            SetBoatAnchor(boat, false)
            exports.notify:display({
                type = "info",
                title = "Úspěch",
                text = "Ukotvnení bylo zrušeno",
                icon = "game-icon game-icon-anchor",
                length = 2500
            })
        else
            if CanAnchorBoatHere(boat) then
                SetBoatFrozenWhenAnchored(boat, true)
                SetBoatAnchor(boat, true)
                exports.notify:display({
                    type = "info",
                    title = "Úspěch",
                    text = "Loď byla ukotvena",
                    icon = "game-icon game-icon-anchor",
                    length = 2500
                })
            else
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Zde nemůžeš kotvit!",
                    icon = "game-icon game-icon-anchor",
                    length = 2500
                })
            end
        end
    end
end

RegisterCommand("window", function()
    toggleWindow()
end)

RegisterCommand("okno", function()
    toggleWindow()
end)

function toggleWindow()
    if inVehicle then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        local seat = nil

        for i = -1, GetVehicleModelNumberOfSeats(GetEntityModel(veh)) do
            if GetPedInVehicleSeat(veh, i) == PlayerPedId() then
                seat = (i + 1)
            end
        end

        if seat ~= nil then
            if window then
                RollDownWindow(veh, seat)
                window = false
            else
                RollUpWindow(veh, seat)
                window = true
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if inVehicle and not isDead and IsControlJustPressed(2, 75) then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local engineOn = GetIsVehicleEngineRunning(veh)

            local checks = 10

            while IsControlPressed(2, 75) do
                checks = checks - 1
                if checks <= 0 then
                    break
                end

                Wait(25)
            end

            if checks <= 0 then
                TaskLeaveVehicle(PlayerPedId(), veh, 256)

                if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                    Wait(50)
                    SetVehicleEngineOn(veh, engineOn == 1 and true or false, true, false)
                end
            end
        end
    end
end)

RegisterNetEvent("vehiclecontrol:destroyTire")
AddEventHandler("vehiclecontrol:destroyTire", function(vehicle, tireIndex)
    local vehicle = NetworkGetEntityFromNetworkId(vehicle)

    if not IsVehicleTyreBurst(vehicle, tireIndex, false) then
        SetVehicleTyreBurst(vehicle, tireIndex, false, 1000.0)
    end
end)
