function openTrunk(vehicle)
    if DoesEntityExist(vehicle) then
        local spz = exports.data:getVehicleActualPlateNumber(vehicle)

        if exports.vehiclelock:isVehicleLocked(vehicle) then
            exports.notify:display({ type = "error", title = "Chyba", text = "Toto vozidlo je zamčené!", icon = "fas fa-car", length = 3000 })
        else
            local playerPed = PlayerPedId()
            local trunkpos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "boot"))
            local distanceToTrunk = #(GetEntityCoords(playerPed) - trunkpos)

            if distanceToTrunk <= 2.0 or (trunkpos.x + trunkpos.y + trunkpos.z) == 0.0 then
                local class = GetVehicleClass(vehicle)
                local vehicleData = Config.VehicleTrunkData[class]

                if vehicleData.maxSpace == 0 then
                    exports.notify:display({ type = "error", title = "Chyba", text = "Toto vozidlo nemá kufr!", icon = "fas fa-car", length = 3000 })
                else
                    TaskTurnPedToFaceEntity(playerPed, vehicle, -1)

                    RequestAnimDict("missexile3")
                    while (not HasAnimDictLoaded("missexile3")) do
                        Citizen.Wait(10)
                    end
                    exports.progressbar:startProgressBar({
                        Duration = 750,
                        Label = "Otevíráš kufr vozidla...",
                        CanBeDead = false,
                        CanCancel = true,
                        DisableControls = {
                            Movement = true,
                            CarMovement = true,
                            Mouse = false,
                            Combat = true
                        }
                    }, function(finished)
                        if finished then
                            currentTrunkVehicle = vehicle
                            SetVehicleDoorOpen(vehicle, 5, false, false)
                            TriggerServerEvent("inventory:openStorage", "trunk", spz, { vehicleId = VehToNet(vehicle), maxWeight = vehicleData.maxWeight, maxSpace = vehicleData.maxSpace, label = "Kufr vozidla"})
                            TaskPlayAnim(playerPed, "missexile3", "ex03_dingy_search_case_a_michael", 100.0, 200.0, 0.3, 17, 0.2, 0, 0, 0)
                        end
                    end)
                end
            else
                exports.notify:display({ type = "error", title = "Chyba", text = "Musíš stát u kufru vozidla!", icon = "fas fa-car", length = 3000 })
            end
        end
    end
end

function openGlovebox(vehicle)
    if DoesEntityExist(vehicle) then
        local spz = exports.data:getVehicleActualPlateNumber(vehicle)
        local playerPed = PlayerPedId()

        if GetPedInVehicleSeat(vehicle, -1) ~= playerPed and GetPedInVehicleSeat(vehicle, 0) ~= playerPed then
            exports.notify:display({ type = "error", title = "Chyba", text = "Pro použití schránky musíš sedět na místě řidiče nebo spolujezdce!", icon = "fas fa-car", length = 3000 })
        else
            local class = GetVehicleClass(vehicle)
            local vehicleData = Config.VehicleGloveboxData[class]

            if vehicleData.maxSpace == 0 then
                exports.notify:display({ type = "error", title = "Chyba", text = "Toto vozidlo nemá schránku!", icon = "fas fa-car", length = 3000 })
            else
                exports.progressbar:startProgressBar({
                    Duration = 750,
                    Label = "Otevíráš přihrádku vozidla...",
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = true,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    }
                }, function(finished)
                    if finished then
                        TriggerServerEvent("inventory:openStorage", "glovebox", spz, { vehicleId = VehToNet(vehicle), maxWeight = vehicleData.maxWeight, maxSpace = vehicleData.maxSpace, label = "přihrádka vozidla"})
                    end
                end)
            end
        end
    end
end

RegisterNetEvent("inventory:trunkDenied")
AddEventHandler("inventory:trunkDenied",
    function()
        if currentTrunkVehicle then
            exports.notify:display(
                {
                    type = "error",
                    title = "Otevření kufru vozidla",
                    text = "Ve vozidle je složitější zabezpečení, do něj se nedostaneš.",
                    icon = "fas fa-car",
                    length = 3000
                }
            )

            ClearPedTasks(PlayerPedId())
            SetVehicleDoorShut(currentTrunkVehicle, 5, false)
            currentTrunkVehicle = nil
        end
    end
)
