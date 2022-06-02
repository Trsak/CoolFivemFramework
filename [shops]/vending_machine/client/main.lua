local buying = false

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        for type, data in each(Config.TrackedEntities) do
            local models = {}
            for _, model in each(data.models) do
                table.insert(models, GetHashKey(model))
            end

            exports["target"]:AddTargetObject(models, {
                actions = {
                    vendingMachineUse = {
                        cb = function(machineData)
                            if not buying then
                                buying = true
                                TriggerServerEvent("vending_machine:buyItem", machineData.entity, machineData.type)
                            end
                        end,
                        cbData = {
                            type = type
                        },
                        icon = data.icon,
                        label = data.label,
                    }
                },
                distance = 1.2
            })
        end
    end
)

RegisterNetEvent("vending_machine:notEnoughMoney")
AddEventHandler(
    "vending_machine:notEnoughMoney",
    function(price)
        buying = false
        exports.notify:display({ type = "error", title = "Automat", text = "Nemáš u sebe $" .. price .. "!", icon = "fas fa-dollar-sign", length = 3500 })
    end
)

RegisterNetEvent("vending_machine:Random")
AddEventHandler(
    "vending_machine:Random",
    function(entity, machineData, type)
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
        exports.notify:display({ type = "info", title = "Automat", text = "Automat pracuje, chvíli vyčkej...", icon = "fas fa-info", length = 3500 })
        if machineData.machineSound then
            TriggerServerEvent("sound:playSound", "SodaMachine", 2.5, GetEntityCoords(playerPed))
        end

        Citizen.Wait(2500)

        if lottery <= 28 or not machineData.canBreak then
            if not IsAnimated then
                IsAnimated = true
                Citizen.CreateThread(
                    function()
                        local text = "Zakoupil"
                        if machineData.price <= 0 then
                            text = "Vzal"
                        end
                        exports.notify:display({ type = "success", title = "Automat", text = text .. " jsi produkt z automatu", icon = machineData.icon, length = 3500 })
                        IsAnimated = false

                        Citizen.Wait(1700)
                        ReqAnimDict(Config.PocketAnims[1])
                        TaskPlayAnim(playerPed, Config.PocketAnims[1], Config.PocketAnims[2], 8.0, 5.0, -1, true, 1, 0, 0, 0)
                        Citizen.Wait(1000)
                        ClearPedTasks(playerPed)

                        TriggerServerEvent("vending_machine:giveItem", type)
                        buying = false
                    end
                )
            end
        else
            Citizen.CreateThread(
                function()

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
