local isSpawned, isDead, isCloseEnough = nil, false, false
local jobName, jobGrade, isDuty, jobType = nil, nil, nil, nil
local jailData = nil
local isJailed, timeInJail = false, 0
local peds = {}

Citizen.CreateThread(function()
    while not exports.data:isUserLoaded() do
        Citizen.Wait(100)
    end

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        loadJobs()
        checkIsJailed()
    end

    createPolyZones()
    createPeds()

    if exports.data:getUserVar("admin") > 1 then
        exports.chat:addSuggestion("/isJailed", "Zjistí, zda-li je hráč ve vězení a na jak dlouho případně.", {{
            name = "Číslo",
            help = "ID hráče"
        }})
    end
    exports.chat:addSuggestion("/jail", "Pošle hráče do vězení")
    exports.chat:addSuggestion("/unjail", "Propustí hráče z vězení")
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        if jailData and (not jailData.time or jailData.time > 0) then
            TriggerServerEvent("jail:updateJailData", jailData)
        end
        jailData, isJailed, isSpawned, isDead = false, false, false, false
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            loadJobs()
            createPolyZones()
            createPeds()
            checkIsJailed()
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

RegisterNetEvent("jail:sendToJail")
AddEventHandler("jail:sendToJail", function(time, data)
    isJailed, timeInJail, jailData = true, time, data
    local isTakingPhoto = true
    blockInputs()

    local requestModel = Config.PhotoScene.Ped
    while not HasModelLoaded(requestModel) do
        RequestModel(requestModel)
        Citizen.Wait(10)
    end

    local policePed = CreatePed(5, requestModel, Config.PhotoScene.PedCoords.xyz, Config.PhotoScene.PedCoords.w)
    TaskStartScenarioInPlace(policePed, "WORLD_HUMAN_PAPARAZZI", 0)

    SetEntityCoords(PlayerPedId(), Config.PhotoScene.Coords.xyz)
    SetEntityHeading(PlayerPedId(), Config.PhotoScene.Coords.w)
    FreezeEntityPosition(PlayerPedId(), true)

    local camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(camera, Config.PhotoScene.Camera[1].xyz)
    SetCamRot(camera, Config.PhotoScene.Camera[2].xyz)

    RenderScriptCams(true, false, 0, true, true)

    Citizen.Wait(3000)
    SetEntityHeading(PlayerPedId(), Config.PhotoScene.Coords.w + 90.0)
    Citizen.Wait(3000)
    SetEntityHeading(PlayerPedId(), Config.PhotoScene.Coords.w - 90.0)
    Citizen.Wait(2000)

    DeleteEntity(policePed)
    SetModelAsNoLongerNeeded(Config.PhotoScene.Ped)

    DoScreenFadeIn(250)

    RenderScriptCams(false, false, 0, true, true)
    FreezeEntityPosition(PlayerPedId(), false)
    DestroyCam(camera)

    local spawnpoint = math.random(1, #Config.JailSpawn)
    SetEntityCoords(PlayerPedId(), Config.JailSpawn[spawnpoint].xyz)
    SetEntityHeading(PlayerPedId(), Config.JailSpawn[spawnpoint].w)
    isTakingPhoto = false

    setJailOutFit()

    while isJailed do
        Citizen.Wait(60000)
        timeInJail = timeInJail - 60000
        if timeInJail > 0 then
            exports.notify:display({
                type = "info",
                title = "Vězení",
                text = "Zbývá Vám " .. math.floor(timeInJail / 60000) .. " minut. ",
                icon = "fas fa-dove",
                length = 3500
            })
        end

        jailData.time = timeInJail
        TriggerServerEvent("jail:updateJailData", jailData)
        if timeInJail <= 0 then
            releasePrisoner()
        end
    end
end)

function blockInputs()
    Citizen.CreateThread(function()
        while isTakingPhoto do
            Citizen.Wait(0)
            DisableControlAction(0, 1, true) -- Disable pan
            DisableControlAction(0, 2, true) -- Disable tilt
            DisableControlAction(1, 23, true)
            DisableControlAction(1, 24, true)
            DisableControlAction(1, 25, true)
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(1, 55, true)
            DisableControlAction(1, 75, true)
            DisableControlAction(1, 75, true)
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 288, true) -- Disable phone
            DisableControlAction(0, 289, true) -- Inventory
            DisableControlAction(0, 170, true) -- Animations
            DisableControlAction(0, 167, true) -- Job
            DisableControlAction(0, 0, true) -- Disable changing view
            DisableControlAction(0, 26, true) -- Disable looking behind
            DisableControlAction(0, 73, true) -- Disable clearing animation
            DisableControlAction(2, 199, true) -- Disable pause screen

            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle

            DisableControlAction(2, 36, true) -- Disable going stealth

            DisableControlAction(0, 47, true) -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true) -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle
        end
    end)
