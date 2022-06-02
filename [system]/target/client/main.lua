local Objects = {}
local PedRelationshipGroups = {}
local Zones = {}
local VehicleBones = {}

local success = false
local isActive = false
local disabled = false
local disabledTimer

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

Citizen.CreateThread(function()
    createNewKeyMapping({
        command = "+playerTarget",
        text = "Cílená akce",
        key = "LMENU"
    })
    RegisterCommand("+playerTarget", playerTargetEnable, false)
    RegisterCommand("-playerTarget", playerTargetDisable, false)
    TriggerEvent("chat:removeSuggestion", "/+playerTarget")
    TriggerEvent("chat:removeSuggestion", "/-playerTarget")

    while true do
        Citizen.Wait(0)
        if targetActive then
            DisablePlayerFiring(PlayerPedId(), true)
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 25, true) -- disable aim
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
        end
    end
end)

function DisableTarget(toggle)
    disabled = toggle

    if disabled then
        playerTargetDisable()
        closeTarget()
    end
end

function playerTargetEnable()
    if not IsPauseMenuActive() then
        if success or disabled or not isSpawned or isDead then
            return
        end

        isActive = false

        if targetActive then
            playerTargetDisable()
        end

        local playerPed = PlayerPedId()
        if IsPlayerFreeAiming(PlayerId()) then
            return
        end

        targetActive = true

        SendNUIMessage({
            response = "openTarget"
        })

        Citizen.CreateThread(function()
            while targetActive do
                Citizen.Wait(200)
                if IsPlayerFreeAiming(PlayerId()) or disabledTimer or disabled or not isSpawned or isDead then
                    success = false
                    SendNUIMessage({
                        response = "leftTarget"
                    })
                    playerTargetDisable()
                    closeTarget()
                end
            end
        end)

        while targetActive do
            local plyCoords = GetEntityCoords(playerPed)
            local hit, entity, entityType, coords = GetEntityPlayerIsLookingAt(20.0, 0.6, 286, playerPed)

            if hit == 1 then
                if entityType ~= 0 then
                    if entityType == 2 then
                        local closestBone, closestBoneDistance

                        for boneName, boneData in pairs(VehicleBones) do
                            local boneIndex = GetEntityBoneIndexByName(entity, boneName)
                            local bonePos = GetWorldPositionOfEntityBone(entity, boneIndex)
                            local boneDistance = #(bonePos - plyCoords)

                            if boneDistance <= boneData.distance and
                                (closestBoneDistance == nil or closestBoneDistance > boneDistance) then
                                closestBone = boneName
                                closestBoneDistance = boneDistance
                            end
                        end

                        if closestBone ~= nil then
                            local boneName = closestBone
                            local boneData = VehicleBones[boneName]
                            local hasWeapon = true

                            local boneIndex = GetEntityBoneIndexByName(entity, boneName)
                            local bonePos = GetWorldPositionOfEntityBone(entity, boneIndex)
                            if boneData.weapons then
                                hasWeapon = hasPlayerWeapon(boneData.weapons)
                            end
                            if #(bonePos - coords) <= boneData.distance and
                                ((not boneData.netId or boneData.netId == NetworkGetNetworkIdFromEntity(entity)) and
                                    hasWeapon) then
                                success = true

                                SendNUIMessage({
                                    response = "validTarget",
                                    entity = entity,
                                    actions = boneData.actions,
                                    index = boneName,
                                    type = "bone"
                                })

                                while success and targetActive and not disabled do
                                    plyCoords = GetEntityCoords(playerPed)
                                    hit, entity, entityType, coords =
                                        GetEntityPlayerIsLookingAt(20.0, 0.6, 286, playerPed)

                                    if hit == 1 and entityType == 2 then
                                        if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                            isActive = true
                                            SetNuiFocus(true, true)
                                            SetCursorLocation(0.5, 0.5)
                                        end

                                        local newClosestBone, newClosestBoneDistance
                                        for boneNameNew, boneDataNew in pairs(VehicleBones) do
                                            local boneIndexNew = GetEntityBoneIndexByName(entity, boneNameNew)
                                            local bonePosNew = GetWorldPositionOfEntityBone(entity, boneIndexNew)
                                            local boneDistance = #(bonePosNew - plyCoords)

                                            if boneDistance <= boneDataNew.distance and
                                                (newClosestBoneDistance == nil or newClosestBoneDistance > boneDistance) then
                                                newClosestBone = boneNameNew
                                                newClosestBoneDistance = boneDistance
                                            end
                                        end

                                        if boneName ~= newClosestBone then
                                            success = false
                                            break
                                        end

                                        boneIndex = GetEntityBoneIndexByName(entity, boneName)
                                        bonePos = GetWorldPositionOfEntityBone(entity, boneIndex)
                                        if hit ~= 1 or entityType ~= 2 or #(bonePos - coords) > boneData.distance then
                                            success = false
                                            break
                                        end
                                    else
                                        success = false
                                        break
                                    end

                                    Citizen.Wait(1)
                                end

                                SendNUIMessage({
                                    response = "leftTarget"
                                })
                            end
                        end
                    else
                        local entityModel = GetEntityModel(entity)

                        if entityType == 1 then
                            for pedRelationshipGroup, objectData in pairs(PedRelationshipGroups) do
                                if (pedRelationshipGroup == GetPedRelationshipGroupHash(entity) and
                                    (objectData.id == nil or objectData.id == entity)) then
                                    if #(plyCoords - coords) <= objectData.distance then
                                        success = true

                                        SendNUIMessage({
                                            response = "validTarget",
                                            entity = entity,
                                            actions = objectData.actions,
                                            index = pedRelationshipGroup,
                                            type = "relationship"
                                        })
                                        while success and targetActive and not disabled do
                                            local plyCoords = GetEntityCoords(playerPed)
                                            local hit, entity, entityType, coords =
                                                GetEntityPlayerIsLookingAt(20.0, 0.6, 286, playerPed)

                                            if hit == 1 and entityType ~= 0 then
                                                if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                                    isActive = true
                                                    SetNuiFocus(true, true)
                                                    SetCursorLocation(0.5, 0.5)
                                                end

                                                if hit ~= 1 or pedRelationshipGroup ~=
                                                    GetPedRelationshipGroupHash(entity) or #(plyCoords - coords) >
                                                    objectData.distance then
                                                    success = false
                                                    break
                                                end
                                            else
                                                success = false
                                                break
                                            end

                                            Citizen.Wait(1)
                                        end
                                        SendNUIMessage({
                                            response = "leftTarget"
                                        })
                                    end
                                end
                            end
                        end

                        for objectModel, objectData in pairs(Objects) do
                            if (objectModel == entityModel and (not objectData.id or objectData.id == entity)) then
                                if not objectData.netId or NetworkGetNetworkIdFromEntity(entity) == objectData.netId then
                                    if #(plyCoords - coords) <= objectData.distance then
                                        if not objectData.networked or NetworkGetEntityIsNetworked(entity) then
                                            success = true

                                            SendNUIMessage({
                                                response = "validTarget",
                                                entity = entity,
                                                actions = objectData.actions,
                                                index = objectModel,
                                                type = "object"
                                            })
                                            while success and targetActive and not disabled do
                                                local plyCoords = GetEntityCoords(playerPed)
                                                local hit, entity, entityType, coords =
                                                    GetEntityPlayerIsLookingAt(20.0, 0.6, 286, playerPed)

                                                if hit == 1 and entityType ~= 0 then
                                                    local entityModel = GetEntityModel(entity)

                                                    if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                                        isActive = true
                                                        SetNuiFocus(true, true)
                                                        SetCursorLocation(0.5, 0.5)
                                                    end

                                                    if hit ~= 1 or objectModel ~= entityModel or #(plyCoords - coords) >
                                                        objectData.distance then
                                                        success = false
                                                        break
                                                    end
                                                else
                                                    success = false
                                                    break
                                                end

                                                Citizen.Wait(1)
                                            end
                                            SendNUIMessage({
                                                response = "leftTarget"
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for _, zone in pairs(Zones) do
                if Zones[_]:isPointInside(coords) or (hit == 0 and Zones[_]:isPointInside(plyCoords)) then
                    if #(plyCoords - Zones[_].center) <= zone.targetoptions.distance then
                        success = true

                        SendNUIMessage({
                            response = "validTarget",
                            actions = zone.actions,
                            index = _,
                            type = "zone"
                        })
                        while success and targetActive and not disabled do
                            local plyCoords = GetEntityCoords(GetPlayerPed(-1))
                            local hit, coords, entity = RayCastGamePlayCamera(20.0)

                            if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                isActive = true
                                SetNuiFocus(true, true)
                                SetCursorLocation(0.5, 0.5)
                            end

                            if not (Zones[_]:isPointInside(coords) or (hit == 0 and Zones[_]:isPointInside(plyCoords))) and
                                #(plyCoords - Zones[_].center) > zone.targetoptions.distance then
                                success = false
                                break
                            end

                            Citizen.Wait(1)
                        end
                        SendNUIMessage({
                            response = "leftTarget"
                        })
                    end
                end
            end

            Citizen.Wait(250)
        end
    end

    success = false
end

function playerTargetDisable()
    if isActive then
        return
    end

    targetActive = false

    SendNUIMessage({
        response = "closeTarget"
    })
end

RegisterNUICallback("selectTarget", function(data, cb)
    SetNuiFocus(false, false)

    success = false
    targetActive = false
    disabledTimer = 250

    if data.type == "object" then
        local cbData = Objects[data.index]["actions"][data.action].cbData
        if cbData == nil then
            cbData = {}
        end

        cbData["entity"] = data.entity
        Objects[data.index]["actions"][data.action].cb(cbData)
    elseif data.type == "relationship" then
        local cbData = PedRelationshipGroups[data.index]["actions"][data.action].cbData
        if cbData == nil then
            cbData = {}
        end

        cbData["entity"] = data.entity
        PedRelationshipGroups[data.index]["actions"][data.action].cb(cbData)
    elseif data.type == "zone" then
        local cbData = Zones[data.index]["actions"][data.action].cbData
        if cbData == nil then
            cbData = {}
        end

        Zones[data.index]["actions"][data.action].cb(cbData)
    elseif data.type == "bone" then
        local cbData = VehicleBones[data.index]["actions"][data.action].cbData
        if cbData == nil then
            cbData = {}
        end

        cbData["entity"] = data.entity
        VehicleBones[data.index]["actions"][data.action].cb(cbData)
    end

    cb("done")
end)

RegisterNUICallback("closeTarget", function(data, cb)
    closeTarget()
    cb("ok")
end)

function closeTarget()
    SetNuiFocus(false, false)
    success = false
    targetActive = false
end

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RayCast(origin, target, options, ignoreEntity, radius)
    local handle = StartShapeTestSweptSphere(origin.x, origin.y, origin.z, target.x, target.y, target.z, radius,
        options, ignoreEntity, 0)
    return GetShapeTestResult(handle)
end

function GetEntityPlayerIsLookingAt(pDistance, pRadius, pFlag, pIgnore)
    local distance = pDistance or 3.0
    local originCoords = GetPedBoneCoords(PlayerPedId(), 31086)
    local forwardVectors = GetForwardVector(GetGameplayCamRot(2))
    local forwardCoords = originCoords + (forwardVectors * (IsInVehicle and distance + 1.5 or distance))

    if not forwardVectors then
        return
    end

    local _, hit, targetCoords, _, targetEntity = RayCast(originCoords, forwardCoords, pFlag or 286, pIgnore,
        pRadius or 0.2)

    if not hit and targetEntity == 0 then
        return
    end

    local entityType = GetEntityType(targetEntity)

    return hit, targetEntity, entityType, targetCoords
end

function GetEntityInFrontOfEntity(pEntity, pDistance, pRadius, pFlag)
    local forwardVector = GetEntityForwardVector(pEntity)
    local originCoords = GetEntityCoords(pEntity)
    local targetCoords = originCoords + (forwardVector * pDistance)

    local _, hit, _, _, targetEntity = RayCast(originCoords, targetCoords, pFlag or 286, pEntity, pRadius or 0.2)

    return targetEntity
end

function GetForwardVector(rotation)
    local rot = (math.pi / 180.0) * rotation
    return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)),
        math.sin(rot.x))
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z,
        destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function AddTargetObject(models, objectData)
    for _, model in pairs(models) do
        if Objects[model] == nil then
            Objects[model] = {}
            Objects[model].distance = objectData.distance
            Objects[model].networked = objectData.networked

            Objects[model]["actions"] = {}
        end

        if objectData.id then
            Objects[model].id = objectData.id
        end
        if objectData.netId then
            Objects[model].netId = objectData.netId
        end


        for action, actionData in pairs(objectData.actions) do
            Objects[model]["actions"][action] = actionData
        end
    end
