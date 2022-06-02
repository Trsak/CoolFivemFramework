local nearestMarker, nearestJob = nil, nil
local showingMarkerHint = false
local isSpawned, isDead = false, false
local jobs = {}
local configJobs = {}
local blips = {}
local showBlips = false

Citizen.CreateThread(
    function()
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            loadJobs()
            isSpawned = true
            isDead = (status == "dead")
            showBlips = exports.settings:getSettingValue("jobBlips")
            if showBlips then
                createBlips()
            end 
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, jobs, configJobs = false, false, {}, {}
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
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

Citizen.CreateThread(
    function()
        local locked = false
        while true do
            if isSpawned then
                local currentTime = GetGameTimer()
                for job, jobData in pairs(Config.Jobs) do
                    local ClearAreaData = jobData.ClearArea
                    if ClearAreaData then
                        local radius = ClearAreaData.radius or 50.0
                        local flags = ClearAreaData.flags or 1
                        local coords = ClearAreaData.Coords
                        if not ClearAreaData.locked then
                            for i = 1, #coords do
                                ClearAreaOfPeds(coords[i].x, coords[i].y, coords[i].z, radius, flags)
                            end
                            ClearAreaData.locked = GetGameTimer()
                        else
                            if (currentTime - ClearAreaData.locked) >= 2000 then
                                ClearAreaData.locked = nil
                            end
                        end
                    end
                end
            end
            Citizen.Wait(50)
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if isSpawned then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local shouldBeDisplayingHint = false
                for job, jobData in pairs(configJobs) do
                    for place, placeData in pairs(jobData.Places) do
                        for i, coords in each(placeData.Coords) do
                            local dist = #(playerCoords - coords) <= 1.0
                            if place == "MechanicMenu" then
                                dist = #(playerCoords - coords) <= 5.0
                            end
                            if dist then
                                if getPlayerJobData(job, place) then
                                    shouldBeDisplayingHint = true
                                    nearestMarker, nearestMarkerId, nearestJob = place, i, job

                                    if not showingMarkerHint then
                                        showingMarkerHint = true
                                        exports.key_hints:displayBottomHint(
                                            {
                                                name = "uni_jobs",
                                                key = "~INPUT_PICKUP~",
                                                text = Config.Texts[place]
                                            }
                                        )
                                    end
                                    break
                                end
                            end
                        end

                        if not shouldBeDisplayingHint and showingMarkerHint or isDead then
                            nearestMarker, nearestMarkerId, nearestJob = nil, nil, nil
                            showingMarkerHint = false
                            exports.key_hints:hideBottomHint({name = "uni_jobs"})
                        end
                    end
                end
            end

            Citizen.Wait(1500)
        end
    end
)

RegisterCommand(
    "jobs_action",
    function()
        if nearestMarker ~= nil then
            if nearestMarker == "Duty" then
                jobs[nearestJob].Duty = not jobs[nearestJob].Duty
                exports.notify:display(
                    {
                        type = "info",
                        title = "Služba",
                        text = jobs[nearestJob].Duty and "Přišel jste do služby" or "Odešel jste ze služby",
                        icon = "fas fa-briefcase",
                        length = 3000
                    }
                )
                TriggerServerEvent("base_jobs:updateDuty", nearestJob, jobs[nearestJob].Duty)
                exports.base_jobs:forceBonus()
            elseif nearestMarker == "Bossmenu" then
                exports.bossmenu:openBossMenu(nearestJob)
            elseif nearestMarker == "Cloakroom" then
                exports.clothes_shop:openClothesMenu()
            elseif nearestMarker == "WeaponRegister" then
                exports.register_weapons:registerWeapon()
            elseif nearestMarker == "MechanicMenu" then
                exports.mechanicmenu:openMechanicMenu({value = "main", job = nearestJob})
            elseif nearestMarker == "Storage" then
                TriggerServerEvent(
                    "inventory:openStorage",
                    "storage",
                    nearestJob .. "-" .. nearestMarkerId,
                    {
                        maxWeight = 5000.0,
                        maxSpace = 500,
                        label = "Sklad č." .. nearestMarkerId .. " " .. nearestJob
                    }
                )
            elseif nearestMarker == "Fridge" then
                TriggerServerEvent(
                    "inventory:openStorage",
                    "fridge",
                    nearestJob .. "-" .. nearestMarkerId,
                    {maxWeight = 250.0, maxSpace = 50, label = "Lednice č." .. nearestMarkerId .. " " .. nearestJob}
                )
            elseif nearestMarker == "Vault" then
                TriggerServerEvent(
                    "inventory:openStorage",
                    "vault",
                    nearestJob .. "-" .. nearestMarkerId,
                    {
                        maxWeight = 50,
                        maxSpace = 5,
                        label = "Trezor č." .. nearestMarkerId .. " " .. nearestJob
                    }
                )
            elseif nearestMarker == "PersonalCloset" then
                TriggerServerEvent(
                    "inventory:openStorage",
                    "personalCloset",
                    nearestJob .. "-" .. tostring(exports.data:getCharVar("id")),
                    {
                        maxWeight = 120.0,
                        maxSpace = 40,
                        label = "Osobní skříňka: " .. exports.data:getCharVar("lastname")
                    }
                )
            elseif nearestMarker == "Licenses" then
                giveLicense()
            elseif nearestMarker == "ChangeOutfit" then
                changeOutfit()
            elseif nearestMarker == "Armory" then
                exports.armory:openArmory(nearestJob)
            end
        end
    end
)
createNewKeyMapping({command = "jobs_action", text = "Akce v zaměstnání", key = "E"})

function loadJobs(Jobs)
    jobs = {}
    configJobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
    for job, data in pairs(Config.Jobs) do
        if jobs[job] then
            configJobs[job] = data
        end
    end
end

function getPlayerJobData(job, place)
    if not configJobs[job].Places[place].Grade or jobs[job].Grade >= configJobs[job].Places[place].Grade then
        local requestedDuty = configJobs[job].Places[place].Duty
        if not requestedDuty or jobs[job].Duty == requestedDuty then
            return true
        end
    end

    return false
end

function createBlips()
    if #blips <= 0 then
        for job, jobData in pairs(Config.Jobs) do
            if jobData.Blips then
                for blipName, blipData in pairs(jobData.Blips) do
                    local blip =
                        createNewBlip(
                        {
                            coords = blipData.Coords,
                            sprite = blipData.Sprite,
                            display = 4,
                            scale = 0.7,
                            colour = 0,
                            isShortRange = true,
                            text = blipName
                        }
                    )
                    table.insert(blips, blip)
                end
            end
        end
    end
end

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "jobBlips" then
            showBlips = value
            if not showBlips then
                for i, blip in each(blips) do
                    RemoveBlip(blip)
                end
                blips = {}
            else
                createBlips()
            end
        end
    end
)
