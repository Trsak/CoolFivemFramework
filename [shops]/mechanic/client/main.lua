local isSpawned, isDead, inVehicle = false, false, false
local jobs = nil
local playerCoords = nil
local showingUpgradeHint = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == ("spawned" or "dead") then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
        end
    end
)
RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == ("spawned" or "dead") then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
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

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)
            if isSpawned and not isDead then
                local playerPed = PlayerPedId()
                playerCoords = GetEntityCoords(playerPed)
                playerVehicle = GetVehiclePedIsIn(playerPed, false)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            local sleep = 1500
            local shouldBeDisplayingHint = false
            if isSpawned and not isDead and playerVehicle ~= 0 and playerCoords then
                for i, station in each(Config.Stations) do
                    local hasAccess = hasAccess(station)
                    if hasAccess then
                        local distance = #(playerCoords - station.Coords.xyz)

                        if distance < 5.0 then
                            sleep = 1
                            shouldBeDisplayingHint = true
                            if not showingUpgradeHint then
                                showingUpgradeHint = true
                                exports.key_hints:displayBottomHint(
                                    {
                                        name = "extras",
                                        key = "~INPUT_VEH_HEADLIGHT~",
                                        text = "Vylepšit vozidlo"
                                    }
                                )
                            end
                            if IsControlJustPressed(0, 74) and not WarMenu.IsAnyMenuOpened() then
                                if station.AnyVeh then
                                    openExtras()
                                else
                                    local plate = exports.data:getVehicleActualPlateNumber(playerVehicle)
                                    TriggerServerEvent("mechanic:restrictedOpen", plate, hasAccess)
                                end
                            end
                            break
                        end
                    end
                end
            else
                sleep = 2000
            end
            if not shouldBeDisplayingHint and showingUpgradeHint then
                if WarMenu.IsMenuOpened("extras") then
                    WarMenu.Close()
                end
                showingUpgradeHint = false
                exports.key_hints:hideBottomHint({name = "extras"})
            end
            Citizen.Wait(sleep)
        end
    end
)

RegisterNetEvent("mechanic:restrictedOpen")
AddEventHandler(
    "mechanic:restrictedOpen",
    function(job)
        exports.mechanicmenu:openMechanicMenu({value = "main", job = job})
    end
)

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

function hasAccess(points)
    if points.Restricted then
        for _, jobData in pairs(jobs) do
            if points.Restricted[jobData.Name] and points.Restricted[jobData.Name] <= jobData.Grade then
                return jobData.Name
            elseif points.Restricted[jobData.Type] and points.Restricted[jobData.Type] <= jobData.Grade then
                return jobData.Name
            end
        end
    else
        return true
    end

    return false
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end