end

function setJailOutFit()
    local sex = exports.skinchooser:getPlayerSex() == 0 and "male" or "female"
    exports.skinchooser:setPlayerOutfit(Config.Outfits[sex], true)
end

function checkIsJailed()
    jailData = exports.data:getCharVar("jail")
    if jailData then
        if jailData.time and jailData.time > 0 then
            timeInJail = jailData.time
            isJailed = true
        end
    end

    while isJailed do
        Citizen.Wait(60000)
        timeInJail = timeInJail - 60000
        if timeInJail > 0 then
            exports.notify:display({
                type = "info",
                title = "Vězení",
                text = "Zbývá Vám " .. math.floor(timeInJail / 60000) .. " minut. ",
                icon = "fas fa-dove",
                length = 3500
            })
        end

        jailData.time = timeInJail
        TriggerServerEvent("jail:updateJailData", jailData)
        if timeInJail <= 0 then
            releasePrisoner()
        end
    end
end

function releasePrisoner()
    isJailed, jailData.time = false, nil
    TriggerServerEvent("jail:updateJailData", jailData)

    SetEntityCoords(PlayerPedId(), Config.ReleaseSpawn.xyz)
    exports.notify:display({
        type = "info",
        title = "Vězení",
        text = "Byl jste propuštěn z vězení. Nezapomeňte si cestou vzít staré oblečení a za rohem vybavení! A chovejte se!",
        icon = "fas fa-dove",
        length = 11000
    })
end

function loadJobs(Jobs)
    if not isSpawned then
        return
    end
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

function isPolice()
    for _, data in pairs(jobs) do
        if Config.CanJail[data.Type] then
            return true
        end
    end
    return false
end

