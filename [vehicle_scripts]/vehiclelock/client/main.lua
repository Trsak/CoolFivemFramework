local isSpawned, isDead = false, false

local lockAnim = {
    dict = "anim@mp_player_intmenu@key_fob@",
    name = "fob_click_fp"
}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
            isDead = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

function getVehicleInDirection(range)
    local playerPed = PlayerPedId()
    local coordA = GetEntityCoords(playerPed, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, range, 0.0)

    local rayHandle =
        StartExpensiveSynchronousShapeTestLosProbe(
        coordA.x,
        coordA.y,
        coordA.z,
        coordB.x,
        coordB.y,
        coordB.z,
        10,
        playerPed,
        0
    )
    local a, b, c, d, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

function toggleVehicleLock(veh)
    local playerPed = PlayerPedId()
    local status = checkLockState(veh)

    if not IsPedInAnyVehicle(playerPed, true) then
        while not HasAnimDictLoaded(lockAnim.dict) do
            RequestAnimDict(lockAnim.dict)
            Citizen.Wait(100)
        end

        TaskPlayAnim(playerPed, lockAnim.dict, lockAnim.name, 8.0, 8.0, -1, 48, 1, false, false, false)
        Citizen.Wait(25)
        while IsEntityPlayingAnim(playerPed, lockAnim.dict, lockAnim.name, 3) do
            Citizen.Wait(100)
        end
        RemoveAnimDict(lockAnim.dict)
    end

    local newStatus = not status
    TriggerServerEvent("vehiclelock:setVehicleLockStatus", VehToNet(veh), newStatus)

    if GetVehicleClass(veh) ~= 13 then
        if newStatus then
            TriggerServerEvent("sound:playSound", "lock", 6.0, GetEntityCoords(veh), nil)
        else
            TriggerServerEvent("sound:playSound", "unlock", 6.0, GetEntityCoords(veh), nil)
        end
    end

    SetVehicleLights(veh, 2)
    Wait(200)
    SetVehicleLights(veh, 0)
    usingKeys = false
end

RegisterNetEvent("vehiclelock:setVehicleLockStatus")
AddEventHandler(
    "vehiclelock:setVehicleLockStatus",
    function(vehNetId, locked)
        
        while not vehNetId or not NetworkDoesEntityExistWithNetworkId(vehNetId) do
            Citizen.Wait(100)
        end

        local vehicle = NetToVeh(vehNetId)
        if locked then
            lockVehicle(vehicle)
        else
            unlockVehicle(vehicle)
        end
    end
)

function lockVehicle(veh)
    local ent = Entity(veh)
    ent.state:set("locked", true, true)

    SetVehicleDoorsLocked(veh, 2)
    SetVehicleDoorsLockedForAllPlayers(veh, true)
    SetVehicleDoorsLockedForPlayer(veh, PlayerId(), true)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        ClearPedTasksImmediately(PlayerPedId())
    end
end

function unlockVehicle(veh)
    local ent = Entity(veh)
    ent.state:set("locked", false, true)

    SetVehicleDoorsLockedForAllPlayers(veh, false)
    SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
    SetVehicleDoorsLocked(veh, 1)
end

function checkLockState(veh)
    local vehEntity = Entity(veh)
    if vehEntity.state.locked == nil then
        return true
    else
        return vehEntity.state.locked
    end
end

function isVehicleLocked(veh)
    local vehEntity = Entity(veh)

    if vehEntity.state.vin then
        return checkLockState(veh)
    end

    return false
end

RegisterCommand(
    "forceunlock",
    function()
        if exports.data:getUserVar("admin") > 1 then
            local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, 0, 23)

            if not DoesEntityExist(veh) then
                veh = getVehicleInDirection(2.0)
            end

            if DoesEntityExist(veh) then
                local status = checkLockState(veh)

                if status then
                    exports.emotes:playEmoteByName("parkingmeter")
                    Citizen.Wait(100)
                    TriggerServerEvent("sound:playSound", "unlock", 6.0, GetEntityCoords(veh), nil)
                    TriggerServerEvent("vehiclelock:setVehicleLockStatus", VehToNet(veh), false)

                    SetVehicleLights(veh, 2)
                    Wait(200)
                    SetVehicleLights(veh, 0)
                else
                    exports.notify:display(
                        {
                            type = "error",
                            title = "Vynucené odemčení",
                            text = "Odemčené vozidlo nelze odemknout",
                            icon = "fas fa-car",
                            length = 3000
                        }
                    )
                end
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Vynucené odemčení",
                        text = "V okolí není žádné vozidlo",
                        icon = "fas fa-car",
                        length = 3000
                    }
                )
            end
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Vynucené odemčení",
                    text = "Jak se sakra odemyká auto bez klíčku?",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end

        exports.emotes:cancelEmote()
    end
)

function tryUnlockVehicle()
    if usingKeys or isDead then
        return
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 or not DoesEntityExist(veh) then
        veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, 0, 23)

        if not DoesEntityExist(veh) then
            veh = getVehicleInDirection(6.0)
        end
    end
    if DoesEntityExist(veh) then
        local actualPlate = exports.data:getVehicleActualPlateNumber(veh)
        if exports.inventory:checkCarKey(actualPlate) or exports.inventory:checkCarKey(removeSpaces(actualPlate)) then
            usingKeys = true
            
            toggleVehicleLock(veh)
        else
            usingKeys = false
        end
    end
end

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName)
        if itemName == "car_keys" then
            tryUnlockVehicle()
        end
    end
)

RegisterCommand(
    "vehicleunlock",
    function()
        tryUnlockVehicle()
    end
)
createNewKeyMapping({command = "vehicleunlock", text = "Odemykání / zamykání vozidla", key = "L"})

function removeSpaces(string)
    local toLower = string:gsub("%s+", "")
    toLower = string.gsub(toLower, "%s+", "")
    return toLower
end
