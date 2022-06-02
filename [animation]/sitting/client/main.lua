local sitting = false
local pos = nil
local lastPos = nil
local currentSitObj = nil
local data = nil
local object = nil
local distance = 0
local inAnimation = nil
local currentSeat = 1
local hasScenario = false

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        local models = {}
        for _, dataSitable in each(Config.Sitable) do
            table.insert(models, GetHashKey(dataSitable.prop))
        end

        exports.target:AddTargetObject(models, {
            actions = {
                sit = {
                    cb = function(entityData)
                        StartSit(entityData.entity)
                    end,
                    cbData = {},
                    icon = "fas fa-chair",
                    label = "Posadit se",
                }
            },
            distance = 2.5
        })
    end
)

function getClosest()
    local coords = GetEntityCoords(PlayerPedId(), true)
    local closestObject, closestDistance = nil, nil

    for object in EnumerateObjects() do
        if DoesEntityExist(object) then
            local distance = #(coords - GetEntityCoords(object))
            local objectHash = GetEntityModel(object)

            for i, chairData in each(Config.Sitable) do
                local maxDistance = 7.0

                if chairData.distance then
                    maxDistance = chairData.distance
                end

                if distance < maxDistance then
                    local hashkey = GetHashKey(chairData.prop)
                    if hashkey == objectHash then
                        if not closestDistance or closestDistance > distance then
                            closestObject, closestDistance = object, distance
                        end

                        break
                    end
                end
            end
        end
    end

    return closestObject, closestDistance
end

RegisterCommand(
    "sednout",
    function()
        StartSit()
    end
)

RegisterCommand(
    "sit",
    function()
        StartSit()
    end
)

RegisterNetEvent("emotes:anim")
AddEventHandler(
    "emotes:anim",
    function(anim)
        if not anim then
            inAnimation = nil
        else
            inAnimation = string.lower(anim)
        end
    end
)

RegisterNetEvent("sitting:client:StartSit")
TriggerEvent(
    "sitting:client:StartSit",
    function()
        StartSit()
    end
)

function StartSit(entity)
    if not IsPedInAnyVehicle(PlayerPedId()) then
        if sitting then
            Standup()
        else
            if not entity then
                object, distance = getClosest()
            else
                object, distance = entity, 0.1
            end

            if not object then
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "error",
                        args = { "Poblíž tebe není žádné místo na sezení" }
                    }
                )
                return
            end

            if distance < 2.5 then
                local hash = GetEntityModel(object)
                data = nil
                local modelName = nil
                local found = false

                for _, chair in each(Config.Sitable) do
                    if GetHashKey(chair.prop) == hash then
                        data = chair
                        modelName = chair.prop
                        found = true
                        break
                    end
                end

                if found then
                    if inAnimation then
                        exports.emotes:cancelEmote()
                    end
                    
                    sit(object)
                end
            else
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "error",
                        args = { "Poblíž tebe není žádné místo na sezení" }
                    }
                )
            end
        end
    else
        TriggerEvent(
            "chat:addMessage",
            {
                templateId = "error",
                args = { "Řekl bych, že už sedíš" }
            }
        )
    end
end

function Standup()
    if currentSitObj ~= nil then
        local playerPed = PlayerPedId()
        local sitID = currentSitObj
        currentSitObj = nil

        local chairObject = NetToObj(tonumber(sitID))
        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(chairObject, true, true)

        local blackjackAnimDictToLoad = "anim_casino_b@amb@casino@games@shared@player@"
        RequestAnimDict(blackjackAnimDictToLoad)
        while not HasAnimDictLoaded(blackjackAnimDictToLoad) do
            Wait(0)
        end
        TaskPlayAnim(PlayerPedId(), blackjackAnimDictToLoad, "sit_exit_left", 1.0, 1.0, 1000, 0)
        Wait(1700)
        ClearPedTasksImmediately(PlayerPedId())

        TriggerServerEvent("sitting:server:LeaveChair", sitID, currentSeat)
        LocalPlayer.state.isSitting = false

        sitting = false
        exports.key_hints:hideBottomHint({ ["name"] = "standup" })
    end