function createPolyZones()
    exports.target:AddCircleZone("jail-food", vec3(1691.658203, 2566.107666, 45.564911), 1.0, {
        actions = {
            action = {
                cb = function()
                    exports.progressbar:startProgressBar({
                        Duration = 6000,
                        Label = "Jíš a piješ...",
                        CanBeDead = false,
                        CanCancel = true,
                        DisableControls = {
                            Movement = false,
                            CarMovement = true,
                            Mouse = false,
                            Combat = true
                        },
                        Animation = {
                            emotes = "beans"
                        }
                    }, function(finished)
                        if finished then
                            exports.notify:display({
                                type = "success",
                                title = "Vězeňská kantýna",
                                text = "Stavte se zase!",
                                icon = "fas fa-drumstick-bite",
                                length = 3500
                            })
                            exports.needs:changeNeed("thirst", 75.0)
                            exports.needs:changeNeed("hunger", 75.0)
                        end
                    end)
                end,
                icon = "fas fa-drumstick-bite",
                label = "Najíst se"
            }
        },
        distance = 0.2
    })

    exports.target:AddCircleZone("jail-player", vec3(1846.060669, 2587.957520, 45.672005), 1.0, {
        actions = {
            outfit = {
                cb = function()
                    if jailData.outfit then
                        exports.skinchooser:setPlayerOutfit((jailData.outfit), true)
                        jailData.outfit = nil
                        TriggerServerEvent("jail:updateJailData", jailData)
                        exports.notify:display({
                            type = "success",
                            title = "Věznice",
                            text = "Tak tady máš svoje věci.",
                            icon = "fas fa-tshirt",
                            length = 3500
                        })
                    else
                        exports.notify:display({
                            type = "warning",
                            title = "Věznice",
                            text = "Nemáme zde žádné tvoje oblečení!",
                            icon = "fas fa-tshirt",
                            length = 3500
                        })
                    end
                end,
                icon = "fas fa-tshirt",
                label = "Vyzvednout si oblečení"
            },
            loadout = {
                cb = function()
                    if jailData.loadout then
                        jailData.loadout = nil
                        TriggerServerEvent("jail:getItemsBack")
                        exports.notify:display({
                            type = "success",
                            title = "Věznice",
                            text = "Tady máš co jsme našli.",
                            icon = "fas fa-box-open",
                            length = 3500
                        })
                    else
                        exports.notify:display({
                            type = "warning",
                            title = "Věznice",
                            text = "Nemáme zde žádné tvoje věci!",
                            icon = "fas fa-box-open",
                            length = 3500
                        })
                    end
                end,
                icon = "fas fa-box-open",
                label = "Vyzvednout si věci"
            }
        },
        distance = 0.2
    })
end

function createPeds()
    if #peds <= 0 then
        local pedModel = GetHashKey("s_m_m_prisguard_01")
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(5)
        end
        local coords = {vec4(1846.060669, 2587.957520, 45.672005, 249.87),
                        vec4(1691.658203, 2566.107666, 45.564911, 183.30)}
        for i, coords in each(coords) do
            local guard = CreatePed(4, pedModel, coords.xy, coords.z - 0.9, false, false)
            SetEntityHeading(guard, coords.w)
            SetEntityAsMissionEntity(guard, true, true)
            SetPedHearingRange(guard, 0.0)
            SetPedSeeingRange(guard, 0.0)
            SetPedAlertness(guard, 0.0)
            SetPedFleeAttributes(guard, 0, 0)
            SetBlockingOfNonTemporaryEvents(guard, true)
            SetPedCombatAttributes(guard, 46, true)
            SetPedFleeAttributes(guard, 0, 0)
            SetEntityInvincible(guard, true)
            FreezeEntityPosition(guard, true)
            table.insert(peds, guard)
        end
    end
end

RegisterCommand("jail", function()
    if isSpawned and not isDead and (isPolice() or exports.data:getUserVar("admin") > 1) then
        local _source = source
        TriggerEvent("util:closestPlayer", {
            radius = 2.0
        }, function(player)
            if player then
                exports.input:openInput("number", {
                    title = "Zadejte délku trestu (v minutách - jak dlouho bude fyzicky ve vězení)",
                    placeholder = ""
                }, function(jailLength)
                    if jailLength then
                        exports.input:openInput("text", {
                            title = "Zadejte TČ (§, vc. pismene!)",
                            placeholder = ""
                        }, function(criminalOffense)
                            if criminalOffense then
                                exports.input:openInput("number", {
                                    title = "Zadejte délku trestu (v letech, celá čísla)",
                                    placeholder = ""
                                }, function(penaltyLength)
                                    if penaltyLength then
                                        TriggerServerEvent("jail:sendToJail", player, {
                                            jailLength = jailLength,
                                            criminalOffense = criminalOffense,
                                            penaltyLength = math.ceil(tonumber(penaltyLength))
                                        })
                                    end
                                end)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end)

RegisterCommand("unjail", function()
    if isSpawned and not isDead and (isPolice() or exports.data:getUserVar("admin") > 1) then
        local _source = source
        TriggerEvent("util:closestPlayer", {
            radius = 2.0
        }, function(player)
            if player then
                TriggerServerEvent("jail:sendFromJail", player)
            end
        end)
    end
end)
