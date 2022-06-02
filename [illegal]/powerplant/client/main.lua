local plantPoints, peds = {}, {}
local isSpawned, isDead, isCop = false, false, false
local plantStyle, canBlackout, ready, policeAlerted = nil, false, true, false
local currentNearestPoint, currentIndex, currentStyle, showingPointHint, blackouted = nil, nil, nil, false, false
local guardsHash, policeHash, otherHash = 1972614767, 2046537925, 1403091332
local jobs = {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
            if #peds == 0 then
                guardPeds()
            end
            TriggerServerEvent("powerplant:sync")
            while not points do
                Citizen.Wait(500)
            end
            for i, point in each(points) do
                createZone(i, point)
            end
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
            isSpawned = true
            isDead = (status == "dead")

            loadJobs()
            if #peds == 0 then
                guardPeds()
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
        if not hasWhitelistedJobType() then
            SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("PLAYER"))
        else
            SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("GuardPeds"))
        end
    end
)

RegisterNetEvent("powerplant:sync")
AddEventHandler(
    "powerplant:sync",
    function(data)
        points = data.Points
        ready = data.Ready
        if not data.Reserve then
            for i, point in each(points) do
                if not point.Made then
                    createZone(i, point)
                else
                    exports.target:RemoveZone("powerplant-" .. i)
                end
            end
        end
        SetArtificialLightsStateAffectsVehicles(false)
        SetArtificialLightsState(data.Blackout)
    end
)
RegisterNetEvent("powerplant:playAudio")
AddEventHandler(
    "powerplant:playAudio",
    function()
        PlaySoundFrontend(-1, "Power_Down", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
    end
)

AddEventHandler(
    "inventory:usedItem",
    function(itemName)
        if itemName == "detonator" then
            if canBlackout and ready then
                if not confirmed then
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Elektrárna",
                            text = "Zmáčkněte znovu spoušť pro potvrzení",
                            icon = "fas fa-times",
                            length = 3000
                        }
                    )
                    confirmed = true
                    Citizen.Wait(5000)
                    confirmed = false
                else
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Elektrárna",
                            text = "Blackout nastane za 10 vteřin",
                            icon = "fas fa-times",
                            length = 3000
                        }
                    )
                    TriggerServerEvent("powerplant:blackout")
                    Citizen.Wait(10000)
                    for i, point in each(points) do
                        if point.Made and point.Actions.Bomb then
                            AddExplosion(point.Coords.xyz, 34, 50.0, true, false, 10.0, false)
                            local bomb = GetClosestObjectOfType(point.Coords.xyz, 1.0, GetHashKey("prop_bomb_01"))
                            DeleteObject(bomb)
                        end
                    end
                end
            end
        end
    end
)
function plantBomb(pointId)
    local animDict = "anim@heists@ornate_bank@thermal_charge"
    local bagModel = "hei_p_m_bag_var22_arm_s"
    local bombModel = "prop_bomb_01"

    while not HasAnimDictLoaded(animDict) or not HasModelLoaded(bagModel) or not HasModelLoaded(bombModel) do
        RequestAnimDict(animDict)
        RequestModel(bagModel)
        RequestModel(bombModel)
        Citizen.Wait(1)
    end

    local playerPed = PlayerPedId()

    TaskGoStraightToCoord(playerPed, points[pointId].Actions.Bomb.xyz, 1.0, 3000, points[pointId].Actions.Bomb.w, 1.0)
    Citizen.Wait(1500)

    local playerRot = GetEntityRotation(PlayerPedId())
    local plantScene =
        NetworkCreateSynchronisedScene(points[pointId].Actions.Bomb.xyz, playerRot, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey(bagModel), points[pointId].Actions.Bomb.xyz, true, true, false)
    local bomb = CreateObject(GetHashKey(bombModel), points[pointId].Actions.Bomb.xyz, true, true, true)
    AttachEntityToEntity(
        bomb,
        playerPed,
        GetPedBoneIndex(playerPed, 28422),
        0,
        0,
        0,
        0,
        0,
        200.0,
        true,
        true,
        false,
        true,
        1,
        true
    )

    NetworkAddPedToSynchronisedScene(playerPed, plantScene, animDict, "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, plantScene, animDict, "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(plantScene)

    TriggerEvent(
        "mythic_progbar:client:progress",
        {
            name = "powerplant",
            duration = 5500,
            label = "Pokládáš bombu",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true
            }
        },
        function(canceled)
            if not canceled then
                DeleteObject(bag)
                DetachEntity(bomb, 1, 1)
                FreezeEntityPosition(bomb, true)
                canBlackout = true
                doingAction = false
                exports.notify:display(
                    {
                        type = "success",
                        title = "Elektrárna",
                        text = "Úspěšně jsi položil bombu! :)",
                        icon = "fas fa-times",
                        length = 3000
                    }
                )
                TriggerServerEvent("powerplant:doPoint", pointId)
            end
        end
    )
