local doors, trolly = nil, nil
local isSpawned, isDead = false, false

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
            TriggerServerEvent("rob_pacificbank:sync")
            while not doors do
                Citizen.Wait(500)
            end
            for i, door in each(doors) do
                createZone(i, door)
            end
            for i, trly in each(trolly) do
                if trly.Left > 0 then
                    createTrollyZone(i, trly)
                end
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
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                TriggerServerEvent("rob_pacificbank:sync")
                while not doors do
                    Citizen.Wait(10)
                end
                for i, door in each(doors) do
                    createZone(i, door)
                end
                for i, trly in each(trolly) do
                    if trly.Left > 0 then
                        createTrollyZone(i, trly)
                    end
                end
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

function lockpick(doorId)
    TaskGoStraightToCoord(
        PlayerPedId(),
        doors[doorId].Actions.Lockpick.xyz,
        1.0,
        3000,
        doors[doorId].Actions.Lockpick.w,
        1.0
    )
    Citizen.Wait(1500)
    TriggerServerEvent(
        "sound:playSound",
        "lockpick",
        3.0,
        GetEntityCoords(PlayerPedId()),
        "pacific_bank_" .. PlayerId()
    )
    TriggerEvent(
        "mythic_progbar:client:progress",
        {
            name = "rob_pacificbank",
            duration = 2000,
            label = "Páčíš dveře",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true
            },
            animation = {
                animDict = "missheistfbisetup1",
                anim = "hassle_intro_loop_f"
            }
        },
        function(canceled)
            if not canceled then
                TriggerServerEvent("sound:stopSound", "pacific_bank_" .. PlayerId())
                TriggerServerEvent("rob_pacificbank:unlockDoors", doorId, "Silent")
                doingAction = false
                exports.notify:display(
                    {
                        type = "success",
                        title = "Dveře",
                        text = "Úspěšně jsi vypáčil dveře!",
                        icon = "fas fa-unlock",
                        length = 3000
                    }
                )
            end
        end
    )
end

