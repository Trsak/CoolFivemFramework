local nearestMarker, nearestType, showingMarkerHint = nil, nil, false
local isSpawned, isDead = false, false
local doingAction = false
local jobs, points = nil, nil

Citizen.CreateThread(
    function()
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            TriggerServerEvent("harvesting:sync")
            loadJobs()
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, doingAction, jobs = false, false, false, {}
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            if not isDead then
                TriggerServerEvent("harvesting:sync")
                loadJobs()
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

RegisterNetEvent("harvesting:sync")
AddEventHandler(
    "harvesting:sync",
    function(sPoints)
        points = sPoints
        if nearestMarker and nearestType then
            resetHint()
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        while true do
            if points ~= nil then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local shouldBeDisplayingHint = false
                for type, typeData in pairs(points) do
                    if not Config.Jobs[type].Job or hasJob(type) then
                        for i, pointData in each(typeData) do
                            if #(playerCoords - pointData.Coords) <= 1.0 then
                                if i ~= nearestMarker then
                                    resetHint()
                                end

                                shouldBeDisplayingHint = true
                                nearestMarker = i
                                nearestType = type

                                if not showingMarkerHint and not doingAction then
                                    showingMarkerHint = true
                                    local text =
                                        pointData.Available ..
                                        " / " .. Config.Jobs[type].MaxCount .. " " .. Config.Jobs[type].Labels.Pickup
                                    exports.key_hints:displayHint(
                                        {
                                            name = "harvesting",
                                            key = "~INPUT_D6FCD4AF~",
                                            text = text,
                                            coords = pointData.Coords
                                        }
                                    )
                                end
                                break
                            end
                        end
                        if not shouldBeDisplayingHint and showingMarkerHint then
                            resetHint()
                        end
                    end
                end
            end

            Citizen.Wait(500)
        end
    end
)

function hasJob(job)
    if jobs[Config.Jobs[job].Job.Job] ~= nil then
        if
            not jobs[Config.Jobs[job].Job.Job].Grade or
                jobs[Config.Jobs[job].Job.Job].Grade >= Config.Jobs[job].Job.Grade
         then
            return true
        end
    end

    return false
end

function harvestPoint(data)
    if points[data.Type][data.Id].Available > 0 then
        if not points[data.Type][data.Id].Reserved then
            resetHint()
            TriggerServerEvent("harvesting:reservePoint", data, true)
            doingAction = true
            exports.progressbar:startProgressBar({
                Duration = Config.Jobs[data.Type].Duration,
                Label = Config.Jobs[data.Type].Labels.MythicPickup,
                CanBeDead = false,
                CanCancel = true,
                DisableControls = {
                    Movement = false,
                    CarMovement = false,
                    Mouse = false,
                    Combat = true
                },
                Animation = Config.Jobs[data.Type].Anim
            }, function(finished)
                doingAction = false
                if finished then
                    TriggerServerEvent("harvesting:madePoint", data)
                else
                    TriggerServerEvent("harvesting:reservePoint", data, false)
                end
            end)
        else
            exports.notify:display(
                {
                    type = "info",
                    title = Config.Jobs[data.Type].Labels.Title,
                    text = "Tady je někdo jiný!",
                    icon = Config.Jobs[data.Type].Labels.Icon,
                    length = 3000
                }
            )
        end
    else
        exports.notify:display(
            {
                type = "info",
                title = Config.Jobs[data.Type].Labels.Title,
                text = "Tady už nic není!",
                icon = Config.Jobs[data.Type].Labels.Icon,
                length = 3000
            }
        )
    end
end

function resetHint()
    nearestMarker, nearestType, showingMarkerHint = nil, nil, false
    exports.key_hints:hideHint({name = "harvesting"})
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

RegisterCommand(
    "harvesting",
    function()
        if not isDead then
            if nearestMarker ~= nil and nearestType ~= nil and not doingAction then
                harvestPoint({Type = nearestType, Id = nearestMarker})
            end
        end
    end
)
createNewKeyMapping({command = "harvesting", text = "Sběr", key = "E"})

local newPoints = {}
RegisterCommand(
    "harvest_dev",
    function(source, args)
        if exports.data:getUserVar("admin") > 2 then
            if args[1] == "start" then
                creating = true
                while creating do
                    local pCoords = GetEntityCoords(PlayerPedId())
                    Citizen.Wait(0)
                    for i, coords in each(newPoints) do
                        if #(pCoords - coords) < 20.0 then
                            DrawMarker(
                                28,
                                coords,
                                0.0,
                                0.0,
                                0.0,
                                0.0,
                                0.0,
                                0.0,
                                1.0,
                                1.0,
                                1.0,
                                150,
                                150,
                                255,
                                150,
                                false,
                                false,
                                false,
                                false
                            )
                        end
                    end
                end
            elseif args[1] == "add" then
                if creating then
                    local currentCoords = GetEntityCoords(PlayerPedId(), false)
                    table.insert(newPoints, currentCoords)
                    TriggerEvent(
                        "chat:addMessage",
                        {
                            templateId = "success",
                            args = {"Pozice 'spawn' přidána"}
                        }
                    )
                end
            elseif args[1] == "save" then
                if creating then
                    TriggerServerEvent("harvesting:printCoords", newPoints)
                    creating = false
                end
            end
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end
)