end

exports("AddTargetObject", AddTargetObject)

function AddTargetPedRelationshipGroups(relationshipGroups, objectData)
    for _, relationshipGroup in pairs(relationshipGroups) do
        if PedRelationshipGroups[relationshipGroup] == nil then
            PedRelationshipGroups[relationshipGroup] = {}
            PedRelationshipGroups[relationshipGroup].distance = objectData.distance
            PedRelationshipGroups[relationshipGroup]["actions"] = {}
        end

        for action, actionData in pairs(objectData.actions) do
            PedRelationshipGroups[relationshipGroup]["actions"][action] = actionData
        end
    end
end

exports("AddTargetPedRelationshipGroups", AddTargetPedRelationshipGroups)

function AddTargetVehicleBone(bones, bonesData)
    for _, bone in pairs(bones) do
        VehicleBones[bone] = {}
        VehicleBones[bone].distance = bonesData.distance
        VehicleBones[bone].netId = bonesData.netId
        VehicleBones[bone]["actions"] = {}
        if bonesData.weapons then
            VehicleBones[bone].weapons = bonesData.weapons
        end

        for action, actionData in pairs(bonesData.actions) do
            VehicleBones[bone]["actions"][action] = actionData
        end
    end
end

exports("AddTargetVehicleBone", AddTargetVehicleBone)

