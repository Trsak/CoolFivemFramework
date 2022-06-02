local jewelry, jewelryReady, alarmed, policeCount = nil, true, false, 0
local isSpawned, isDead, doingAction = false, false, false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
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
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
                TriggerServerEvent("jewelry:sync")
                TriggerServerEvent("jewelry:countPolice")
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
        while true do
            Citizen.Wait(15000)
            if isSpawned and not hasWhitelistedJobType() then
                TriggerServerEvent("jewelry:countPolice")
            end
        end
    end
)
RegisterNetEvent("jewelry:countPolice")
AddEventHandler(
    "jewelry:countPolice",
    function(sPolice)
        policeCount = sPolice
    end
)

RegisterNetEvent("jewelry:sync")
AddEventHandler(
    "jewelry:sync",
    function(data)
        jewelry = data.Jewelry
        jewelryReady = data.JewelryReady
        alarmed = data.Alarmed
        if not data.Reserve then
            for i, jewel in pairs(data.Jewelry) do
                if jewel.Changed or data.First then
                    if not jewel.Robbed then
                        local placeActions = {}
                        if jewel.Hacked then
                            placeActions.loot = {
                                cb = function(data)
                                    if not jewelry[data.Id].Reserved then
                                        if
                                            policeCount >= Config.PoliceCount and not doingAction and
                                                not hasWhitelistedJobType()
                                         then
                                            lootShowcase(data.Id)
                                        end
                                    end
                                end,
                                cbData = {Id = i},
                                icon = "fas fa-hand-paper",
                                label = "Vybrat vitrínu"
                            }
                        else
                            placeActions.loot = {
                                cb = function(data)
                                    if not jewelry[data.Id].Reserved then
                                        if
                                            policeCount >= Config.PoliceCount and not doingAction and
                                                not hasWhitelistedJobType()
                                         then
                                            breakShowcase(data.Id)
                                        end
                                    end
                                end,
                                cbData = {Id = i},
                                icon = "fas fa-wrench",
                                label = "Rozbít vitrínu "
                            }
                            placeActions.hack = {
                                cb = function(data)
                                    if not jewelry[data.Id].Reserved then
                                        if
                                            policeCount >= Config.PoliceCount and not doingAction and
                                                not hasWhitelistedJobType()
                                         then
                                            TriggerServerEvent("rob_jewelry:checkHackItem", data.Id)
                                        end
                                    end
                                end,
                                cbData = {Id = i},
                                icon = "fas fa-mobile",
                                label = "Hacknout"
                            }
                        end
                        exports.target:AddCircleZone(
                            "jewelry-" .. i,
                            jewel.Coords.xyz,
                            1.0,
                            {
                                actions = placeActions,
                                distance = 0.5
                            }
                        )
                    else
                        exports.target:RemoveZone("jewelry-" .. i)
                    end
                end
            end
        end
    end
)

RegisterNetEvent("jewelry:countCops")
AddEventHandler(
    "jewelry:countCops",
    function(countedPolice)
        policeCount = countedPolice
    end
)

function breakShowcase(showcase)
    doingAction = true

    TriggerServerEvent("jewelry:reserveShowcase", showcase)
    TriggerServerEvent("jewelry:breakShowcase", showcase)
    TriggerServerEvent("jewelry:alarm")

    exports.progressbar:startProgressBar({
        Duration = 5000,
        Label = "Rozbijíš sklo a bereš klenoty..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "missheist_jewel",
            anim = "smash_case_f"
        }
    }, function(finished)
        doingAction = false
        if finished then
            PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
            TriggerServerEvent("jewelry:stoleJewelry", showcase)
        else
            TriggerServerEvent("jewelry:reserveShowcase", showcase)
        end
    end)
end

function hackShowcase(showcase)
    doingAction = true
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, true)
    Citizen.Wait(4000)

    TriggerServerEvent("jewelry:reserveShowcase", showcase)

    local hackState =
        exports.hacking:DATA_CRACK(
        {
            Scaleform = "DATA_CRACK",
            Speed = 8,
            Jewelry = true,
            PoliceReportChange = 30
        }
    )
    if hackState == "successfull" then
        TriggerServerEvent("jewelry:hackShowcase", showcase)
        TriggerServerEvent("jewelry:reserveShowcase", showcase)
    else
        TriggerServerEvent("jewelry:reserveShowcase", showcase)
    end
    ClearPedTasks(PlayerPedId())
    doingAction = false
end

function lootShowcase(showcase)
    doingAction = true

    TriggerServerEvent("jewelry:reserveShowcase", showcase)

    exports.progressbar:startProgressBar({
        Duration = 10000,
        Label = "otevíráš sklo a bereš klenoty..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "oddjobs@shop_robbery@rob_till",
            anim = "loop"
        }
    }, function(finished)
        doingAction = false
        if finished then
            PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
            TriggerServerEvent("jewelry:stoleJewelry", showcase)
        else
            TriggerServerEvent("jewelry:reserveShowcase", showcase)
        end
    end)
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

function hasWhitelistedJobType()
    for _, data in pairs(jobs) do
        if Config.WhitelistedJobTypes[data.Type] and data.Duty then
            return true
        end
    end

    return false
end

RegisterNetEvent("jewelry:breakShowcase")
AddEventHandler(
    "jewelry:breakShowcase",
    function(showcase)
        while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
            RequestNamedPtfxAsset("scr_jewelheist")
            Citizen.Wait(0)
        end

        SetPtfxAssetNextCall("scr_jewelheist")
        StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", jewelry[showcase].Coords.xyz, 0.0, 0.0, 0.0, 1.0)
    end
)

RegisterNetEvent("rob_jewelry:checkHackItem")
AddEventHandler(
    "rob_jewelry:checkHackItem",
    function(showcase)
        hackShowcase(showcase)
    end
)