end
function hackPlace(pointId)
    local animDict = "anim@heists@ornate_bank@hack"

    while not HasAnimDictLoaded(animDict) or not HasModelLoaded("hei_prop_hst_laptop") or
        not HasModelLoaded("hei_p_m_bag_var22_arm_s") do
        RequestAnimDict(animDict)
        RequestModel("hei_prop_hst_laptop")
        RequestModel("hei_p_m_bag_var22_arm_s")
        Citizen.Wait(1)
    end
    local playerPed = PlayerPedId()

    TaskGoStraightToCoord(playerPed, points[pointId].Actions.Hack.xyz, 1.0, 3000, points[pointId].Actions.Hack.w, 1.0)
    Citizen.Wait(1500)
    local coords = vec3(points[pointId].Actions.Hack.xy, points[pointId].Actions.Hack.z)
    local playerCoords, playerRot = GetEntityCoords(playerPed), GetEntityRotation(playerPed)

    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), playerCoords, true, true, false)
    local laptop = CreateObject(GetHashKey("hei_prop_hst_laptop"), playerCoords, true, true, false)
    local animPos = GetAnimInitialOffsetPosition(animDict, "hack_enter", coords, coords, 0, 2)
    local animPos2 = GetAnimInitialOffsetPosition(animDict, "hack_loop", coords, coords, 0, 2)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, "hack_exit", coords, coords, 0, 2)

    local hackEnter = NetworkCreateSynchronisedScene(animPos, playerRot, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(playerPed, hackEnter, animDict, "hack_enter", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, hackEnter, animDict, "hack_enter_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, hackEnter, animDict, "hack_enter_laptop", 4.0, -8.0, 1)

    local hackLoop = NetworkCreateSynchronisedScene(animPos2, playerRot, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(playerPed, hackLoop, animDict, "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, hackLoop, animDict, "hack_loop_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, hackLoop, animDict, "hack_loop_laptop", 4.0, -8.0, 1)

    local hackExit = NetworkCreateSynchronisedScene(animPos3, playerRot, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(playerPed, hackExit, animDict, "hack_exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, hackExit, animDict, "hack_exit_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, hackExit, animDict, "hack_exit_laptop", 4.0, -8.0, 1)

    NetworkStartSynchronisedScene(hackEnter)
    Citizen.Wait(6300)
    NetworkStartSynchronisedScene(hackLoop)
    Citizen.Wait(2000)

    local hack =
        exports.hacking:HACKING_PC(
        {
            Scaleform = "HACKING_PC",
            Background = 4,
            Powerplant = true,
            PoliceReportChange = 80
        }
    )
    if hack == "successfull" then
        TriggerServerEvent("powerplant:doPoint", pointId)
    end
    Citizen.Wait(1500)
    NetworkStartSynchronisedScene(hackExit)
    Citizen.Wait(4600)
    canBlackout = true
    DeleteObject(bag)
    DeleteObject(laptop)
    TriggerServerEvent("powerplant:doPoint", pointId)
    doingAction = false
end

function loadJobs(Jobs)
    jobs = {}
    for _, jobData in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[jobData.job] = {
            Name = jobData.job,
            Type = exports.base_jobs:getJobVar(jobData.job, "type"),
            Grade = jobData.job_grade,
            Duty = jobData.duty
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

function guardPeds()
    local ped = PlayerPedId()

    if not hasWhitelistedJobType() then
        SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))
    else
        SetPedRelationshipGroupHash(ped, GetHashKey("GuardPeds"))
    end
    AddRelationshipGroup("GuardPeds")

    for i, coords in each(Config.Guards) do
        while not HasModelLoaded("ig_casey") do
            RequestModel("ig_casey")
            Citizen.Wait(1)
        end
        peds[i] = CreatePed(26, GetHashKey("ig_casey"), coords, true, true)
        NetworkRegisterEntityAsNetworked(peds[i])
        networkID = NetworkGetNetworkIdFromEntity(peds[i])
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetEntityAsMissionEntity(peds[i])
        SetEntityVisible(peds[i], true)
        SetPedRelationshipGroupHash(peds[i], GetHashKey("GuardPeds"))
        SetPedAccuracy(peds[i], 50)
        SetPedArmour(peds[i], 100)
        SetPedCanSwitchWeapon(peds[i], true)
        SetPedDropsWeaponsWhenDead(peds[i], false)
        GiveWeaponToPed(peds[i], GetHashKey("WEAPON_ADVANCEDRIFLE"), 255, false, false)
        if math.random(1, 2) == 2 then
            TaskGuardCurrentPosition(peds[i], 10.0, 10.0, 1)
        end
    end

    SetRelationshipBetweenGroups(0, GetHashKey("GuardPeds"), GetHashKey("GuardPeds"))
    SetRelationshipBetweenGroups(5, GetHashKey("GuardPeds"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GuardPeds"))
end

function createZone(i, point)
    local placeActions = {}
    if point.Actions.Bomb then
        placeActions.Bomb = {
            cb = function(data)
                if not points[data.Id].Reserved then
                    if not doingAction and not hasWhitelistedJobType() then
                        TriggerServerEvent("powerplant:checkItem", data.Id, "Bomb")
                    end
                end
            end,
            cbData = {Id = i},
            icon = "fas fa-bomb",
            label = "Použít C4"
        }
    end
    if point.Actions.Hack then
        placeActions.Hack = {
            cb = function(data)
                if not points[data.Id].Reserved then
                    if not doingAction and not hasWhitelistedJobType() then
                        TriggerServerEvent("powerplant:checkItem", data.Id, "Hack")
                    end
                end
            end,
            cbData = {Id = i},
            icon = "fas fa-unlock",
            label = "Hacknout zabezpečení"
        }
    end
    exports.target:AddCircleZone(
        "powerplant-" .. i,
        point.Coords.xyz,
        1.0,
        {
            actions = placeActions,
            distance = 0.5
        }
    )
end

RegisterNetEvent("powerplant:doAction")
AddEventHandler(
    "powerplant:doAction",
    function(pointId, action)
        doingAction = true
        if action == "Bomb" then
            plantBomb(pointId)
        elseif action == "Hack" then
            hackPlace(pointId)
        end
    end
)