end

function sit(object)
    pos = GetEntityCoords(object)
    sitting = true

    if not NetworkGetEntityIsNetworked(object) then
        NetworkRegisterEntityAsNetworked(object)
    end
    
    currentSitObj = tostring(NetworkGetNetworkIdFromEntity(object))

    TriggerServerEvent("sitting:server:GetChair", currentSitObj, GetEntityModel(object))
end

RegisterNetEvent("sitting:client:GetChair")
AddEventHandler(
    "sitting:client:GetChair",
    function(occupied, seat)
        if occupied then
            exports.notify:display({ type = "warning", title = "Židle", text = "Nemáš si kam sednout", icon = "fa fa-frown-o", length = 3000 })
        else
            LocalPlayer.state.isSitting = true

            local playerPed = PlayerPedId()
            lastPos = GetEntityCoords(playerPed)
            currentSeat = seat
            TriggerServerEvent("sitting:server:TakeChair", currentSitObj, seat)
            SetEntityCollision(object, false, true)

            local headingOffset = 0
            local chairOffsetPosition = 0
            local position = 0

            if data.seats then
                headingOffset = data.seats[seat].headingOffset or 180.0
                chairOffsetPosition = GetOffsetFromEntityInWorldCoords(object, data.seats[seat].leftOffset, data.seats[seat].forwardOffset, data.seats[seat].verticalOffset + 1)
                position = GetOffsetFromEntityInWorldCoords(object, data.seats[seat].leftOffset, data.seats[seat].forwardOffset - 0.95, data.seats[seat].verticalOffset + 1)
            else
                headingOffset = data.headingOffset or 180.0
                chairOffsetPosition = GetOffsetFromEntityInWorldCoords(object, data.leftOffset, data.forwardOffset, data.verticalOffset + 1)
                position = GetOffsetFromEntityInWorldCoords(object, data.leftOffset, data.forwardOffset - 0.95, data.verticalOffset + 1)
            end

            TaskTurnPedToFaceEntity(playerPed, object, -1)
            SetPedResetFlag(playerPed, 322, true)

            local tries = 3

            while not IsEntityAtCoord(playerPed, position, 0.1, 0.1, 1.5, false, true, 0) or not GetEntityHeading(playerPed) == (GetEntityHeading(entity) + headingOffset) do
                TaskGoStraightToCoord(playerPed, position, 1.0, 20000, GetEntityHeading(entity) + headingOffset, 0.1)
                Citizen.Wait(500)

                tries = tries - 1
                if tries < 0 then
                    break
                end
            end

            Citizen.Wait(650)

            if data.scenario then
                TaskStartScenarioAtPosition(playerPed, data.scenario, chairOffsetPosition.x, chairOffsetPosition.y, chairOffsetPosition.z, GetEntityHeading(object) + headingOffset, 0, true, true)
            else
                RequestAnimDict(data.anim.dict)
                while not HasAnimDictLoaded(data.anim.dict) do
                    RequestAnimDict(data.anim.dict)
                    Citizen.Wait(100)
                end

                TaskPlayAnimAdvanced(playerPed, data.anim.dict, data.anim.name, chairOffsetPosition.x, chairOffsetPosition.y, chairOffsetPosition.z, 0, 0.0, GetEntityHeading(object) + headingOffset, 8.0, 1.0, -1, 2, 0.0, 0, 0)
            end

            sitting = true

            exports["key_hints"]:displayBottomHint(
                {
                    ["name"] = "standup",
                    ["key"] = "~INPUT_9B28DD9A~",
                    ["text"] = "Stoupnout si"
                }
            )
        end
    end
)

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = { handle = iter, destructor = disposeFunc }
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end
