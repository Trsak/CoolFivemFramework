local isSpawned, isDead = false, false
local isMenuActive = false
local shouldCloseMenu = false
local dialogPed

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end

        local pedGroups = {}
        for pedGroup, _ in pairs(Config.PedGroups) do
            table.insert(pedGroups, GetHashKey(pedGroup))
        end

        exports.target:AddTargetPedRelationshipGroups(
            pedGroups,
            {
                actions = {
                    ask = {
                        cb = function(data)
                            if isSpawned and not isDead and not isMenuActive then
                                local playerPedId = PlayerPedId()

                                if IsPedInAnyVehicle(playerPedId) then
                                    exports.notify:display(
                                        {
                                            type = "error",
                                            title = "Oslovení",
                                            text = "Z auta to nepůjde!",
                                            icon = "fas fa-times",
                                            length = 5000
                                        }
                                    )
                                    return
                                end

                                if GetEntityHealth(data.entity) > 0 and not IsPedDeadOrDying(data.entity) and not IsPedInAnyVehicle(data.entity) and not IsPedInMeleeCombat(data.entity) then
                                    ClearPedTasks(data.entity)
                                    TaskStandStill(data.entity, 10000)

                                    TaskTurnPedToFaceEntity(data.entity, playerPedId, 1.5)
                                    TaskTurnPedToFaceEntity(playerPedId, data.entity, 1.5)

                                    exports.progressbar:startProgressBar({
                                        Duration = 5000,
                                        Label = "Nabízíš trávu k prodeji..",
                                        CanBeDead = false,
                                        CanCancel = true,
                                        DisableControls = {
                                            Movement = true,
                                            CarMovement = true,
                                            Mouse = false,
                                            Combat = true
                                        },
                                        Animation = {
                                            animDict = "mp_arresting",
                                            anim = "a_uncuff",
                                            flags = 51
                                        }
                                    }, function(finished)
                                        if finished then
                                            TriggerServerEvent(
                                                "npc_sell:startTalk",
                                                PedToNet(data.entity),
                                                GetPedRelationshipGroupHash(data.entity),
                                                GetRelationshipBetweenPeds(playerPedId, data.entity)
                                            )

                                            TaskTurnPedToFaceEntity(data.entity, playerPedId, 1.5)
                                            Wait (200)
                                            TaskStandStill(data.entity, 10000)
                                        end
                                        ClearPedTasks(playerPedId)
                                    end)

                                    Wait (1500)
                                    TaskTurnPedToFaceEntity(data.entity, playerPedId, 1.5)
                                    Wait (500)

                                    TaskStandStill(data.entity, 10000)
                                else
                                    exports.notify:display(
                                        {
                                            type = "error",
                                            title = "Oslovení",
                                            text = "Jsi od osoby příliš daleko, nebo s ní nelze obchodovat!",
                                            icon = "fas fa-times",
                                            length = 5000
                                        }
                                    )
                                end
                            end
                        end,
                        icon = "fas fa-cannabis",
                        label = "Zkusit prodat trávu"
                    }
                },
                distance = 1.2
            }
        )
    end
)