function RemoveVehicleBone(name)
    if not VehicleBones[name] then
        return
    end

    VehicleBones[name] = nil
end

exports("RemoveVehicleBone", RemoveVehicleBone)

function AddCircleZone(name, center, radius, options)
    Zones[name] = CircleZone:Create(center, radius, {
        name = name,
        useZ = false
    })

    Zones[name].targetoptions = {}
    Zones[name].targetoptions.distance = options.distance + radius
    Zones[name].actions = options.actions
end

function AddBoxZone(name, center, length, width, zoneOptions, options)
    Zones[name] = BoxZone:Create(center, length, width, zoneOptions)

    Zones[name].targetoptions = {}
    Zones[name].targetoptions.distance = options.distance
    Zones[name].actions = options.actions
end

function AddPolyzone(name, points, minZ, maxZ, gridDivisions, options)
    Zones[name] = PolyZone:Create(points, {
        name = name,
        minZ = minZ,
        maxZ = maxZ,
        gridDivisions = gridDivisions
    })

    Zones[name].targetoptions = {}
    Zones[name].targetoptions.distance = options.distance
    Zones[name].actions = options.actions
end

function AddTargetModel(models, parameteres)
    for _, model in pairs(models) do
        Models[model] = parameteres
    end
end

function RemoveZone(name)
    if not Zones[name] then
        return
    end

    if Zones[name].destroy then
        Zones[name]:destroy()
    end

    Zones[name] = nil
end

exports("DisableTarget", DisableTarget)

exports("AddCircleZone", AddCircleZone)

exports("AddBoxZone", AddBoxZone)

exports("AddPolyzone", AddPolyzone)

exports("RemoveZone", RemoveZone)

Citizen.CreateThread(function()
    while true do
        Wait(10)
        if disabledTimer ~= nil then
            disabledTimer = disabledTimer - 10
            if disabledTimer <= 0 then
                disabledTimer = nil
                if targetActive then
                    playerTargetDisable()
                end
            end
        end
    end
end)

function getPlayerWeapon()
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
    local inventoryWeapon = exports.inventory:getWeaponFromHash(weaponHash)
    if not inventoryWeapon then
        inventoryWeapon = exports.inventory:getWeaponFromHash(weaponHash % 0x100000000)
    end
    return inventoryWeapon
end

function hasPlayerWeapon(weapon)
    local currentWeapon = getPlayerWeapon()
    if currentWeapon.name ~= "weapon_unarmed" then
        if type(weapon) == "table" then
            for wp, state in each(weapon) do
                if currentWeapon.name == wp then
                    return true
                end
            end
        elseif type(weapon) == "string" then
            if weapon == currentWeapon.name then
                return true
            end
        end
    end
    return false
end
