RegisterCommand('attach', function()
    local player = PlayerPedId()
    if IsPedInAnyVehicle(player, false) then
        exports.notify:display({ type = "error", title = "Chyba", text = "Nesmíš sedět ve vozidle!", icon = "fas fa-times", length = 5000 })
    else
        local vehicle = getClosestVehicle(GetEntityCoords(player))

        if DoesEntityExist(vehicle) and #(GetEntityCoords(player) - GetEntityCoords(vehicle)) <= 4.0 then
            local flatbed, distance = getClosestVehicle(GetEntityCoords(player), GetHashKey("flatbed3"))
            if DoesEntityExist(flatbed) and distance < 15.0 then
                if flatbed == vehicle then
                    exports.notify:display({ type = "error", title = "Chyba", text = "Nemůžeš dát odtahovku na odtahovku!", icon = "fas fa-times", length = 5000 })
                else
                    if not IsEntityAttached(vehicle) then
                        exports.progressbar:startProgressBar({
                            Duration = 7500,
                            Label = "Připevňuješ vozidlo na odtahovku..",
                            CanBeDead = false,
                            CanCancel = true,
                            DisableControls = {
                                Movement = false,
                                CarMovement = false,
                                Mouse = false,
                                Combat = true
                            },
                            Animation = {
                                scenario = "PROP_HUMAN_BUM_BIN"
                            }
                        }, function(finished)
                            if finished then
                                local boneIndex = GetEntityBoneIndexByName(flatbed, 'chassis')
                                local vehicleCoords = vec3(0.0, -2.4, 0.95)

                                SetEntityHeading(vehicle, GetEntityHeading(flatbed))
                                AttachEntityToEntity(vehicle, flatbed, boneIndex, vehicleCoords, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                PlaceObjectOnGroundProperly(vehicle)
                            end
                        end)
                    else
                        exports.notify:display({ type = "error", title = "Chyba", text = "Vozidlo je již naloženo!", icon = "fas fa-times", length = 5000 })
                    end
                end
            else
                exports.notify:display({ type = "error", title = "Chyba", text = "Poblíž není žádná odtahovka!", icon = "fas fa-times", length = 5000 })
            end
        else
            exports.notify:display({ type = "error", title = "Chyba", text = "Není u tebe žádné auto k naložení!", icon = "fas fa-times", length = 5000 })
        end
    end
end)

RegisterCommand('detach', function()
    local player = PlayerPedId()
    if IsPedInAnyVehicle(player, false) then
        exports.notify:display({ type = "error", title = "Chyba", text = "Nesmíš sedět ve vozidle!", icon = "fas fa-times", length = 5000 })
    else
        local vehicle = getClosestVehicle(GetEntityCoords(player))

        if DoesEntityExist(vehicle) and #(GetEntityCoords(player) - GetEntityCoords(vehicle)) <= 4.0 then
            if IsEntityAttached(vehicle) then
                exports.progressbar:startProgressBar({
                    Duration = 7500,
                    Label = "Sundáváš vozidlo z odtahu..",
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = false,
                        CarMovement = false,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = {
                        scenario = "PROP_HUMAN_BUM_BIN"
                    }
                }, function(finished)
                    if finished then
                        DetachEntity(vehicle, false, true)
                        SetEntityCoords(vehicle, GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -7.5, -1.0))
                    end
                end)
            else
                exports.notify:display({ type = "error", title = "Chyba", text = "Není u tebe žádné naložené auto!", icon = "fas fa-times", length = 5000 })
            end
        else
            exports.notify:display({ type = "error", title = "Chyba", text = "Není u tebe žádné naložené auto!", icon = "fas fa-times", length = 5000 })
        end
    end
end)

function getClosestVehicle(coords, vehModel)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end

    for _, vehicle in each(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(vehicleCoords - coords)

        if ((vehModel == nil and GetEntityModel(vehicle) ~= GetHashKey("flatbed3")) or GetEntityModel(vehicle) == vehModel) and (closestDistance == -1 or closestDistance > distance) then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    return closestVehicle, closestDistance
end

