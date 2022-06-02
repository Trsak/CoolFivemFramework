local isSpawned, isDead = false, false
local currentJob, savedOutfit, doingAction = {}, nil, false
local blips, peds = {}, {}
local showBlips = true

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        checkMisc()
    end
    for job, data in pairs(Config.Jobs) do
        exports.target:AddCircleZone("job-city-" .. job, data.Ped.xyz, 1.5, {
            actions = {
                openMenu = {
                    cb = function(data)
                        openMenu(data.Job)
                    end,
                    cbData = {
                        Job = job
                    },
                    icon = data.Texts.Icon,
                    label = "Oslovit osobu"
                }
            },
            distance = 0.3
        })
    end
end)

function openMenu(job)
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("city", Config.Jobs[job].Texts.Job, "Zvolte akci")
        WarMenu.OpenMenu("city")

        if not currentJob.Job then
            while WarMenu.IsMenuOpened("city") do
                if WarMenu.Button("Začít pracovat") then
                    TriggerServerEvent("city:checkAvailable", job)
                    WarMenu.CloseMenu()
                elseif WarMenu.Button("Zavřít") then
                    WarMenu.CloseMenu()
                end

                WarMenu.Display()
                Citizen.Wait(0)
            end
        else
            while WarMenu.IsMenuOpened("city") do
                if WarMenu.Button("Převléknout se") then
                    if not savedOutfit then
                        savedOutfit = exports.skinchooser:getPlayerOutfit()
                        local sex = exports.skinchooser:getPlayerSex() == 0 and "male" or "female"
                        print (sex, "huh")
                        exports.skinchooser:setPlayerOutfit(Config.Outfits[sex])
                    else
                        exports.skinchooser:setPlayerOutfit(savedOutfit)
                        savedOutfit = nil
                    end
                elseif currentJob.Job == job and WarMenu.Button("Ukončit práci") then
                    exports.notify:display({
                        type = "info",
                        title = "Úřad práce",
                        text = "Zase se někdy stav!",
                        icon = Config.Jobs[job].Texts.Icon,
                        length = 3000
                    })
                    endJob()
                    WarMenu.CloseMenu()
                elseif currentJob.Job ~= job and WarMenu.Button("Ukončit práci jinde a začít zde") then
                    exports.notify:display({
                        type = "info",
                        title = "Úřad práce",
                        text = "Zase se někdy stav!",
                        icon = Config.Jobs[currentJob.Job].Texts.Icon,
                        length = 3000
                    })
                    endJob()
                    Citizen.Wait(200)
                    TriggerServerEvent("city:checkAvailable", job)
                    WarMenu.CloseMenu()
                end
                if WarMenu.Button("Zavřít") then
                    WarMenu.CloseMenu()
                end
                WarMenu.Display()

                Citizen.Wait(0)
            end
        end
    end)
end

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, isDead = false, false
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            checkMisc()
        end
    end
end)

RegisterNetEvent("city:checkAvailable")
AddEventHandler("city:checkAvailable", function(job, pointId, coords, repeated)
    if currentJob.Blip then
        SetBlipCoords(currentJob.Blip, coords)
    else
        createBlip(job, coords)
    end

    currentJob.Job = job
    currentJob.Point = pointId
    createPoint(job, pointId, coords)
    if not repeated then
        exports.notify:display({
            type = "info",
            title = "Úřad práce",
            text = Config.Jobs[job].Texts.Notify,
            icon = Config.Jobs[job].Texts.Icon,
            length = 3000
        })
    end
end)

RegisterNetEvent("city:doCurrentJob")
AddEventHandler("city:doCurrentJob", function(tillFinish)
    if tillFinish <= 0 then
        if not currentJob.Job then
            return
        end
        TriggerServerEvent("city:checkAvailable", currentJob.Job, true)
    else
        exports.notify:display({
            type = "info",
            title = "Úřad práce",
            text = "Jen tak dál! Ještě to tu udělej párkrát.",
            icon = Config.Jobs[currentJob.Job].Texts.Icon,
            length = 2500
        })
    end
end)

function createPoint(job, point, coords)
    exports.target:AddCircleZone("cityJobPoint", vec3(coords.xyz), 1.5, {
        actions = {
            doAction = {
                cb = function(data)
                    if not doingAction then
                        doingAction = true
                        exports.progressbar:startProgressBar({
                            Duration = Config.Jobs[data.Job].Duration,
                            Label = Config.Jobs[data.Job].Texts.ProgressBar,
                            CanBeDead = false,
                            CanCancel = true,
                            DisableControls = {
                                Movement = true,
                                CarMovement = true,
                                Mouse = false,
                                Combat = true
                            },
                            Animation = Config.Jobs[data.Job].Anim
                        }, function(finished)
                            doingAction = false
                            if finished then
                                ClearPedTasksImmediately(PlayerPedId())
                                TriggerServerEvent("city:doCurrentJob", data.Job, data.Point)
                            end
                        end)
                    end
                end,
                cbData = {
                    Job = job,
                    Point = point
                },
                icon = Config.Jobs[job].Texts.Icon,
                label = Config.Jobs[job].Texts.Point
            }
        },
        distance = 0.2
    })
end

RegisterNetEvent("city:endJob")
AddEventHandler("city:endJob", function()
    endJob()
end)

function endJob()
    if currentJob.Job then
        TriggerServerEvent("city:unreserveJob", currentJob.Job, currentJob.Point)

        exports.target:RemoveZone("cityJobPoint")
        if DoesBlipExist(currentJob.Blip) then
            RemoveBlip(currentJob.Blip)
        end
        currentJob = {}
    end
end

function checkMisc()
    if not DoesEntityExist(peds[1]) then
        for job, data in pairs(Config.Jobs) do
            local model = GetHashKey("s_m_m_gentransport")
            while not HasModelLoaded(model) do
                RequestModel(model)
                Wait(5)
            end
            local ped = CreatePed(4, model, data.Ped.xy, data.Ped.z, false, false)
            SetEntityHeading(ped, data.Ped.w)
            SetEntityAsMissionEntity(ped, true, true)
            SetPedHearingRange(ped, 0.0)
            SetPedSeeingRange(ped, 0.0)
            SetPedAlertness(ped, 0.0)
            SetPedFleeAttributes(ped, 0, 0)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCombatAttributes(ped, 46, true)
            SetPedFleeAttributes(ped, 0, 0)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, false)
            table.insert(peds, ped)
        end
    end
    showBlips = exports.settings:getSettingValue("brigadeBlips")
    if showBlips and not DoesBlipExist(blips[1]) then
        createBrigadesBlips()
    end
end

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "brigadeBlips" then
            showBlips = value
            if not showBlips then
                for i, blip in each(blips) do
                    RemoveBlip(blip)
                end
                blips = {}
            else
                createBrigadesBlips()
            end
        end
    end
)

function createBrigadesBlips()
    for job, data in pairs(Config.Jobs) do
        local blip = createNewBlip({
            coords = data.Ped.xyz,
            sprite = 801,
            display = 4,
            scale = 0.4,
            colour = 0,
            isShortRange = true,
            text = data.Texts.Job
        })
        SetBlipCategory(blip, 10)
        table.insert(blips, blip)
    end
end

function createBlip(job, coords)
    currentJob.Blip = createNewBlip({
        coords = coords,
        sprite = 544,
        display = 2,
        scale = 0.7,
        colour = 7,
        isShortRange = true,
        text = Config.Jobs[job].Texts.Blip
    })
end
