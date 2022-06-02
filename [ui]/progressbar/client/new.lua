local hasBar, hasFinished = false, false
local isSpawned, isDead = false, false
local props = {}

Citizen.CreateThread(function()

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, isDead = false, false
    elseif status == "spawned" or "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

function disableControls(data)
    Citizen.CreateThread(function()
        while hasBar do
            Citizen.Wait(0)
            if data.Mouse then
                DisableControlAction(0, 1, true) -- LookLeftRight
                DisableControlAction(0, 2, true) -- LookUpDown
                DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            end

            if data.Movement then
                DisableControlAction(0, 30, true) -- disable left/right
                DisableControlAction(0, 31, true) -- disable forward/back
                DisableControlAction(0, 36, true) -- INPUT_DUCK
                DisableControlAction(0, 21, true) -- disable sprint
            end

            if data.CarMovement then
                DisableControlAction(0, 63, true) -- veh turn left
                DisableControlAction(0, 64, true) -- veh turn right
                DisableControlAction(0, 71, true) -- veh forward
                DisableControlAction(0, 72, true) -- veh backwards
                DisableControlAction(0, 75, true) -- disable exit vehicle
            end

            if data.Combat then
                DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
                DisableControlAction(0, 24, true) -- disable attack
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(1, 37, true) -- disable weapon select
                DisableControlAction(0, 47, true) -- disable weapon
                DisableControlAction(0, 58, true) -- disable weapon
                DisableControlAction(0, 140, true) -- disable melee
                DisableControlAction(0, 141, true) -- disable melee
                DisableControlAction(0, 142, true) -- disable melee
                DisableControlAction(0, 143, true) -- disable melee
                DisableControlAction(0, 263, true) -- disable melee
                DisableControlAction(0, 264, true) -- disable melee
                DisableControlAction(0, 257, true) -- disable melee
            end
        end
    end)
end

function cleanUp(data)
    local playerPed = PlayerPedId()

    if data.Animation then
        if data.Animation.scenario then
            ClearPedSecondaryTask(playerPed)
            if data.Animation.immediatelyCancel then
                ClearPedTasksImmediately(playerPed)
            else
                ClearPedTasks(playerPed)
            end
        elseif data.Animation.animDict and data.Animation.anim then
            StopAnimTask(playerPed, data.Animation.animDict, data.Animation.anim, 1.0)
        elseif data.Animation.emotes then
            exports.emotes:cancelEmote()
        end
    end
    if data.Props and #props > 0 then
        for i, prop in each(props) do
            local entityId = NetToObj(prop)
            DeleteEntity(entityId)
        end
    end
end

function playAnim(animData)
    if animData then
        if animData.scenario then
            TaskStartScenarioInPlace(PlayerPedId(), animData.scenario, 0, true)
        elseif animData.emotes then
            print(animData.emotes)
            exports.emotes:playEmoteByName(animData.emotes)
        elseif animData.animDict and animData.anim then
            local flags = (animData.flags or 1)
            loadAnimDict(animData.animDict)
            TaskPlayAnim(PlayerPedId(), animData.animDict, animData.anim, 2.0, 2.0, -1, flags, 0, false, false, false)
        end
    end
end

function createProps(propsData)
    if propsData then
        props = {}
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for i, propData in each(propsData) do
            loadModel(propData.Model)
            local model = (type(propData.Model) == "string" and GetHashKey(propData.Model) or propData.Model)
            local boneIndex = GetPedBoneIndex(playerPed, propData.Bone)
            local prop = CreateObject(model, playerCoords, true, true, true)
            AttachEntityToEntity(prop, playerPed, boneIndex, propData.Offset, propData.Rotate, true, true, false, true, 1, true)
            SetEntityCollision(prop, false, true)
            table.insert(props, ObjToNet(prop))
        end
    end
end

function hasProgressBar()
    return hasBar
end

function blockFrameworkThings(state)
    exports.inventory:disableInventory(state)
    exports.target:DisableTarget(state)
    exports.emotes:DisableEmotes(state)
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function loadModel(model)
    local model = (type(model) == "string" and GetHashKey(model) or model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function cancelProgressBar(finished)
    blockFrameworkThings(false)
    hasFinished, hasBar = finished, false

    if not finished then
        SendNUIMessage({
            action = "cancelProgressBar"
        })
    end
end

function startProgressBar(data, cb)
    if isDead and not data.CanBeDead or hasBar then
        return
    end
    hasBar = true
    blockFrameworkThings(true)

    SendNUIMessage({
        action = "showProgressBar",
        duration = data.Duration,
        label = data.Label
    })

    playAnim(data.Animation)
    createProps(data.Props)
    disableControls(data.DisableControls)

    Citizen.CreateThread(function()
        while hasBar do
            Citizen.Wait(1)
            if IsControlJustReleased(0, 178) and data.CanCancel or isDead and not data.CanBeDead then
                cancelProgressBar(false)
            end
        end
        cleanUp(data)
        if cb then
            cb(hasFinished)
        end
    end)
end

RegisterNetEvent("startProgressBar", startProgressBar)

RegisterNUICallback("actionFinish", function(data, cb)
    cancelProgressBar(true)
    cb(true);
end)