function plantThermite(doorId)
    local bagModel = "hei_p_m_bag_var22_arm_s"
    local thermiteModel = "hei_prop_heist_thermite"
    local animDict = "anim@heists@ornate_bank@thermal_charge"
    while not HasAnimDictLoaded(animDict) or not HasModelLoaded("hei_p_m_bag_var22_arm_s") or
        not HasModelLoaded(thermiteModel) do
        RequestAnimDict(animDict)
        RequestModel(bagModel)
        RequestModel(thermiteModel)
        Citizen.Wait(50)
    end
    local playerPed = PlayerPedId()
    TaskGoStraightToCoord(
        playerPed,
        doors[doorId].Actions.Thermite.xyz,
        1.0,
        3000,
        doors[doorId].Actions.Thermite.w,
        1.0
    )
    Citizen.Wait(1500)

    local playerRot = GetEntityRotation(PlayerPedId())
    local plantingScene =
        NetworkCreateSynchronisedScene(
        doors[doorId].Actions.Thermite.xyz,
        playerRot.xy,
        playerRot.z,
        2,
        false,
        false,
        1065353216,
        0,
        1.3
    )
    local bag = CreateObject(GetHashKey(bagModel), doors[doorId].Actions.Thermite.xyz, true, true, false)
    local thermite = CreateObject(GetHashKey(thermiteModel), doors[doorId].Actions.Thermite.xyz, true, true, true)
    AttachEntityToEntity(
        thermite,
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

    NetworkAddPedToSynchronisedScene(
        playerPed,
        plantingScene,
        animDict,
        "thermal_charge",
        1.5,
        -4.0,
        1,
        16,
        1148846080,
        0
    )
    NetworkAddEntityToSynchronisedScene(bag, plantingScene, animDict, "bag_thermal_charge_suit", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(plantingScene)

    TriggerEvent(
        "mythic_progbar:client:progress",
        {
            name = "rob_pacificbank",
            duration = 5500,
            label = "Pokládáš termit",
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
            ClearPedTasks(PlayerPedId())

            if not canceled then
                DeleteObject(bag)
                DetachEntity(thermite, 1, 1)
                FreezeEntityPosition(thermite, true)
                TriggerServerEvent("rob_pacificbank:startThermite", doorId)
                Citizen.SetTimeout(
                    13000,
                    function()
                        TriggerServerEvent("rob_pacificbank:unlockDoors", doorId, "Loud")
                        FreezeEntityPosition(thermite, false)
                        DeleteObject(thermite)
                        doingAction = false
                        exports.notify:display(
                            {
                                type = "success",
                                title = "Dveře",
                                text = "Úspěšně jsi otevřel dveře!",
                                icon = "fas fa-unlock",
                                length = 3000
                            }
                        )
                    end
                )
            end
        end
    )
end

RegisterNetEvent("rob_pacificbank:sync")
AddEventHandler(
    "rob_pacificbank:sync",
    function(data)
        doors = data.Doors
        trolly = data.Trolly
        if not data.Reserve then
            for i, door in each(doors) do
                if not door.Made then
                    createZone(i, door)
                else
                    exports.target:RemoveZone("pacific-bank-" .. i)
                end
            end
            for i, trly in each(trolly) do
                if trly.Left > 0 then
                    createTrollyZone(i, trly)
                else
                    exports.target:RemoveZone("pacific-bank-trolly-" .. i)
                end
            end
        end
    end
)
RegisterNetEvent("rob_pacificbank:startThermite")
AddEventHandler(
    "rob_pacificbank:startThermite",
    function(doorId)
        RequestNamedPtfxAsset("scr_ornate_heist")
        while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
            Citizen.Wait(1)
        end
        SetPtfxAssetNextCall("scr_ornate_heist")

        local effect =
            StartParticleFxLoopedAtCoord(
            "scr_heist_ornate_thermal_burn",
            doors[doorId].Actions.Smoke,
            0.0,
            0.0,
            0.0,
            1.0,
            false,
            false,
            false,
            false
        )
        Citizen.Wait(13000)
        StopParticleFxLooped(effect, 0)
    end
)

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

function hasWhitelistedJobType()
    for _, data in pairs(jobs) do
        if Config.WhitelistedJobTypes[data.Type] and not data.Duty then
            return true
        end
    end

    return false
end

RegisterNetEvent("rob_pacificbank:doAction")
AddEventHandler(
    "rob_pacificbank:doAction",
    function(doorId, action)
        doingAction = true
        if action == "thermite" then
            plantThermite(doorId)
        elseif action == "lockpick" then
           -- lockpick(doorId)
        elseif action == "hack" then
            hackPlace(doorId)
        end
    end
)

RegisterNetEvent("rob_pacificbank:swapDoors")
AddEventHandler(
    "rob_pacificbank:swapDoors",
    function(doorId, type)
        if type == "Melt" then
            CreateModelSwap(doors[doorId].Coords.xyz, 5, doors[doorId].Prop, Config.ModelSwaps[doors[doorId].Prop], 1)
        else
            CreateModelSwap(doors[doorId].Coords.xyz, 5, Config.ModelSwaps[doors[doorId].Prop], doors[doorId].Prop, 1)
        end
    end
)

function hackPlace(doorId)
    local animDict = "anim@heists@ornate_bank@hack"

    while not HasAnimDictLoaded(animDict) or not HasModelLoaded("hei_prop_hst_laptop") or
        not HasModelLoaded("hei_p_m_bag_var22_arm_s") or
        not HasModelLoaded("hei_prop_heist_card_hack_02") do
        RequestAnimDict(animDict)
        RequestModel("hei_prop_hst_laptop")
        RequestModel("hei_p_m_bag_var22_arm_s")
        RequestModel("hei_prop_heist_card_hack_02")
        Citizen.Wait(100)
    end

    local playerPed = PlayerPedId()
    TaskGoStraightToCoord(playerPed, doors[doorId].Actions.Hack.xyz, 1.0, 3000, doors[doorId].Actions.Hack.w, 1.0)
    Citizen.Wait(1500)

    local playerCoords, playerRot = GetEntityCoords(playerPed), GetEntityRotation(playerPed)
    local coords = doors[doorId].Actions.Hack.xyz

    local animPos = GetAnimInitialOffsetPosition(animDict, "hack_enter", coords, coords, 0, 2)
    local animPos2 = GetAnimInitialOffsetPosition(animDict, "hack_loop", coords, coords, 0, 2)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, "hack_exit", coords, coords, 0, 2)

    local netScene = NetworkCreateSynchronisedScene(animPos, playerRot, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), playerCoords, 1, 1, 0)
    local laptop = CreateObject(GetHashKey("hei_prop_hst_laptop"), playerCoords, 1, 1, 0)
    local card = CreateObject(GetHashKey("hei_prop_heist_card_hack_02"), playerCoords, 1, 1, 0)

    NetworkAddPedToSynchronisedScene(playerPed, netScene, animDict, "hack_enter", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, "hack_enter_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, "hack_enter_laptop", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene, animDict, "hack_enter_card", 4.0, -8.0, 1)

    local netScene2 = NetworkCreateSynchronisedScene(animPos2, playerRot, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(playerPed, netScene2, animDict, "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, "hack_loop_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, "hack_loop_laptop", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene2, animDict, "hack_loop_card", 4.0, -8.0, 1)

    local netScene3 = NetworkCreateSynchronisedScene(animPos3, playerRot, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(playerPed, netScene3, animDict, "hack_exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, "hack_exit_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, "hack_exit_laptop", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene3, animDict, "hack_exit_card", 4.0, -8.0, 1)

    Citizen.Wait(200)
    NetworkStartSynchronisedScene(netScene)
    Citizen.Wait(6300)
    NetworkStartSynchronisedScene(netScene2)
    Citizen.Wait(2000)

    local hack =
        exports.hacking:HACKING_PC(
        {
            Scaleform = "HACKING_PC",
            Background = 4,
            Pacific = true,
            PoliceReportChange = 80
        }
    )
    if hack == "successfull" then
        if doors[doorId].DoorLockID ~= nil then
            TriggerServerEvent("rob_pacificbank:unlockDoors", doorId, "Silent")
        else
            TriggerServerEvent("rob_pacificbank:vaultManipulate", "Open")
            TriggerServerEvent("rob_pacificbank:createTrollys")
        end
    else
        TriggerServerEvent("rob_pacificbank:reserveDoor", doorId, false)
    end
    Citizen.Wait(1500)
    NetworkStartSynchronisedScene(netScene3)
    Citizen.Wait(4600)
    NetworkStopSynchronisedScene(netScene3)
    DeleteObject(bag)
    DeleteObject(laptop)
    DeleteObject(card)
    doingAction = false
end

RegisterNetEvent("rob_pacificbank:vaultManipulate")
AddEventHandler(
    "rob_pacificbank:vaultManipulate",
    function(type)
        local vaultDoors =
            GetClosestObjectOfType(253.92, 224.56, 101.88, 2.0, GetHashKey("v_ilev_bk_vaultdoor"), false, false, false)
        local count = 0
        FreezeEntityPosition(vaultDoors, true)

        if type == "Open" then
            while count < 1100 do
                local rotation = GetEntityHeading(vaultDoors) - 0.1

                SetEntityHeading(vaultDoors, rotation)
                count = count + 1

                Citizen.Wait(10)
            end
        else
            while count < 1100 do
                local rotation = GetEntityHeading(vaultDoors) + 0.1

                SetEntityHeading(vaultDoors, rotation)
                count = count + 1

                Citizen.Wait(10)
            end
        end
    end
)

function createZone(i, door)
    local placeActions = {}
    if door.Actions.Thermite then
        placeActions.Thermite = {
            cb = function(data)
                if not doors[data.Id].Reserved then
                    if not doingAction and not hasWhitelistedJobType() then
                        TriggerServerEvent("rob_pacificbank:checkItem", data.Id, "thermite")
                    end
                end
            end,
            cbData = {Id = i},
            icon = "fas fa-bomb",
            label = "Použít termit"
        }
    end
    if door.Actions.Lockpick then
        placeActions.Lockpick = {
            cb = function(data)
                if not doors[data.Id].Reserved then
                    if not doingAction and not hasWhitelistedJobType() then
                        TriggerServerEvent("rob_pacificbank:checkItem", data.Id, "lockpick")
                    end
                end
            end,
            cbData = {Id = i},
            icon = "fas fa-unlock",
            label = "Vypáčit zámek"
        }
    end
    if door.Actions.Hack then
        placeActions.Hack = {
            cb = function(data)
                if not doors[data.Id].Reserved then
                    if not doingAction and not hasWhitelistedJobType() then
                        TriggerServerEvent("rob_pacificbank:checkItem", data.Id, "hack")
                    end
                end
            end,
            cbData = {Id = i},
            icon = "fas fa-unlock",
            label = "Hacknout zabezpečení"
        }
    end
    local count = 0
    for _ in pairs(placeActions) do
        count = count + 1
    end
    if count > 0 then
        exports.target:AddCircleZone(
            "pacific-bank-" .. i,
            door.Coords.xyz,
            1.0,
            {
                actions = placeActions,
                distance = 0.5
            }
        )
    else
        exports.target:RemoveZone("pacific-bank-" .. i)
    end
end

function createTrollyZone(i, trly)
    exports.target:AddCircleZone(
        "pacific-bank-trolly-" .. i,
        trly.Coords.xyz,
        1.0,
        {
            actions = {
                use = {
                    cb = function(data)
                        if not trolly[data.Id].Reserved then
                            TriggerServerEvent("rob_pacificbank:reserveTrolly", data.Id)
                            Citizen.Wait(200)
                            Loot(data.Id)
                        end
                    end,
                    cbData = {Id = i},
                    icon = "fas fa-cash",
                    label = "Použít vozík"
                }
            },
            distance = 0.5
        }
    )
end

function Loot(trollyId)
    local ped = PlayerPedId()
    local model = "hei_prop_heist_cash_pile"

    local Trolly = NetworkGetEntityFromNetworkId(trolly[trollyId].NetId)
    if trolly[trollyId].Type == "gold" then
        model = "ch_prop_gold_bar_01a"
    end

    function CashAppear()
        local pedCoords = GetEntityCoords(ped)
        local grabmodel = GetHashKey(model)

        while not HasModelLoaded(grabmodel) do
            RequestModel(grabmodel)
            Citizen.Wait(100)
        end
        local propInHand = CreateObject(grabmodel, pedCoords, true)

        FreezeEntityPosition(propInHand, true)
        SetEntityInvincible(propInHand, true)
        SetEntityNoCollisionEntity(propInHand, ped)
        SetEntityVisible(propInHand, false, false)
        AttachEntityToEntity(
            propInHand,
            ped,
            GetPedBoneIndex(ped, 60309),
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            false,
            false,
            false,
            false,
            0,
            true
        )
        local startedGrabbing = GetGameTimer()

        Citizen.CreateThread(
            function()
                while GetGameTimer() - startedGrabbing < 37000 do
                    Citizen.Wait(1)
                    DisableControlAction(0, 73, true)
                    if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                        if not IsEntityVisible(propInHand) then
                            SetEntityVisible(propInHand, true, false)
                        end
                    end
                    if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                        if IsEntityVisible(propInHand) then
                            SetEntityVisible(propInHand, false, false)
                            TriggerServerEvent("rob_pacificbank:lootTrolly", trollyId)
                        end
                    end
                end
                DeleteObject(propInHand)
            end
        )
    end

    local animDict = "anim@heists@ornate_bank@grab_cash"
    local emptyTrolly = 769923921
    local trllyCoords = GetEntityCoords(Trolly)

    if IsEntityPlayingAnim(Trolly, animDict, "cart_cash_dissapear", 3) then
        return
    end
    local bagHash = GetHashKey("hei_p_m_bag_var22_arm_s")

    while not HasAnimDictLoaded(animDict) and not HasModelLoaded(emptyTrolly) and not HasModelLoaded(bagHash) do
        RequestAnimDict(animDict)
        RequestModel(bagHash)
        RequestModel(emptyTrolly)
        Citizen.Wait(100)
    end
    while not NetworkHasControlOfEntity(Trolly) do
        Citizen.Wait(1)
        NetworkRequestControlOfEntity(Trolly)
    end
    local bag = CreateObject(bagHash, GetEntityCoords(ped), true, false, false)
    local grabInit =
        NetworkCreateSynchronisedScene(trllyCoords, GetEntityRotation(Trolly), 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, grabInit, animDict, "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, grabInit, animDict, "bag_intro", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(grabInit)
    Citizen.Wait(1500)
    CashAppear()
    local grabLoop =
        NetworkCreateSynchronisedScene(trllyCoords, GetEntityRotation(Trolly), 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, grabLoop, animDict, "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, grabLoop, animDict, "bag_grab", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(Trolly, grabLoop, animDict, "cart_cash_dissapear", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(grabLoop)
    Citizen.Wait(37000)
    local grabExit =
        NetworkCreateSynchronisedScene(trllyCoords, GetEntityRotation(Trolly), 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, grabExit, animDict, "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, grabExit, animDict, "bag_exit", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(grabExit)
    Newtrolly = CreateObject(emptyTrolly, trllyCoords + vector3(0.0, 0.0, -0.985), true, false, false)
    SetEntityRotation(Newtrolly, GetEntityRotation(Trolly))

    while not NetworkHasControlOfEntity(Trolly) do
        Citizen.Wait(1)
        NetworkRequestControlOfEntity(Trolly)
    end

    while DoesEntityExist(Trolly) do
        Citizen.Wait(1)
        DeleteObject(Trolly)
    end

    PlaceObjectOnGroundProperly(Newtrolly)
    Citizen.Wait(1800)

    if DoesEntityExist(bag) then
        DeleteEntity(bag)
    end
    RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
    SetModelAsNoLongerNeeded(emptyTrolly)
    SetModelAsNoLongerNeeded(bagHash)
end