Citizen.CreateThread(
    function()
        while true do
            Wait(200)
            if dialogPed and (not DoesEntityExist(dialogPed) or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(dialogPed)) > 7.0) then
                shouldCloseMenu = true
                exports.notify:display(
                    {
                        type = "error",
                        title = "Oslovení",
                        text = "Osoba se vzdálila příliš daleko!",
                        icon = "fas fa-times",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead = false, false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("npc_sell:callPolice")
AddEventHandler(
    "npc_sell:callPolice",
    function(netId)
        local ped = NetToPed(netId)
        if DoesEntityExist(ped) then
            TriggerServerEvent(
                "outlawalert:sendAlert",
                {
                    Type = "illegalsell",
                    Coords = GetEntityCoords(ped)
                }
            )
        end
    end
)

RegisterNetEvent("npc_sell:sold")
AddEventHandler(
    "npc_sell:sold",
    function(netId, sellPrice)
        local ped = NetToPed(netId)
        if DoesEntityExist(ped) then
            RequestAnimDict("mp_common")
            while (not HasAnimDictLoaded("mp_common")) do
                Citizen.Wait(10)
            end

            local playerPedId = PlayerPedId()
            SetCurrentPedWeapon(playerPedId, GetHashKey("weapon_unarmed"))
            local attachModel = GetHashKey("bkr_prop_weed_bag_01a")

            RequestModel(attachModel)
            while not HasModelLoaded(attachModel) do
                Citizen.Wait(100)
            end

            local attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
            AttachEntityToEntity(attachedProp, playerPedId, GetPedBoneIndex(playerPedId, 28422), 0.1, 0.0, -0.03, 135.0, -100.0, 40.0, 1, 1, 0, 0, 2, 1)
            SetEntityCollision(attachedProp, false, true)

            ClearPedTasks(ped)
            TaskTurnPedToFaceEntity(ped, playerPedId, 1.5)
            TaskTurnPedToFaceEntity(playerPedId, ped, 1.5)

            Citizen.Wait(50)

            TaskPlayAnim(
                ped,
                "mp_common",
                "givetake1_a",
                100.0,
                200.0,
                0.3,
                120,
                0.2,
                0,
                0,
                0
            )

            TaskPlayAnim(
                playerPedId,
                "mp_common",
                "givetake1_a",
                100.0,
                200.0,
                0.3,
                120,
                0.2,
                0,
                0,
                0
            )

            exports.notify:display(
                {
                    type = "success",
                    title = "Úspěch",
                    text = "Prodal jsi balíček s trávou za " .. exports.data:getFormattedCurrency(sellPrice) .. "!",
                    icon = "fas fa-cannabis",
                    length = 5000
                }
            )

            Citizen.Wait(800)
            DeleteEntity(attachedProp)
            Citizen.Wait(50)
            ClearPedTasks(ped)
            ClearPedTasks(playerPedId)
        end
    end
)

RegisterNetEvent("npc_sell:sellToPlayer")
AddEventHandler(
    "npc_sell:sellToPlayer",
    function(netId, sellPrice, isFriendlyRelationship)
        local ped = NetToPed(netId)
        if DoesEntityExist(ped) then
            local weedPrice = exports.data:getFormattedCurrency(sellPrice)

            local betterPrices = {
                math.ceil(sellPrice + sellPrice * 0.1),
                math.ceil(sellPrice + sellPrice * 0.2),
                math.ceil(sellPrice + sellPrice * 0.3),
                math.ceil(sellPrice + sellPrice * 0.4),
                math.ceil(sellPrice + sellPrice * 0.5)
            }

            shouldCloseMenu = false
            isMenuActive = true
            dialogPed = ped

            WarMenu.CreateMenu("weed_npc_sell", "Prodat trávu za " .. weedPrice, "Přeješ si trávu prodat?")
            WarMenu.OpenMenu("weed_npc_sell")
            WarMenu.SetMenuY("weed_npc_sell", 0.35)

            WarMenu.CreateSubMenu("weed_npc_sell_better", "weed_npc_sell", "Zvolte cenu na vyjednávání")

            while true do
                if WarMenu.IsMenuOpened("weed_npc_sell") then
                    if WarMenu.Button("Prodat za " .. weedPrice) then
                        TriggerServerEvent(
                            "npc_sell:confirmBuy",
                            netId
                        )
                        WarMenu.CloseMenu()
                    elseif not isFriendlyRelationship and WarMenu.MenuButton("Zkusit vyjednat lepší cenu", "weed_npc_sell_better") then
                    elseif WarMenu.Button("Nevyužít nabídky") then
                        WarMenu.CloseMenu()
                    end

                    WarMenu.Display()
                elseif not isFriendlyRelationship and WarMenu.IsMenuOpened("weed_npc_sell_better") then
                    for _, betterPrice in each(betterPrices) do
                        if WarMenu.Button("Nabídnout za " .. betterPrice .. "$") then
                            TriggerServerEvent(
                                "npc_sell:confirmBuy",
                                netId,
                                betterPrice
                            )
                            WarMenu.CloseMenu()
                        end
                    end

                    WarMenu.Display()
                else
                    WarMenu.CloseMenu()
                    break
                end

                if shouldCloseMenu then
                    WarMenu.CloseMenu()
                    break
                end

                Citizen.Wait(0)
            end

            dialogPed = nil
            isMenuActive = false
        end
    end
)

