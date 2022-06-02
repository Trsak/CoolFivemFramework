local isSpawned, isDead = false, false

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        for item, prop in pairs(Config.AllowedItems) do
            exports.target:AddTargetObject(
                { GetHashKey(prop) },
                {
                    actions = {
                        propPickup = {
                            cb = function(propData)
                                if not isDead then
                                    startAnimation("anim@heists@narcotics@trash", "pickup")

                                    Citizen.Wait(700)

                                    local coords = GetOffsetFromEntityInWorldCoords(propData.entity, 0.0, -1.5 + (3.5 * 2), 0.15)
                                    local coords2 = GetOffsetFromEntityInWorldCoords(propData.entity, 0.0, 1.5 - 3.5, 0.15)

                                    TriggerServerEvent("utility_items:deleteObject", ObjToNet(propData.entity), propData.item)

                                    if propData.item == "spikestrips" then
                                        local second = GetClosestObjectOfType(coords, 1.5, GetHashKey(Config.AllowedItems[propData.item]), false, false, false)
                                        if DoesEntityExist(second) then
                                            TriggerServerEvent("utility_items:deleteObject", ObjToNet(second), propData.item)
                                        end

                                        second = GetClosestObjectOfType(coords2, 1.5, GetHashKey(Config.AllowedItems[propData.item]), false, false, false)
                                        if DoesEntityExist(second) then
                                            TriggerServerEvent("utility_items:deleteObject", ObjToNet(second), propData.item)
                                        end
                                    end

                                    Citizen.Wait(500)

                                    if not DoesEntityExist(propData.entity) then
                                        TriggerServerEvent("utility_items:takeFromGround", propData.item)
                                    end

                                    ClearPedTasks(PlayerPedId())
                                end
                            end,
                            cbData = {
                                item = item
                            },
                            icon = "fas fa-box",
                            label = "Sebrat předmět"
                        }
                    },
                    distance = 1.2
                }
            )
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)
RegisterNetEvent("utility_items:deleteObject")
AddEventHandler(
    "utility_items:deleteObject",
    function(netId)
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local entity = NetToObj(netId)
            DeleteEntity(entity)
        end
    end)

RegisterNetEvent("utility_items:place")
AddEventHandler(
    "utility_items:place",
    function(entity, count)
        local pPed = PlayerPedId()
        if entity == "P_ld_stinger_s" then
            startAnimationSpikes("weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor")
            Citizen.Wait(250)
        else
            startAnimation("anim@heists@money_grab@briefcase", "put_down_case")
            Citizen.Wait(1000)
            ClearPedTasks(pPed)
        end

        local model = GetHashKey(entity)

        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(0)
        end

        for i = 1, count do
            local position
            if entity == "P_ld_stinger_s" then
                position = GetOffsetFromEntityInWorldCoords(pPed, 0.0, -1.5 + (3.5 * i), 0.15)
            else
                position = GetOffsetFromEntityInWorldCoords(pPed, 1, 0.5, -0.98)
            end

            local object = CreateObject(model, position, true, false)
            SetEntityHeading(object, GetEntityHeading(pPed))
            PlaceObjectOnGroundProperly(object)

            if entity == "P_ld_stinger_s" then
                FreezeEntityPosition(object)
            end
        end
    end
)

function startAnimation(lib, anim)
    while not HasAnimDictLoaded(lib) do
        RequestAnimDict(lib)
        Citizen.Wait(1)
    end

    TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

function startAnimationSpikes(lib, anim)
    while not HasAnimDictLoaded(lib) do
        RequestAnimDict(lib)
        Citizen.Wait(1)
    end

    TaskPlayAnim(PlayerPedId(), lib, anim, 1.0, 1.0, -1, 48, -1, 0, 0, 0)
end

-- Spikes
local spikemodel = Config.AllowedItems.spikestrips
local currentDrivingVehicle

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsUsing(playerPed)
        currentDrivingVehicle = nil

        if vehicle ~= 0 then
            if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                currentDrivingVehicle = vehicle
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if currentDrivingVehicle ~= nil then
            local vehicle = currentDrivingVehicle
            local vehCoord = GetEntityCoords(vehicle)

            if DoesObjectOfTypeExistAtCoords(vehCoord.x, vehCoord.y, vehCoord.z, 1.5, GetHashKey(spikemodel), true) then
                local tires = {
                    { bone = "wheel_lf", index = 0 },
                    { bone = "wheel_rf", index = 1 },
                    { bone = "wheel_lm", index = 2 },
                    { bone = "wheel_rm", index = 3 },
                    { bone = "wheel_lr", index = 4 },
                    { bone = "wheel_rr", index = 5 }
                }

                for a = 1, #tires do
                    local tirePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))

                    if DoesObjectOfTypeExistAtCoords(tirePos.x, tirePos.y, tirePos.z, 0.8, GetHashKey(spikemodel), true) then
                        if not IsVehicleTyreBurst(vehicle, tires[a].index, true) then
                            SetVehicleTyreBurst(vehicle, tires[a].index, true, 1000.0)
                        end
                    end
                end
            end
        end

        Citizen.Wait(10)
    end
end)