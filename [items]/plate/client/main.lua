AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if itemName == "screwdriver" or itemName == "screwdriver_bennys" then
            removePlate()
        elseif itemName == "plate" then
            usePlate(itemName, slot, data)
        end
    end
)

function removePlate()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = nil

    if IsPedInAnyVehicle(playerPed, true) then
        return
    else
        vehicle = GetClosestVehicle(coords, 5.0, 0, 23)

        if not DoesEntityExist(vehicle) then
            vehicle = getVehicleInDirection(5.0)
        end
    end

    if DoesEntityExist(vehicle) then
        local plateText = GetVehicleNumberPlateText(vehicle)
        plateText = plateText:gsub(" ", "")
        if plateText ~= "" then
            local platePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "platelight"))
            if platePos.x == 0.0 and platePos.y == 0.0 and platePos.z == 0.0 then
                platePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "bumper_f"))
            end
            local distanceToPlate = #(coords - platePos)

            if distanceToPlate <= 1.0 then
                makeEntityFaceEntity(playerPed, vehicle)
                exports.progressbar:startProgressBar({
                    Duration = 7500,
                    Label = "Sundaváš SPZ z vozidla..",
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
                        if DoesEntityExist(vehicle) then
                            plateText = GetVehicleNumberPlateText(vehicle)
                            plateText = plateText:gsub(" ", "")
                            if plateText ~= "" then
                                local platePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "platelight"))
                                if platePos.x == 0.0 and platePos.y == 0.0 and platePos.z == 0.0 then
                                    platePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "bumper_f"))
                                end
                                local distanceToPlate = #(coords - platePos)

                                if distanceToPlate <= 1.0 then
                                    local netId = VehToNet(vehicle)
                                    TriggerServerEvent("plate:getVehiclePlate", plateText, GetVehicleNumberPlateTextIndex(vehicle))
                                    exports.data:setVehicleActualPlateText(netId, plateText)
                                    TriggerServerEvent("plate:setVehicleNumberPlate", netId, " ")
                                else
                                    exports.notify:display({type = "error", title = "Chyba", text = "Vozidlo se od tebe vzdálilo!", icon = "fas fa-car", length = 3000})
                                end
                            else
                                exports.notify:display({type = "error", title = "Chyba", text = "Vozidlo nemá SPZ!", icon = "fas fa-car", length = 3000})
                            end
                        else
                            exports.notify:display({type = "error", title = "Chyba", text = "Musíš stát u vozidla", icon = "fas fa-car", length = 3000})
                        end
                    end
                end)
            else
                exports.notify:display({type = "error", title = "Chyba", text = "Musíš stát u SPZ vozidla!", icon = "fas fa-car", length = 3000})
            end
        else
            exports.notify:display({type = "error", title = "Chyba", text = "Vozidlo nemá SPZ!", icon = "fas fa-car", length = 3000})
        end
    end
end

function usePlate(itemName, slot, data)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = nil

    if IsPedInAnyVehicle(playerPed, true) then
        return
    else
        vehicle = GetClosestVehicle(coords, 5.0, 0, 23)

        if not DoesEntityExist(vehicle) then
            vehicle = getVehicleInDirection(5.0)
        end
    end

    if DoesEntityExist(vehicle) then
        local plateText = GetVehicleNumberPlateText(vehicle)
        plateText = plateText:gsub(" ", "")
        if plateText == "" then
            local platePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "platelight"))
            local distanceToPlate = #(coords - platePos)
            
            if distanceToPlate <= 1.0 then
                makeEntityFaceEntity(playerPed, vehicle)
                exports.progressbar:startProgressBar({
                    Duration = 7500,
                    Label = "Nandaváš SPZ na vozidlo..",
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
                        if DoesEntityExist(vehicle) then
                            local plateText = GetVehicleNumberPlateText(vehicle)
                            plateText = plateText:gsub(" ", "")
                            if plateText == "" then
                                local platePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "platelight"))
                                local distanceToPlate = #(coords - platePos)

                                if distanceToPlate <= 1.0 then
                                    TriggerServerEvent("plate:usedPlate", data, slot)
                                    TriggerServerEvent("plate:setVehicleNumberPlate", VehToNet(vehicle), data.plateText, data.plateIndex)
                                else
                                    exports.notify:display({type = "error", title = "Chyba", text = "Vozidlo se od tebe vzdálilo!", icon = "fas fa-car", length = 3000})
                                end
                            else
                                exports.notify:display({type = "error", title = "Chyba", text = "Vozidlo již má SPZ!", icon = "fas fa-car", length = 3000})
                            end
                        else
                            exports.notify:display({type = "error", title = "Chyba", text = "Musíš stát u vozidla", icon = "fas fa-car", length = 3000})
                        end
                    end
                end)
            else
                exports.notify:display({type = "error", title = "Chyba", text = "Musíš stát u SPZ vozidla!", icon = "fas fa-car", length = 3000})
            end
        else
            exports.notify:display({type = "error", title = "Chyba", text = "Vozidlo již má SPZ!", icon = "fas fa-car", length = 3000})
        end
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Musíš stát u vozidla", icon = "fas fa-car", length = 3000})
    end
end

function getVehicleInDirection(range)
    local playerPed = PlayerPedId()
    local coordA = GetEntityCoords(playerPed, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, range, 0.0)

    local rayHandle = CastRayPointToPoint(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 10, playerPed, 0)
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

RegisterNetEvent("plate:setVehicleNumberPlate")
AddEventHandler(
    "plate:setVehicleNumberPlate",
    function(netId, plate, plateIndex)
        if not NetworkDoesEntityExistWithNetworkId(netId) then
            return
        end
        local vehicle = NetToVeh(netId)

        if DoesEntityExist(vehicle) then
            SetVehicleNumberPlateText(vehicle, plate)

            if plateIndex then 
                SetVehicleNumberPlateTextIndex(vehicle, plateIndex)
            end
        end
    end
)