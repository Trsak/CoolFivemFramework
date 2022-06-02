local isSpawned, isDead, jobs = false, false, nil

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == ("spawned" or "dead") then
        isSpawned = true
        isDead = (status == "dead")
        loadJobs()
    end
end)
RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == ("spawned" or "dead") then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            loadJobs()
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

function getVehicleInDirection()
    local pPed = PlayerPedId()
    local coordA = GetEntityCoords(pPed)
    local coordB = GetOffsetFromEntityInWorldCoords(pPed, 0.0, 6.0, 0.0)

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordA, coordB, 10, pPed, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

RegisterNetEvent("inventory:usedItem")
AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    if itemName == "repairkit" or itemName == "sponge" or itemName == "sponge_bennys" then
        local pPed = PlayerPedId()
        local pCoords = GetEntityCoords(pPed)
        local vehicle = GetClosestVehicle(pCoords, 5.0, 0, 70)

        if not DoesEntityExist(vehicle) then
            vehicle = getVehicleInDirection()
        end
        if vehicle ~= nil and vehicle ~= 0 then
            if itemName == "repairkit" then
                local plcBone = GetEntityBoneIndexByName(vehicle, "engine")
                local motorCoords = GetWorldPositionOfEntityBone(vehicle, plcBone)
                local distance = #(pCoords - motorCoords)
                if distance <= 2.5 then
                    local enginehealth, bodyhealth = GetVehicleEngineHealth(vehicle), GetVehicleBodyHealth(vehicle)
                    if enginehealth <= -4000 or bodyhealth <= 0 then
                        exports.notify:display({
                            type = "error",
                            title = "Oprava vozidla",
                            text = "Tohle asi jen tak neopravíš",
                            icon = "fas fa-car",
                            length = 3000
                        })
                    else
                        if not isMechanic() then
                            exports.notify:display({
                                type = "error",
                                title = "Chyba",
                                text = "Na toto nemáš dostatek znalostí!",
                                icon = "fas fa-car",
                                length = 3000
                            })
                            return
                        end
                        exports.progressbar:startProgressBar({
                            Duration = 60000,
                            Label = "Opravuješ vozidlo..",
                            CanBeDead = false,
                            CanCancel = true,
                            DisableControls = {
                                Movement = true,
                                CarMovement = true,
                                Mouse = false,
                                Combat = true
                            },
                            Animation = Config.Anims[itemName]
                        }, function(finished)
                            if finished then
                                local checkVeh = GetClosestVehicle(pCoords, 5.0, 0, 70)

                                if not DoesEntityExist(checkVeh) then
                                    checkVeh = getVehicleInDirection()
                                end
                                if checkVeh == vehicle then
                                    local veh = NetworkGetNetworkIdFromEntity(vehicle)
                                    if isMechanic() then
                                        TriggerServerEvent("repairkit:repair", veh, true, true, false)
                                    end
                                else
                                    exports.notify:display({
                                        type = "error",
                                        title = "Oprava vozidla",
                                        text = "Vozidlo se vzdálilo",
                                        icon = "fas fa-car",
                                        length = 3000
                                    })
                                end
                            end
                        end)
                    end
                else
                    exports.notify:display({
                        type = "error",
                        title = "Oprava vozidla",
                        text = "Nejsi u motoru",
                        icon = "fas fa-car",
                        length = 3000
                    })
                end
            else
                exports.progressbar:startProgressBar({
                    Duration = 15000,
                    Label = "Myješ vozidlo..",
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = true,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = Config.Anims[itemName]
                }, function(finished)
                    if finished then
                        local checkVeh = GetClosestVehicle(pCoords, 5.0, 0, 70)

                        if not DoesEntityExist(checkVeh) then
                            checkVeh = getVehicleInDirection()
                        end
                        if checkVeh == vehicle then
                            local veh = NetworkGetNetworkIdFromEntity(vehicle)
                            TriggerServerEvent("repairkit:repair", veh, false, false, true)
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Umytí vozu",
                                text = "Vozidlo se vzdálilo",
                                icon = "fas fa-car",
                                length = 3000
                            })
                        end
                    end
                end)
            end
        else
            exports.notify:display({
                type = "error",
                title = "Vozidlo",
                text = "Nejsi poblíž žádného vozidla",
                icon = "fas fa-car",
                length = 3000
            })
        end
    end
end)

RegisterNetEvent("repairkit:repair")
AddEventHandler("repairkit:repair", function(netID, engine, design, clean)
    local vehicle = NetworkGetEntityFromNetworkId(netID)
    if DoesEntityExist(vehicle) then
        local enginehealth, bodyhealth = GetVehicleEngineHealth(vehicle), GetVehicleBodyHealth(vehicle)
        if design then
            SetVehicleDeformationFixed(vehicle)
            SetVehicleFixed(vehicle)
            SetVehicleBodyHealth(vehicle, bodyhealth)
            SetVehicleEngineHealth(vehicle, enginehealth)
        end

        if engine then
            SetVehicleDeformationFixed(vehicle)
            SetVehicleFixed(vehicle)
            SetVehicleBodyHealth(vehicle, 1000.00)
            SetVehicleEngineHealth(vehicle, 1000.00)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleEngineOn(vehicle, true, true)
        end

        if clean then
            WashDecalsFromVehicle(vehicle, 1.0)
            SetVehicleDirtLevel(vehicle, 0.0)
        end
    end
end)

function isMechanic()
    for _, data in pairs(jobs) do
        if Config.CanRepair[data.Name] then
            return true
        end
    end
    return false
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end
