local buying = false

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        for type, data in each(Config.TrackedEntities) do
            local models = {}
            for _, model in each(data.Models) do
                table.insert(models, GetHashKey(model))
            end
            local actionsToSend = {}
            for item, action in pairs(data.Selling) do
                actionsToSend[item] = {
                    cb = function(machineData)
                        if not buying then
                            buying = true
                            TriggerServerEvent("stands:buyItem", machineData)
                        end
                    end,
                    cbData = {
                        type = type,
                        item = item
                    },
                    icon = action.Icon,
                    label = action.Label
                }
            end

            exports.target:AddTargetObject(
                models,
                {
                    actions = actionsToSend,
                    distance = data.Radius or 1.2
                }
            )
        end
    end
)

RegisterNetEvent("stands:notEnoughMoney")
AddEventHandler(
    "stands:notEnoughMoney",
    function(price)
        buying = false
        exports.notify:display(
            {
                type = "error",
                title = "Automat",
                text = "Nemáš u sebe $" .. price .. "!",
                icon = "fas fa-dollar-sign",
                length = 3500
            }
        )
    end
)

RegisterNetEvent("stands:Random")
AddEventHandler(
    "stands:Random",
    function(data, standData)
        local entity = data.entity
        local lottery = math.random(1, 30)
        local playerPed = PlayerPedId()

        local position = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.97, 0.05)
        TaskTurnPedToFaceEntity(playerPed, entity, -1)
        ReqAnimDict(Config.DispenseDict[1])
        SetPedCurrentWeaponVisible(playerPed, false, true, 1, 0)
        SetPedResetFlag(playerPed, 322, true)

        if not IsEntityAtCoord(playerPed, position, 0.1, 0.1, 1.5, false, true, 0) then
            while not IsEntityAtCoord(playerPed, position, 0.1, 0.1, 1.5, false, true, 0) do
                TaskGoStraightToCoord(playerPed, position, 1.0, 20000, GetEntityHeading(entity), 0.5)
                Citizen.Wait(2000)
            end
        end

        TaskTurnPedToFaceEntity(playerPed, entity, -1)
        Citizen.Wait(1000)
        TaskPlayAnim(playerPed, Config.DispenseDict[1], Config.DispenseDict[2], 8.0, 5.0, -1, true, 1, 0, 0, 0)
        Citizen.Wait(100)
        exports.notify:display(
            {
                type = "info",
                title = "Stánek",
                text = "Zaměstanec pracuje, chvíli vyčkej...",
                icon = "fas fa-info",
                length = 3500
            }
        )

        Citizen.Wait(2500)

        if not IsAnimated then
            IsAnimated = true
            Citizen.CreateThread(
                function()
                    local text = "Zakoupil"
                    if standData.Price <= 0 then
                        text = "Vzal"
                    end
                    exports.notify:display(
                        {
                            type = "success",
                            title = "Stánek",
                            text = text .. " jsi produkt ze stánku",
                            icon = standData.Icon,
                            length = 3500
                        }
                    )
                    IsAnimated = false

                    Citizen.Wait(1700)
                    ReqAnimDict(Config.PocketAnims[1])
                    TaskPlayAnim(
                        playerPed,
                        Config.PocketAnims[1],
                        Config.PocketAnims[2],
                        8.0,
                        5.0,
                        -1,
                        true,
                        1,
                        0,
                        0,
                        0
                    )
                    Citizen.Wait(1000)
                    ClearPedTasks(playerPed)

                    TriggerServerEvent("stands:giveItem")
                    buying = false
                end
            )
        end
    end
)

function ReqAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
end

function playMachineTakeAnim(playerPed)
    RequestAnimDict("amb@medic@standing@kneel@base")
    while not HasAnimDictLoaded("amb@medic@standing@kneel@base") do
        Citizen.Wait(0)
    end

    TaskPlayAnim(playerPed, "amb@medic@standing@kneel@base", "base", 3.0, 3.0, 2000, 0, 1, true, true, true)
end
